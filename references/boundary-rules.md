# 边界规则

使用本文件来确保三个来源系统各守其位。

## Gstack 边界

允许：

- 通过显式调用 `/office-hours`、`/plan-ceo-review`、`/plan-eng-review`、`/review`、`/retro` 提供阶段骨架与角色式提问视角
- 在验收确实依赖真实 UI / 浏览器用户流时，通过 `/qa` 或 `/qa-only` 提供真实浏览器验证

禁止：

- 产品方向决策
- 新阶段发明
- 用角色提示当权威来扩范围
- 在本技能未声明适用时，擅自把 `/qa` 扩张成普适验证替代品

## Superpowers 边界

允许：

- `test-driven-development` 在 `build` 前约束实现起点
- `systematic-debugging` 在故障、测试失败或意外行为出现时约束排障
- `verification-before-completion` 在 `verify` 前约束完成声明
- 文件操作、任务组织、上下文处理，以及已获准阶段中的执行辅助

禁止：

- 需求取舍
- 范围扩张
- `plan` 改写
- 以效率为名绕过 `review` 或 `verify`
- 在没有失败信号时把 `systematic-debugging` 变成拖延性 ritual

## Harness 边界

允许：

- Gate 执行
- 证据约束
- quick-fail 决策
- `blocked` 决策
- `retro` 纪律

禁止：

- 与 gate 或 evidence 无关的架构偏好输出
- 产品优先级裁决
- 静默把工作流治理器变成自治智能体

> 来源系统的按阶段职责映射见 references/source-system-mapping.md
