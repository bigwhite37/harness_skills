# 阶段规则

本文件将阶段行为集中起来，避免技能依赖零散解释。

## 固定顺序

`reframe -> plan -> ticket -> build -> review -> verify -> retro`

## 强制属性

- 每个阶段都必须有显式输入、输出、gate 和失败去向。
- 没有上一阶段显式输出，下一阶段不得开始。
- 只允许通过已声明的阶段回退进行 rollback。
- `retro` 是终止阶段。

## 允许的回退

> 完整回退路径见 flows/phase-order.md

## 禁止动作

> 禁止动作见 flows/phase-order.md

## 横切纪律

所有阶段共享以下横切约束：

- 每个阶段的 go / no-go 判断遵循 `references/gate-rubric.md` 统一准绳。
- 每个阶段都受 `guards/` 目录中相关守卫的 veto 约束。
- 任何阶段在 guard 或 gate 未通过时，都不得继续推进。
