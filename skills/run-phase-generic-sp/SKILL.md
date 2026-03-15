---
name: run-phase-generic-sp
description: Use when executing an existing phase or milestone ticket stream in order, rather than compiling new planning artifacts.
---

# Run Phase Generic

这是一个通用执行 driver，用来顺序推进某个仓库里“已经存在”的 phase / milestone / lane 工件。

它不是需求编译器；如果用户本意是新建 `EP / Ticket / Spec / Report`，应优先使用 `harness-engineering`。

先读：

- `references/repo-adapter.md`
- `references/completion-gate-contract.md`
- `references/exit-verdict-and-stop-cause.md`
- `references/anti-loop-observation-contract.md`
- `references/context-economy-and-delta-refresh.md`

## 目标

把 repo-local 的 phase driver 抽成通用流程。默认负责：

1. 识别当前要执行的 phase / milestone / lane
2. 找到对应 tickets / latest / campaign / handover / exit truth
3. 从首个未完成票或用户显式指定起点继续推进
4. 对每张票执行 `Plan -> Implement -> Verify -> Record`
5. 在关键退出点产出稳定的 `exit_verdict`

## 何时使用

- 用户要继续执行已有 phase / milestone / lane
- 仓库里已经有 tickets 和对应 truth 页面
- 用户要求“从某张票继续”、“把当前 phase 跑下去”
- 当前任务重点是实现与验证，而不是重新组织 planning artifacts

## 何时不要使用

- 用户要新建或重组 artifacts
- 用户要 kickoff 一个新 phase
- 用户只是要做 correctness / verify
- 用户显式点名 phase-specific wrapper，且该 wrapper 足以覆盖当前请求

## 输入解析

优先从用户输入里提取：

- `PhaseN`、milestone 名、lane 名，或仓库自己的阶段标识
- 可选 `START: T-xxx`
- 可选 `implementation lane`
- 可选目标关键词

如果阶段标识无法稳定判断，允许先问一个简短问题；如果仓库事实足够，也可以从 `_STATUS` 与最新 truth 中推断。

## 最小发现

首次进入当前阶段时，默认读取：

- repo 的全局约束入口，例如 `AGENTS.md`
- 状态页，例如 `_STATUS`
- 上下文页，例如 `CONTEXT_PACK`
- 当前阶段最相关的 latest / exit / handover
- 当前 ticket 或本阶段 ticket 列表

具体路径不要硬编码，按 `references/repo-adapter.md` 适配。

## 工作流

1. 确定执行范围与起点
2. 判断当前票是 `planning-only` 还是 `implementation-required`
3. 对当前票执行 `Plan -> Implement -> Verify -> Record`
4. 只同步本票真正 touched 的 truth surface
5. 产出 `exit_verdict`
6. 若还可继续，则进入下一票；若被阻塞，则给出清晰 stop cause

## Ticket Type 规则

### Planning-only

只有当票据目标明确停在以下范围时，才允许 docs-only 收口：

- kickoff / baseline freeze
- contract / spec formalization
- report / latest / context sync
- config skeleton
- 未接线 scaffold

### Implementation-required

若票据目标或验收涉及以下任一项，则必须视为 `implementation-required`：

- runtime behavior 变化
- 策略、分配器、构造器、执行路径变化
- DTO / 导出 / truth materialization
- 脚本、后端、前端等真实运行路径变化
- gate 从合同变成真实运行时产物

对 `implementation-required` 票：

- docs-only completion 无效
- 必须有代码或运行路径层面的真实改动
- 必须有匹配的验证证据

## Auto-Continuation 规则

如果用户显式要求：

- `implementation lane`
- `plan 完成后继续实现`
- 一次性把当前阶段往下跑

那么 driver 不应在“planning 前置票完成但实现票仍缺失”时误判完成。

此时应：

1. 完成当前 planning 前置票
2. 如果缺少实现票，返回 `needs-new-implementation-lane`
3. 明确下一步应回到 `harness-engineering` 或 repo-local ticket generator 追加实现票

## Completion Gate

任何票在宣布完成前，都必须经过 completion gate。具体字段与判定见：

- `references/completion-gate-contract.md`

核心要求只有一条：不要把 `implementation-required` 票误收成 docs-only 完成。

## Exit Verdict

driver 在结束当前票或当前轮时，必须产出结构化 verdict。固定集合见：

- `references/exit-verdict-and-stop-cause.md`

默认先翻译成人话给用户，不要直接把内部 contract 标题墙铺给用户。

## Anti-Loop

如果出现同一文件反复返工，或同一命令重复失败且原因不变，应触发轻量 anti-loop，见：

- `references/anti-loop-observation-contract.md`

## 输出节制

对用户的默认输出，只需回答：

1. 这轮做了什么
2. 结果是什么
3. 还剩什么
4. 下一步是什么

不要每票都重讲整条 phase 历史。

## 最低验证

如果目标仓库没有更强约束，默认至少包括：

- `git diff --check`
- 仓库本地的 docs / lint / format 检查

更严格的命令由 repo adapter 和当前票类型决定。
