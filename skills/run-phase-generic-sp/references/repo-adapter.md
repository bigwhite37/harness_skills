# Repo Adapter

这个文档定义 `run-phase-generic-sp` 如何适配不同仓库的执行入口。

## 目标

让 driver 依赖仓库 truth surface，而不是依赖固定命名。

## 建议入口

首次进入某个阶段时，优先寻找：

- 全局约束入口，例如 `AGENTS.md`
- 状态页，例如 `_STATUS`
- `CONTEXT_PACK` 或等价上下文页
- 当前阶段的 latest / handover / campaign / exit 页面
- 当前阶段的 ticket 列表

## 默认目录变量

如果仓库没有额外说明，可以先按下面的常见结构理解：

- `DOCS_DIR=docs`
- `TASKS_DIR=docs/tasks`
- `REPORTS_DIR=docs/reports`
- `PLANS_DIR=docs/exec-plans`

但这些不是强约束。

## 适配原则

- 不要硬编码 `PhaseN`
- 如果仓库使用 `milestone`、`release train`、`wave` 等概念，可等价映射为“当前阶段”
- 不要假设一定存在 `campaign / exit / handover`
- 如果某类 truth page 不存在，用仓库等价页面替代
- 如果阶段无法稳定识别，先返回 `invalid-phase-or-ticket`，不要猜
