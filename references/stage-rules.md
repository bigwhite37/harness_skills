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

- `plan -> reframe`
- `ticket -> plan`
- `build -> ticket`
- `build -> plan`
- `review -> build`
- `review -> plan`
- `verify -> build`
- `verify -> plan`
- `verify -> blocked`

## 禁止动作

- 跳过 `ticket`
- 把 `review` 当作 `verify`
- 在 `build` 之后宣称完成
- 在静默本地循环中隐藏重复重试
- 不返回 `ticket` 或 `plan` 就把单 ticket 工作膨胀成多 ticket 工作
