# convergent-dev-flow 验证工具
# 维护工具，非 skill 运行时的一部分。

.PHONY: test probe-install tier1 tier2 tier3 tier4 all

REF ?= refs/heads/main
REPO ?= bigwhite37/harness_skills

# 快速验证（无 API 依赖）
test: tier1 tier2

# Published Ref Probe: 已发布 ref 的公开安装入口探测
probe-install:
	@bash scripts/check_remote_install.sh --ref "$(REF)" --repo "$(REPO)"

# Tier 1: 回归断言（14 个 RC）
tier1:
	@bash scripts/tier1_regression.sh

# Tier 2: 自检断言（21 个 SC）
tier2:
	@bash scripts/tier2_selfcheck.sh

# Tier 3: LLM-as-judge 评估（27 个用例，需要 ANTHROPIC_API_KEY）
tier3:
	@python3 scripts/tier3_llm_eval.py $(ARGS)

# Tier 4: 只用 Codex 的宿主黑盒验证
tier4:
	@bash scripts/tier4_codex_host_e2e.sh $(ARGS)

# 完整验证（含 API 调用）
all: tier1 tier2 tier3
