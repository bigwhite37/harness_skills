# 反模式

这些是本技能必须抵抗的高频失败模式。

## Workflow 反模式

- 因为“任务很明显”而直接从 `build` 开始
- 因为工作很小而跳过 `ticket`
- 把 `review` 当作测试通过
- 把 `verify` 当作信心或目测检查
- 因为任务看起来简单就省略 `retro`

## Scope 反模式

- 把相邻清理折叠进当前活动 ticket
- 在一个 ticket 中混入多个风险
- 不经过阶段回退就膨胀成多 ticket 工作
- 以“局部清理”为名做 opportunistic refactor

## 证据反模式

- 用“应该可以”替代证据
- 强检查失败后，静默改用更弱检查
- 让验收点与证据脱钩
- 在关键项仍然只是推定状态时宣称 `verified`

## 控制反模式

- 让 superpowers 决定产品方向或范围
- 让 gstack 的角色提示覆盖用户意图
- 让 harness 输出与 gate / evidence 无关的架构偏好
- 在普通产品工作期间重写这个技能、`AGENTS.md` 或 `CLAUDE.md`
