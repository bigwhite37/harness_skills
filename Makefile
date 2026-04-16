# convergent-dev-flow 验证工具
# 维护工具，非 skill 运行时的一部分。

.PHONY: test tier1 tier2 tier3 all

# 快速验证（无 API 依赖）
test: tier1 tier2

# Tier 1: 回归断言（12 个 RC）
tier1:
	@bash scripts/tier1_regression.sh

# Tier 2: 自检断言（16 个 SC）
tier2:
	@bash scripts/tier2_selfcheck.sh

# Tier 3: LLM-as-judge 评估（20 个用例，需要 ANTHROPIC_API_KEY）
tier3:
	@python3 scripts/tier3_llm_eval.py $(ARGS)

# 完整验证（含 API 调用）
all: tier1 tier2 tier3
