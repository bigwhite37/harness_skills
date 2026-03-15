# Harness Engineering 触发边界

## 应该使用

以下场景属于 `harness-engineering`：

- 用户要把自由需求编译成 repo-native 工件
- 用户要新建或补充 `EP / Ticket / Spec / Report / Context`
- 用户要在当前 phase 里补一条新 lane
- 用户要把“想法/方向”整理成可执行的 repo 工件

## 不应该使用

以下场景不应由 `harness-engineering` 处理：

- 用户只是要继续执行已有 tickets
- 用户只是要启动 phase kickoff
- 用户只是要跑 correctness / verify
- 用户已经明确点名 phase-specific 执行 wrapper

## 歧义处理

如果请求同时包含：

- `phase / lane / latest / blocker` 等背景词
- 但本质是在要求“重新组织工件”

仍应判定为 `harness-engineering`。

如果请求本质是在说：

- `继续`
- `从 T-xxx 开始`
- `把已有 phase 跑下去`

则应判定为执行请求，而不是需求编译请求。
