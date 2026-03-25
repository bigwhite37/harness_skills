# 阶段顺序

工作流顺序是固定的：

`reframe -> plan -> ticket -> build -> review -> verify -> retro`

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

`retro` 是终止阶段，不向前也不向后流转。

## 禁止动作

- 在没有活动 ticket 之前，不得进入 `build`。
- `build` 后不得直接宣称完成。
- 不得把 `review` 当成 `verify`。
- 不得在内部静默重试并反复循环，却不声明阶段回退。

## 结束状态

- `verified`
- `blocked`
- `reframe-needed`

如果一次运行无法诚实地落到这些状态之一，则该工作流仍未完成。
