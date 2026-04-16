#!/usr/bin/env bash
# ============================================================================
# Tier 2 自检断言脚本
# 维护工具，非 skill 运行时的一部分。从开发者终端执行。
# 从 docs/self-check.md 提取可自动化检查项。
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
# SC-01: 阶段顺序文本在 SKILL.md
# ---------------------------------------------------------------------------
sc01() {
  local id="SC-01 阶段顺序"
  if grep -q 'reframe.*plan.*ticket.*build.*review.*verify.*retro' "$ROOT/SKILL.md"; then
    pass "$id"
  else
    fail "$id" "SKILL.md 缺少完整阶段顺序"
  fi
}

# ---------------------------------------------------------------------------
# SC-02: review/verify 分离 — 两个 flow 文件存在 + 各含 ## Gate
# ---------------------------------------------------------------------------
sc02() {
  local id="SC-02 review/verify 分离"
  local ok=true
  [ -f "$ROOT/flows/review.md" ] || ok=false
  [ -f "$ROOT/flows/verify.md" ] || ok=false
  if $ok; then
    grep -q '## Gate' "$ROOT/flows/review.md" || ok=false
    grep -q '## Gate' "$ROOT/flows/verify.md" || ok=false
  fi
  if $ok; then
    pass "$id"
  else
    fail "$id" "flows/review.md 或 flows/verify.md 缺失或缺少 ## Gate"
  fi
}

# ---------------------------------------------------------------------------
# SC-03: blocked 是一等结果
# ---------------------------------------------------------------------------
sc03() {
  local id="SC-03 blocked 一等结果"
  local ok=true
  grep -q 'blocked' "$ROOT/SKILL.md" || ok=false
  grep -q 'blocked' "$ROOT/flows/phase-order.md" 2>/dev/null || ok=false
  if $ok; then
    pass "$id"
  else
    fail "$id" "SKILL.md 或 flows/phase-order.md 缺少 blocked 相关表述"
  fi
}

# ---------------------------------------------------------------------------
# SC-04: gate-rubric 存在
# ---------------------------------------------------------------------------
sc04() {
  local id="SC-04 gate-rubric 存在"
  if [ -f "$ROOT/references/gate-rubric.md" ]; then
    pass "$id"
  else
    fail "$id" "references/gate-rubric.md 不存在"
  fi
}

# ---------------------------------------------------------------------------
# SC-05: source-system-mapping 存在
# ---------------------------------------------------------------------------
sc05() {
  local id="SC-05 source-system-mapping 存在"
  if [ -f "$ROOT/references/source-system-mapping.md" ]; then
    pass "$id"
  else
    fail "$id" "references/source-system-mapping.md 不存在"
  fi
}

# ---------------------------------------------------------------------------
# SC-06: run-state 标记为可选
# ---------------------------------------------------------------------------
sc06() {
  local id="SC-06 run-state 可选"
  if grep -q '可选' "$ROOT/templates/run-state.md" 2>/dev/null; then
    pass "$id"
  else
    fail "$id" "templates/run-state.md 缺少 '可选' 标记"
  fi
}

# ---------------------------------------------------------------------------
# SC-07: run-state 未进 frontmatter — 所有 .md 文件的 frontmatter 无 run_state
# ---------------------------------------------------------------------------
sc07() {
  local id="SC-07 run-state 未进 frontmatter"
  local found=""
  for dir in flows templates references; do
    local matches
    matches=$(find "$ROOT/$dir" -name '*.md' -exec \
      awk '/^---$/{fm++} fm==1 && /run.state/{print FILENAME; exit}' {} \; 2>/dev/null || true)
    if [ -n "$matches" ]; then
      found="$found $matches"
    fi
  done
  if [ -z "$found" ]; then
    pass "$id"
  else
    fail "$id" "以下文件 frontmatter 含 run-state: $found"
  fi
}

# ---------------------------------------------------------------------------
# SC-08: review 含结构化审查项（Scope 对照 / Plan 一致性 / 隐式默认搜索）
# ---------------------------------------------------------------------------
sc08() {
  local id="SC-08 review 结构化审查项"
  local ok=true
  grep -q 'Scope 对照' "$ROOT/flows/review.md" 2>/dev/null || ok=false
  grep -q 'Plan 一致性' "$ROOT/flows/review.md" 2>/dev/null || ok=false
  grep -q '隐式默认搜索' "$ROOT/flows/review.md" 2>/dev/null || ok=false
  if $ok; then
    pass "$id"
  else
    fail "$id" "flows/review.md 缺少结构化审查项"
  fi
}

# ---------------------------------------------------------------------------
# SC-09: INSTALL.md 存在
# ---------------------------------------------------------------------------
sc09() {
  local id="SC-09 INSTALL.md 存在"
  if [ -f "$ROOT/INSTALL.md" ]; then
    pass "$id"
  else
    fail "$id" "INSTALL.md 不存在"
  fi
}

# ---------------------------------------------------------------------------
# SC-10: 宿主模板存在且显式引用 skill 触发方式
# ---------------------------------------------------------------------------
sc10() {
  local id="SC-10 宿主模板"
  local ok=true
  [ -f "$ROOT/host-templates/AGENTS.md" ] || ok=false
  [ -f "$ROOT/host-templates/CLAUDE.md" ] || ok=false
  if $ok; then
    grep -q '\$convergent-dev-flow' "$ROOT/host-templates/AGENTS.md" || ok=false
    grep -q '/convergent-dev-flow' "$ROOT/host-templates/CLAUDE.md" || ok=false
  fi
  if $ok; then
    pass "$id"
  else
    fail "$id" "host-templates/AGENTS.md 或 host-templates/CLAUDE.md 缺失，或未显式引用 skill 触发方式"
  fi
}

# ---------------------------------------------------------------------------
# SC-11: README 安装节是 agent-oriented prompt，并指向 INSTALL.md
# ---------------------------------------------------------------------------
sc11() {
  local id="SC-11 README 安装 prompt"
  local ok=true
  grep -q 'Fetch and follow instructions from https://raw.githubusercontent.com/bigwhite37/harness_skills/refs/heads/main/INSTALL.md' "$ROOT/README.md" || ok=false
  grep -q 'Codex' "$ROOT/README.md" || ok=false
  grep -q 'Claude Code' "$ROOT/README.md" || ok=false
  if $ok; then
    pass "$id"
  else
    fail "$id" "README.md 缺少面向 agent 的安装 prompt，或未同时覆盖 Codex / Claude Code"
  fi
}

# ---------------------------------------------------------------------------
# SC-12: README / INSTALL 的最小安装校验覆盖 3 个 docs 文件
# ---------------------------------------------------------------------------
sc12() {
  local id="SC-12 安装校验覆盖 docs"
  local ok=true
  for f in \
    '.agents/skills/convergent-dev-flow/docs/usage.md' \
    '.claude/skills/convergent-dev-flow/docs/usage.md' \
    '.agents/skills/convergent-dev-flow/docs/self-check.md' \
    '.claude/skills/convergent-dev-flow/docs/self-check.md' \
    '.agents/skills/convergent-dev-flow/docs/acceptance.md' \
    '.claude/skills/convergent-dev-flow/docs/acceptance.md'
  do
    grep -q "$f" "$ROOT/README.md" || ok=false
    grep -q "$f" "$ROOT/INSTALL.md" || ok=false
  done
  if $ok; then
    pass "$id"
  else
    fail "$id" "README.md 或 INSTALL.md 的最小安装校验未完整覆盖 usage/self-check/acceptance 三个 docs 文件"
  fi
}

# ---------------------------------------------------------------------------
# SC-13: 安装后的 docs/usage.md 不引用未安装的相对路径 INSTALL.md
# ---------------------------------------------------------------------------
sc13() {
  local id="SC-13 usage 无死链接到 INSTALL"
  if grep -q '\.\./INSTALL\.md' "$ROOT/docs/usage.md"; then
    fail "$id" "docs/usage.md 仍引用不会被安装进宿主 skill 包的 ../INSTALL.md"
  else
    pass "$id"
  fi
}

# ---------------------------------------------------------------------------
# SC-14: README / INSTALL 区分 bootstrap install 与 update 路径
# ---------------------------------------------------------------------------
sc14() {
  local id="SC-14 bootstrap/update 分离"
  local ok=true
  grep -q 'bootstrap' "$ROOT/README.md" || ok=false
  grep -q 'update' "$ROOT/README.md" || ok=false
  grep -q 'bootstrap' "$ROOT/INSTALL.md" || ok=false
  grep -q 'update' "$ROOT/INSTALL.md" || ok=false
  grep -q -E '保留.*AGENTS\.md|保留.*CLAUDE\.md|preserve.*AGENTS\.md|preserve.*CLAUDE\.md' "$ROOT/INSTALL.md" || ok=false
  grep -q 'convergent-dev-flow bootstrap-template: AGENTS' "$ROOT/host-templates/AGENTS.md" || ok=false
  grep -q 'convergent-dev-flow bootstrap-template: CLAUDE' "$ROOT/host-templates/CLAUDE.md" || ok=false
  grep -q 'convergent-dev-flow bootstrap-template: AGENTS' "$ROOT/INSTALL.md" || ok=false
  grep -q 'convergent-dev-flow bootstrap-template: CLAUDE' "$ROOT/INSTALL.md" || ok=false
  if $ok; then
    pass "$id"
  else
    fail "$id" "README.md / INSTALL.md / host-templates 未清晰定义 bootstrap/update 路径与 bootstrap marker 校验"
  fi
}

# ---------------------------------------------------------------------------
# SC-15: README / INSTALL 支持 same-ref / pinned install
# ---------------------------------------------------------------------------
sc15() {
  local id="SC-15 ref-aware install"
  local ok=true
  grep -q '<REF>' "$ROOT/README.md" || ok=false
  grep -q -E 'same ref|同一.*ref|branch/tag/commit' "$ROOT/README.md" || ok=false
  grep -q -E 'same ref|同一.*ref|branch/tag/commit' "$ROOT/INSTALL.md" || ok=false
  grep -q 'SOURCE_REF' "$ROOT/INSTALL.md" || ok=false
  if $ok; then
    pass "$id"
  else
    fail "$id" "README.md 或 INSTALL.md 仍未提供 same-ref / pinned install 语义，或未要求记录 SOURCE_REF"
  fi
}

# ---------------------------------------------------------------------------
# SC-16: Tier 2 数量在 README / Makefile / script 中一致
# ---------------------------------------------------------------------------
sc16() {
  local id="SC-16 Tier 2 数量一致"
  local ok=true
  local defined_count
  local invoked_count
  defined_count=$(rg -n '^sc[0-9]+\(\)' "$ROOT/scripts/tier2_selfcheck.sh" | wc -l | tr -d ' ')
  invoked_count=$(awk '
    /^sc01$/,/^sc16$/ {
      if ($0 ~ /^sc[0-9]+$/) count++
    }
    END { print count + 0 }
  ' "$ROOT/scripts/tier2_selfcheck.sh")
  grep -q "Tier 2 | \`make tier2\` | ${defined_count} 个自检断言" "$ROOT/README.md" || ok=false
  grep -q "Tier 2: 自检断言（${defined_count} 个 SC）" "$ROOT/Makefile" || ok=false
  [ "$defined_count" = "$invoked_count" ] || ok=false
  grep -q 'AGENTS_BEFORE_SHA' "$ROOT/INSTALL.md" || ok=false
  grep -q 'AGENTS_AFTER_SHA' "$ROOT/INSTALL.md" || ok=false
  grep -q 'CLAUDE_BEFORE_SHA' "$ROOT/INSTALL.md" || ok=false
  grep -q 'CLAUDE_AFTER_SHA' "$ROOT/INSTALL.md" || ok=false
  if $ok; then
    pass "$id"
  else
    fail "$id" "Tier 2 数量未真实对齐，或 INSTALL.md 缺少 update preservation evidence 字段"
  fi
}

# ---------------------------------------------------------------------------
# 执行所有断言
# ---------------------------------------------------------------------------
echo "=== Tier 2 自检断言 (docs/self-check.md) ==="
echo ""

sc01
sc02
sc03
sc04
sc05
sc06
sc07
sc08
sc09
sc10
sc11
sc12
sc13
sc14
sc15
sc16

echo ""
echo "=== 汇总: $PASS_COUNT PASS / $FAIL_COUNT FAIL (共 $((PASS_COUNT + FAIL_COUNT))) ==="

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
exit 0
