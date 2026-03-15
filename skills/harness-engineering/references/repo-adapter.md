# Repo Adapter

这个文档定义通用 `harness-engineering` 在不同仓库中如何做最小适配。

## 目标

把 skill 中“与具体仓库有关的事实”集中到这一层，而不是散落在主 `SKILL.md` 里。

## 建议的发现入口

优先假设目标仓库存在下列 truth surface；如果不存在，再按仓库实际结构调整：

- `docs/tasks/_STATUS.md` 或等价状态页
- `docs/reports/CONTEXT_PACK.md` 或等价上下文页
- 当前最相关的 `latest` / `report` / `handover` 页面
- 用户直接点名的 ticket / spec / plan / report 文件

## 分层发现

### Tier-1

仅读取：

- 状态页
- context pack
- 当前最相关的 latest truth page
- 用户直接点名的文件

### Tier-2

只有当 Tier-1 无法稳定判断 `phase / lane / high_impact` 时，才进一步读取：

- `AGENTS.md`
- report index
- exec-plan index
- 当前 phase 的 handover / campaign / exit / latest
- 与请求直接相关的 spec / open questions

## 默认路径变量

如果仓库没有额外说明，可以先按以下默认值理解：

- `DOCS_DIR=docs`
- `TASKS_DIR=docs/tasks`
- `REPORTS_DIR=docs/reports`
- `SPEC_DIR=docs/spec`
- `PLANS_DIR=docs/exec-plans`

但这些只是默认值，不是强约束。

## 适配规则

- 不要硬编码仓库名
- 不要假设一定有 phase 编号
- 不要假设 latest / exit / campaign 命名固定
- 如果无法确认 phase，写 `phase_guess: unknown`
- 如果无法确认 lane，写 `lane_guess: unknown`

## 最低工件集合

如果请求需要真正落成一轮 repo-native planning，通常至少要考虑：

- 一个 `EP`
- 一个或多个 `Ticket`
- 状态页更新计划
- `Context Pack` 更新计划
- 若 truth surface 变化，则补对应的 latest/report 更新计划
