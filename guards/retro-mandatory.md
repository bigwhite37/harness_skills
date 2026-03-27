# `retro-mandatory` 守卫

## 触发时机

只要某次运行试图在未完成 `retro` 输出的情况下终止，就触发此守卫。

## 必需响应

- 指出 `retro` 尚未完成
- 拒绝终止运行
- 要求补完 `retro` 输出后再结束

## 阻断规则

不得因为"任务已经完成"或"没什么可复盘的"而跳过 `retro`。每次运行必须以 `retro` 结束，无论结果是 `verified`、`blocked` 还是 `reframe-needed`。
