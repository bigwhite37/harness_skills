# 重复热点：convergent-dev-flow

## 重复规则处理表

| 重复规则 | 当前位置 | 保留位置 | 其他位置改为 |
|---|---|---|---|
| 来源视角（3 bullets） | 7 个 flows | references/source-system-mapping.md | 1 行引用 |
| 来源约束（3 bullets） | 9 个 templates | references/boundary-rules.md | 1 行引用 |
| 允许回退列表 | phase-order + stage-rules | flows/phase-order.md | stage-rules 改引用 |
| 禁止动作列表 | phase-order + stage-rules | flows/phase-order.md | stage-rules 改引用 |
| 来源系统体现 | 6 个 examples | 保留（示例需独立可读） | 不改 |

## 详细说明

### 来源视角重复

7 个阶段 flow 文件（reframe、plan、ticket、build、review、verify、retro）各包含一个 `## 来源视角` 节，列出 gstack、superpowers、harness engineering 三个来源系统在该阶段的职责。这些内容的规范来源是 `references/source-system-mapping.md`，flow 文件中应改为单行引用。

预计减少：~42-56 行（每处 6-8 行 × 7 文件）

### 来源约束重复

9 个 template 文件（7 个阶段 + blocked + handoff）各包含一个 `## 来源约束` 节。这些约束的规范来源是 `references/boundary-rules.md`，template 文件中应改为单行引用。

预计减少：~18-27 行（每处 2-3 行 × 9 文件）

### 允许回退与禁止动作重复

`references/stage-rules.md` 与 `flows/phase-order.md` 之间存在回退路径和禁止动作的重复。规范位置为 `flows/phase-order.md`，`stage-rules.md` 应改为引用。

预计减少：~14 行

### 保留不改的重复

示例文件中的"来源系统体现"节保留不改。示例需要独立可读，读者不应在阅读示例时还需要跳转到参考文件。
