#!/usr/bin/env bash
# ============================================================================
# Tier 1 回归断言脚本
# 维护工具，非 skill 运行时的一部分。从开发者终端执行。
# 实现 evals/regression-cases.md 中的 14 个 RC 断言。
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS_COUNT=0
FAIL_COUNT=0

pass() {
  echo "PASS  $1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
  echo "FAIL  $1  — $2"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

# ---------------------------------------------------------------------------
# RC-01: "快速失败"作为显式停止规则存在于 SKILL.md + guards/quick-fail.md
# ---------------------------------------------------------------------------
rc01() {
  local id="RC-01 快速失败"
  if grep -q '快速失败' "$ROOT/SKILL.md" && grep -q -E '快速失败|quick-fail|立即停止' "$ROOT/guards/quick-fail.md" 2>/dev/null; then
    pass "$id"
  else
    fail "$id" "SKILL.md 或 guards/quick-fail.md 缺少 '快速失败'"
  fi
}

# ---------------------------------------------------------------------------
# RC-02: "禁止静默回退"存在于 SKILL.md + guards/no-silent-fallback.md
# ---------------------------------------------------------------------------
rc02() {
  local id="RC-02 禁止静默回退"
  if grep -q '禁止静默回退' "$ROOT/SKILL.md" && grep -q -E '禁止静默回退|不得悄悄切换' "$ROOT/guards/no-silent-fallback.md" 2>/dev/null; then
    pass "$id"
  else
    fail "$id" "SKILL.md 或 guards/no-silent-fallback.md 缺少相关表述"
  fi
}

# ---------------------------------------------------------------------------
# RC-03: "禁止隐式默认"存在于 SKILL.md + guards/no-implicit-defaults.md
# ---------------------------------------------------------------------------
rc03() {
  local id="RC-03 禁止隐式默认"
  if grep -q '禁止隐式默认' "$ROOT/SKILL.md" && grep -q -E '禁止隐式默认|合理默认值' "$ROOT/guards/no-implicit-defaults.md" 2>/dev/null; then
    pass "$id"
  else
    fail "$id" "SKILL.md 或 guards/no-implicit-defaults.md 缺少相关表述"
  fi
}

# ---------------------------------------------------------------------------
# RC-04: 证据要求 — "依赖证据" + "验收点到证据"在相关文件
# ---------------------------------------------------------------------------
rc04() {
  local id="RC-04 证据要求"
  local ok=true
  grep -q '依赖证据' "$ROOT/SKILL.md" || ok=false
  grep -q -E '验收点.*证据|证据.*验收' "$ROOT/flows/verify.md" 2>/dev/null || ok=false
  grep -q -E '没有证据|不能宣称完成' "$ROOT/guards/evidence-required.md" 2>/dev/null || ok=false
  if $ok; then
    pass "$id"
  else
    fail "$id" "证据要求链不完整（SKILL.md / flows/verify.md / guards/evidence-required.md）"
  fi
}

# ---------------------------------------------------------------------------
# RC-05: 宪法第 8 条 — ticket 不可跳过 + phase-order 禁止动作
# ---------------------------------------------------------------------------
rc05() {
  local id="RC-05 ticket-before-build"
  local ok=true
  grep -q -E '先有.*ticket.*再做.*build' "$ROOT/SKILL.md" || ok=false
  grep -q -E '没有活动 ticket.*不得进入.*build' "$ROOT/flows/phase-order.md" 2>/dev/null || ok=false
  if $ok; then
    pass "$id"
  else
    fail "$id" "SKILL.md 或 flows/phase-order.md 缺少 ticket-before-build 规则"
  fi
}

# ---------------------------------------------------------------------------
# RC-06: 宪法第 3 条 — review/verify 独立 + 两个 flow 文件存在
# ---------------------------------------------------------------------------
rc06() {
  local id="RC-06 review/verify 分离"
  local ok=true
  grep -q -E '绝不把.*review.*verify.*合并' "$ROOT/SKILL.md" || ok=false
  [ -f "$ROOT/flows/review.md" ] || ok=false
  [ -f "$ROOT/flows/verify.md" ] || ok=false
  if $ok; then
    pass "$id"
  else
    fail "$id" "review/verify 分离不完整（宪法第 3 条 或文件缺失）"
  fi
}

# ---------------------------------------------------------------------------
# RC-07: phases/ 目录不得存在
# ---------------------------------------------------------------------------
rc07() {
  local id="RC-07 无 phases/ 目录"
  if [ -d "$ROOT/phases" ]; then
    fail "$id" "phases/ 目录仍然存在"
  else
    pass "$id"
  fi
}

# ---------------------------------------------------------------------------
# RC-08: 无 "small-fix" / "fast-track" / "quick-path" 表述
# ---------------------------------------------------------------------------
rc08() {
  local id="RC-08 无快捷路径表述"
  local found
  found=$(grep -rl -E 'small-fix|fast-track|quick-path' \
    "$ROOT/SKILL.md" \
    "$ROOT/flows/" \
    "$ROOT/references/" \
    "$ROOT/guards/" \
    "$ROOT/templates/" \
    2>/dev/null || true)
  if [ -z "$found" ]; then
    pass "$id"
  else
    fail "$id" "在以下文件中找到快捷路径表述: $found"
  fi
}

# ---------------------------------------------------------------------------
# RC-09: 所有 .md frontmatter 无 context: 字段
# ---------------------------------------------------------------------------
rc09() {
  local id="RC-09 无 context: frontmatter"
  local found=""
  for dir in flows templates references; do
    local matches
    matches=$(find "$ROOT/$dir" -name '*.md' -exec \
      awk '/^---$/{fm++} fm==1 && /^context:/{print FILENAME; exit}' {} \; 2>/dev/null || true)
    if [ -n "$matches" ]; then
      found="$found $matches"
    fi
  done
  if [ -z "$found" ]; then
    pass "$id"
  else
    fail "$id" "以下文件 frontmatter 含 context: $found"
  fi
}

# ---------------------------------------------------------------------------
# RC-10: 4 个必需示例目录存在
# ---------------------------------------------------------------------------
rc10() {
  local id="RC-10 必需示例目录"
  local ok=true
  for d in small-bug small-feature safe-refactor blocked-run; do
    [ -d "$ROOT/examples/$d" ] || ok=false
  done
  if $ok; then
    pass "$id"
  else
    fail "$id" "examples/ 缺少必需子目录"
  fi
}

# ---------------------------------------------------------------------------
# RC-11: gate-rubric.md 存在 + 含 "通用 Go 问题" + "各阶段 Go 问题"
# ---------------------------------------------------------------------------
rc11() {
  local id="RC-11 gate-rubric"
  local ok=true
  [ -f "$ROOT/references/gate-rubric.md" ] || ok=false
  if $ok; then
    grep -q '通用 Go 问题' "$ROOT/references/gate-rubric.md" || ok=false
    grep -q '各阶段 Go 问题' "$ROOT/references/gate-rubric.md" || ok=false
  fi
  if $ok; then
    pass "$id"
  else
    fail "$id" "references/gate-rubric.md 缺失或内容不完整"
  fi
}

# ---------------------------------------------------------------------------
# RC-12: 宪法第 16 条（自治边界 — v1 不得调用脚本等）
# ---------------------------------------------------------------------------
rc12() {
  local id="RC-12 自治边界（宪法第 16 条）"
  if grep -q -E '不得调用脚本.*hooks.*subagents' "$ROOT/SKILL.md"; then
    pass "$id"
  else
    fail "$id" "SKILL.md 缺少宪法第 16 条（v1 自治边界）"
  fi
}

# ---------------------------------------------------------------------------
# RC-13: 集成版阶段文档显式要求 gstack / superpowers 调用
# ---------------------------------------------------------------------------
rc13() {
  local id="RC-13 外部技能显式调用点"
  local ok=true
  grep -q 'office-hours' "$ROOT/flows/reframe.md" 2>/dev/null || ok=false
  grep -q 'plan-ceo-review' "$ROOT/flows/plan.md" 2>/dev/null || ok=false
  grep -q 'plan-eng-review' "$ROOT/flows/plan.md" 2>/dev/null || ok=false
  grep -q 'test-driven-development' "$ROOT/flows/build.md" 2>/dev/null || ok=false
  grep -q '/review' "$ROOT/flows/review.md" 2>/dev/null || ok=false
  grep -q 'verification-before-completion' "$ROOT/flows/verify.md" 2>/dev/null || ok=false
  grep -q '/retro' "$ROOT/flows/retro.md" 2>/dev/null || ok=false
  if $ok; then
    pass "$id"
  else
    fail "$id" "flows/ 中缺少集成版必需的外部技能显式调用点"
  fi
}

# ---------------------------------------------------------------------------
# RC-14: 安装链路要求先安装 / 校验 gstack 与 superpowers 依赖
# ---------------------------------------------------------------------------
rc14() {
  local id="RC-14 安装链路包含外部依赖"
  local ok=true
  grep -q 'GSTACK_SOURCE_REPO' "$ROOT/INSTALL.md" 2>/dev/null || ok=false
  grep -q 'GSTACK_REV' "$ROOT/INSTALL.md" 2>/dev/null || ok=false
  grep -q 'SUPERPOWERS_SOURCE_REPO' "$ROOT/INSTALL.md" 2>/dev/null || ok=false
  grep -q 'SUPERPOWERS_PROVENANCE' "$ROOT/INSTALL.md" 2>/dev/null || ok=false
  grep -q 'office-hours' "$ROOT/README.md" 2>/dev/null || ok=false
  grep -q 'test-driven-development' "$ROOT/docs/usage.md" 2>/dev/null || ok=false
  if $ok; then
    pass "$id"
  else
    fail "$id" "INSTALL.md / README.md / docs/usage.md 未完整表达集成版外部依赖安装契约"
  fi
}

# ---------------------------------------------------------------------------
# 执行所有断言
# ---------------------------------------------------------------------------
echo "=== Tier 1 回归断言 (evals/regression-cases.md) ==="
echo ""

rc01
rc02
rc03
rc04
rc05
rc06
rc07
rc08
rc09
rc10
rc11
rc12
rc13
rc14

echo ""
echo "=== 汇总: $PASS_COUNT PASS / $FAIL_COUNT FAIL (共 $((PASS_COUNT + FAIL_COUNT))) ==="

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
exit 0
