---
name: harness-engineering
description: Use when the user wants to compile a natural-language request into repo-native EP / ticket / spec / report / context artifacts.
---

# Harness Engineering

这是一个通用的“需求编译器” skill，不是 phase 执行器。

它的目标是把自然语言需求，编译成某个仓库内部可继续执行的工件，例如：

- `EP`
- `Ticket`
- `Spec`
- `Report`
- `Context / Latest / Status` 同步项

先读：

- `references/trigger-boundary.md`
- `references/repo-adapter.md`
- `references/context-economy.md`
- `references/compact-context-packet-contract.md`
- `references/output-contract-template.md`

## 何时使用

- 用户明确说要把自由需求整理成 repo-native 工件
- 用户要新增一条 lane，或补 `contract + implementation` 两层工件
- 用户不是要“继续跑已有 tickets”，而是要先把需求编排清楚
- 当前请求涉及 phase / lane / spec / report / latest 的重新组织

## 何时不要使用

- 用户只是要继续执行已有 tickets
- 用户只是要启动某个 phase kickoff
- 用户只是要跑 verify / correctness
- 用户已经明确点名某个 phase-specific runner 或 wrapper

这些情况应优先交给目标仓库已有的执行型 skills。

## 核心职责

在任意仓库里，`harness-engineering` 只做五件事：

1. 基于 repo adapter 找到当前仓库的 truth surface
2. 先产出一份 compact `Context Packet`
3. 把需求分类成 `request_type / lane / phase / high_impact`
4. 生成最小必要的工件计划
5. 把后续动作交给执行型 skill，而不是自己把 phase 跑完

## 工件最小化原则

- 默认一个 lane 只建一个 `EP`
- `contract lane` 与 `implementation lane` 优先放在同一个 `EP` 中
- 只有当 implementation 明显跨子域、跨多人、跨多轮时，才拆第二个 `EP`
- 如果当前只是 planning-only，默认不要为了“完整”生成一大串 report

## 高影响语义规则

以下主题默认视为高影响，不应只靠随口建议直接落实现：

- protocol / budget / trial semantics
- canonical DTO / truth surface / latest meaning
- storage fact model
- degraded vs formal runtime semantics
- operator truth / fallback contract
- strategy / allocator / constructor / order path 的运行时行为变化

遇到这些主题时，必须：

- 显式给出 `high_impact: true`
- 先给出合同化/工件化结果
- 写清楚 verify plan 与 propagation plan

## Implementation Lane 规则

当以下任一条件成立时，必须明确输出 `implementation_lane_required: true`：

- 用户显式要求“做完 planning 后继续实现”
- 需求本质上要求 runtime 行为变化
- 如果只生成 planning artifacts，会导致执行 driver 卡住

不要产出一种“看似完成 planning，但其实无法继续执行”的半成品票组。

## 输出规则

最终输出必须满足：

- 先给一段人话摘要
- 再给稳定的机器可读骨架
- 字段名尽量固定，方便评估器抓取
- 不重复抄写已经出现在 `Context Packet` 里的大段背景

具体字段见：

- `references/compact-context-packet-contract.md`
- `references/output-contract-template.md`

## Verify 规则

每次输出都必须明确：

- 这轮是 `planning-only` 还是 `plan+implementation`
- 有哪些 blocking checks
- 下一步命令是什么
- 需要同步哪些 `latest / report / context`

最小验证集合由目标仓库决定；如果仓库没有更强约束，默认至少包括：

- `git diff --check`
- 仓库自己的 docs structure / lint / format 检查

## 通用化边界

这个 skill 本身不应硬编码：

- 固定仓库名
- 固定 `phase<n>` 规则
- 固定 `docs/tasks/_STATUS.md` 之外唯一合法入口
- 固定某个 repo 的 report / latest / exit 命名

这些都应通过 `repo-adapter` 和当前仓库 truth 结构来适配。
