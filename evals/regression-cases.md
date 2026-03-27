# 回归用例

每次编辑这个技能后，都应用这些结构化检查做回归。

## 结构化测试用例

### RC-01: 快速失败措辞削弱

- **id**: RC-01
- **target_files**: SKILL.md, guards/quick-fail.md
- **assertion**: "快速失败"作为显式停止规则存在，措辞未被软化
- **check_method**: 文本搜索 — 确认 SKILL.md 宪法第 4 条和 guards/quick-fail.md 中"快速失败"或等价表述存在
- **severity**: critical

### RC-02: 静默回退变得可接受

- **id**: RC-02
- **target_files**: SKILL.md, guards/no-silent-fallback.md
- **assertion**: 静默回退仍被明确禁止
- **check_method**: 文本搜索 — 确认"禁止静默回退"或等价表述存在
- **severity**: critical

### RC-03: 隐式默认重新混入

- **id**: RC-03
- **target_files**: SKILL.md, guards/no-implicit-defaults.md
- **assertion**: 隐式默认仍被明确禁止
- **check_method**: 文本搜索 — 确认"禁止隐式默认"或等价表述存在
- **severity**: critical

### RC-04: 无证据完成性表述

- **id**: RC-04
- **target_files**: SKILL.md, guards/evidence-required.md, flows/verify.md
- **assertion**: 不存在无证据宣称完成的路径
- **check_method**: 文本搜索 — 确认证据要求存在，verify 仍要求"验收点到证据"映射
- **severity**: critical

### RC-05: ticket 可被跳过

- **id**: RC-05
- **target_files**: SKILL.md, flows/phase-order.md
- **assertion**: ticket 阶段不可被跳过，build 前必须有活动 ticket
- **check_method**: 文本搜索 — 确认宪法第 8 条和 phase-order 禁止动作中相关规则存在
- **severity**: critical

### RC-06: review 和 verify 混合

- **id**: RC-06
- **target_files**: SKILL.md, flows/review.md, flows/verify.md
- **assertion**: review 和 verify 是独立阶段，不可合并或互相替代
- **check_method**: 文本搜索 — 确认宪法第 3 条存在；review 和 verify 有独立的 gate
- **severity**: critical

### RC-07: 防 phases/ 目录回潮

- **id**: RC-07
- **target_files**: 仓库目录结构
- **assertion**: 不存在 phases/ 目录
- **check_method**: 目录检查 — `ls phases/` 应返回"不存在"
- **severity**: high

### RC-08: 防 small-fix-track 引入

- **id**: RC-08
- **target_files**: SKILL.md, flows/, references/
- **assertion**: 不存在 small-fix-track 或等价的快速通道概念
- **check_method**: 全文搜索 — grep "small-fix" 或 "fast-track" 或 "quick-path" 应无结果
- **severity**: high

### RC-09: 防 context: frontmatter 越权

- **id**: RC-09
- **target_files**: flows/*.md, templates/*.md, references/*.md
- **assertion**: 没有文件的 YAML frontmatter 中包含 context: 字段
- **check_method**: 全文搜索 — grep "^context:" 在所有 .md 文件的 frontmatter 中应无结果
- **severity**: high

### RC-10: 四类示例完整性

- **id**: RC-10
- **target_files**: examples/
- **assertion**: 小型缺陷、小型功能、安全重构、阻塞运行四类示例均存在
- **check_method**: 目录检查 — examples/small-bug/, examples/small-feature/, examples/safe-refactor/, examples/blocked-run/ 均存在
- **severity**: high

### RC-11: gate rubric 存在性

- **id**: RC-11
- **target_files**: references/gate-rubric.md
- **assertion**: 共享 gate rubric 文件存在且包含通用 go 问题和各阶段 go 问题
- **check_method**: 文件存在检查 + 文本搜索"通用 Go 问题"和"各阶段 Go 问题"
- **severity**: high

### RC-12: 自治性边界

- **id**: RC-12
- **target_files**: SKILL.md
- **assertion**: v1 不引入 scripts、hooks、subagents、并行智能体、commit、PR 创建、部署或其他外部副作用
- **check_method**: 文本搜索 — 确认宪法第 16 条存在且措辞未被削弱
- **severity**: critical

## 预期结果

只要任一回归检查失败，都应将这个技能视为不合规，直到措辞或结构重新收紧。
