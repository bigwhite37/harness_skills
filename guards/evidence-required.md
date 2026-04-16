# `evidence-required` 守卫

## 触发时机

在任何完成宣称、通过判定或 `verified` handoff 之前，触发此守卫。

## 必需响应

- 将每条验收标准映射到直接证据
- 缺失项必须标记为 `unverified` 或 `blocked`
- 结论表述必须与证据保持一致

## 阻断规则

没有证据，就不能宣称完成。
