#!/usr/bin/env python3
"""
Tier 3 LLM-as-judge 评估脚本
维护工具，非 skill 运行时的一部分。从开发者终端执行。

依赖: pip install anthropic pyyaml

用法:
  python3 scripts/tier3_llm_eval.py                    # 运行全部 27 个用例
  python3 scripts/tier3_llm_eval.py --case TC-05       # 运行单个用例
  python3 scripts/tier3_llm_eval.py --category trigger  # 运行某类用例
  python3 scripts/tier3_llm_eval.py --output results.json  # 输出 JSON
  python3 scripts/tier3_llm_eval.py --verbose           # 显示详细推理
"""

import argparse
import json
import os
import sys
import time
from pathlib import Path

try:
    import yaml
except ImportError:
    print("ERROR: pyyaml 未安装。运行: pip install pyyaml", file=sys.stderr)
    sys.exit(2)

try:
    import anthropic
except ImportError:
    print("ERROR: anthropic 未安装。运行: pip install anthropic", file=sys.stderr)
    sys.exit(2)


SCRIPT_DIR = Path(__file__).resolve().parent
ROOT = SCRIPT_DIR.parent


def load_config() -> dict:
    config_path = SCRIPT_DIR / "tier3_config.yaml"
    with open(config_path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def build_system_prompt(config: dict) -> str:
    """拼接 skill context 文件为 system prompt。"""
    parts = [
        "你是一个代码智能体，已安装了 convergent-dev-flow 技能。"
        "以下是技能的完整定义文件内容。你必须严格按照这些规则行事。\n"
    ]
    for rel_path in config["context_files"]:
        full_path = ROOT / rel_path
        if full_path.exists():
            content = full_path.read_text(encoding="utf-8")
            parts.append(f"=== {rel_path} ===\n{content}\n")
        else:
            parts.append(f"=== {rel_path} === (文件不存在)\n")
    return "\n".join(parts)


def build_judge_prompt(case: dict, response: str) -> str:
    """构建 judge 模型的评估 prompt。"""
    return f"""你是一个严格的评估者。你需要判断被测模型的响应是否满足给定的通过标准。

## 测试用例

- **ID**: {case["id"]}
- **类别**: {case["category"]}
- **输入**: {case["input"]}
- **上下文/setup**: {case.get("setup", "无")}
- **预期行为**: {case["expected"]}
- **通过标准**: {case["pass_criteria"]}

## 被测模型的响应

{response}

## 你的任务

判断上述响应是否满足通过标准。输出严格 JSON 格式，不要输出其他内容：

{{"verdict": "pass" 或 "fail", "reasoning": "一句话解释"}}"""


def run_case(
    client: anthropic.Anthropic,
    system_prompt: str,
    case: dict,
    config: dict,
    verbose: bool = False,
) -> dict:
    """运行单个用例：被测模型生成 -> judge 模型评判。"""
    model = config["model"]
    judge_model = config["judge_model"]

    # 构建被测消息
    messages = []
    if case.get("setup"):
        messages.append({"role": "user", "content": case["setup"]})
        messages.append(
            {"role": "assistant", "content": "好的，我理解当前的上下文。请继续。"}
        )
    messages.append({"role": "user", "content": case["input"]})

    # 调用被测模型
    try:
        response = client.messages.create(
            model=model,
            max_tokens=2048,
            system=system_prompt,
            messages=messages,
        )
        response_text = response.content[0].text
    except Exception as e:
        return {
            "id": case["id"],
            "verdict": "error",
            "reasoning": f"被测模型调用失败: {e}",
            "response": "",
        }

    if verbose:
        print(f"\n  [{case['id']}] 被测模型响应 (前 200 字):")
        print(f"  {response_text[:200]}...")

    # sleep 避免限流
    time.sleep(1)

    # 调用 judge 模型
    judge_prompt = build_judge_prompt(case, response_text)
    try:
        judge_response = client.messages.create(
            model=judge_model,
            max_tokens=512,
            messages=[{"role": "user", "content": judge_prompt}],
        )
        judge_text = judge_response.content[0].text.strip()

        # 提取 JSON
        # 处理可能被 markdown 包裹的情况
        if "```" in judge_text:
            lines = judge_text.split("\n")
            json_lines = []
            in_block = False
            for line in lines:
                if line.strip().startswith("```"):
                    in_block = not in_block
                    continue
                if in_block:
                    json_lines.append(line)
            judge_text = "\n".join(json_lines)

        result = json.loads(judge_text)
        return {
            "id": case["id"],
            "verdict": result.get("verdict", "error"),
            "reasoning": result.get("reasoning", ""),
            "response": response_text[:500],
        }
    except (json.JSONDecodeError, Exception) as e:
        return {
            "id": case["id"],
            "verdict": "error",
            "reasoning": f"Judge 解析失败: {e} | raw: {judge_text[:200] if 'judge_text' in dir() else 'N/A'}",
            "response": response_text[:500],
        }


def main():
    parser = argparse.ArgumentParser(description="Tier 3 LLM-as-judge 评估")
    parser.add_argument("--case", help="运行单个用例 (e.g. TC-05)")
    parser.add_argument(
        "--category", help="运行某类用例 (trigger / stage-gate)"
    )
    parser.add_argument("--output", help="输出 JSON 文件路径")
    parser.add_argument("--verbose", action="store_true", help="显示详细信息")
    args = parser.parse_args()

    # 检查 API key
    if not os.environ.get("ANTHROPIC_API_KEY"):
        print("ERROR: 请设置 ANTHROPIC_API_KEY 环境变量", file=sys.stderr)
        sys.exit(2)

    config = load_config()
    client = anthropic.Anthropic()
    system_prompt = build_system_prompt(config)

    # 筛选用例
    cases = config["cases"]
    if args.case:
        cases = [c for c in cases if c["id"] == args.case]
        if not cases:
            print(f"ERROR: 未找到用例 {args.case}", file=sys.stderr)
            sys.exit(2)
    elif args.category:
        cases = [c for c in cases if c["category"] == args.category]
        if not cases:
            print(f"ERROR: 未找到类别 {args.category}", file=sys.stderr)
            sys.exit(2)

    print(f"=== Tier 3 LLM-as-judge 评估 ===")
    print(f"被测模型: {config['model']}")
    print(f"评判模型: {config['judge_model']}")
    print(f"用例数量: {len(cases)}")
    print()

    results = []
    pass_count = 0
    fail_count = 0
    error_count = 0

    for case in cases:
        print(f"  运行 {case['id']}...", end=" ", flush=True)
        result = run_case(client, system_prompt, case, config, args.verbose)
        results.append(result)

        verdict = result["verdict"]
        if verdict == "pass":
            print(f"PASS")
            pass_count += 1
        elif verdict == "fail":
            print(f"FAIL  — {result['reasoning']}")
            fail_count += 1
        else:
            print(f"ERROR — {result['reasoning']}")
            error_count += 1

        # sleep 避免限流
        time.sleep(1)

    print()
    print(
        f"=== 汇总: {pass_count} PASS / {fail_count} FAIL / {error_count} ERROR"
        f" (共 {len(results)}) ==="
    )

    if args.output:
        output_path = Path(args.output)
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(results, f, ensure_ascii=False, indent=2)
        print(f"\n结果已写入 {output_path}")

    if fail_count > 0 or error_count > 0:
        sys.exit(1)
    sys.exit(0)


if __name__ == "__main__":
    main()
