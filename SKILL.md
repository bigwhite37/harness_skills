---
name: convergent-dev-flow
description: 用于需要通过 reframe、plan、ticket、build、review、verify 与 retro 固定阶段推进收敛式开发任务的场景。
---

# Convergent Dev Flow 技能

这是一个系统级工作流技能。它是流程治理器，不是产品决策器、通用编码助手，也不是高自治智能体。

本仓库在根目录存放规范源码包。下游应将该包复制到宿主专用的技能目录中，而不是在本仓库中保留消费端镜像目录。

这个技能只适用于必须经过固定阶段机推进的单个开发任务：

`reframe -> plan -> ticket -> build -> review -> verify -> retro`

## 运行时宪法

1. 本技能是工作流治理器，不是产品决策器。
2. 严格按照阶段顺序执行：reframe → plan → ticket → build → review → verify → retro。
3. 绝不跳阶段。绝不把 `review` 和 `verify` 合并。
4. 优先快速失败，不做投机推进。
5. 禁止静默回退。若 tool、文件、环境或检查不可用，必须明确说出。
6. 禁止隐式默认。任何重要行为选择都必须锚定在用户请求、仓库证据，或 `reframe` 中已声明的显式假设上。
7. 在 `reframe` 锁定范围，在 `plan` 锁定验证契约。任一项发生变化，都必须返回对应阶段。
8. 先有 `ticket`，再做 `build`。没有活动 ticket 不得开始实现。
9. 同一时间只允许一个活动 ticket。
10. 只构建满足活动 ticket 的最小变更。禁止顺手加料。
11. `review` 必须是对抗式的。它要主动寻找范围漂移、隐藏回退、不必要复杂度、回归风险和缺失测试。
12. `verify` 依赖证据，不依赖信心。没有证据时，状态是未知，不是完成。
13. 除非每条验收标准都有直接证据，或被明确标记为 `blocked` / `unverified`，否则不得宣称成功。
14. 如果同一 ticket 在 `review` 或 `verify` 中反复失败，应停止局部打补丁并返回 `plan`。
15. `blocked` 是可接受结果，隐藏不确定性不是。
16. v1 中不得调用脚本、hooks、subagents、并行智能体、commit、PR 创建、部署或其他外部副作用流程。
17. 在产品工作期间，不得改写 `AGENTS.md`、`CLAUDE.md` 或这个技能本身。流程改进建议应记录到 `retro`。
18. 每次运行必须以 `retro` 结束。
19. [v1 扩展] handoff 是工作流结束后的摘要产物，不是第八个阶段。

## 宿主边界

- 永久生效的仓库规则应放在 `AGENTS.md` 或 `CLAUDE.md`，不要放进这个技能。
- 这个技能只负责按任务触发的工作流控制。
- gstack 提供阶段骨架和审查视角。
- superpowers 只在已获准阶段内提供低自由度执行辅助。
- harness engineering 负责 gate 纪律、证据纪律和失败处理的否决层。
- 三者的具体落地映射见 `references/source-system-mapping.md`。

## 分层加载策略

运行这个技能时按以下层次加载文件：

### 核心层（始终加载）

- `SKILL.md`
- `flows/phase-order.md`
- `references/gate-rubric.md`

### 阶段层（按当前阶段加载）

- `flows/{当前阶段}.md`
- `templates/{当前阶段}.md`（生成输出时）

### 守卫层（按阶段加载相关守卫）

- `guards/quick-fail.md`
- `guards/no-silent-fallback.md`
- `guards/no-implicit-defaults.md`
- `guards/evidence-required.md`
- `guards/phase-gate-discipline.md`
- `guards/controlled-scope.md`
- `guards/no-false-completion.md`
- `guards/retro-mandatory.md`

### 参考层（按需加载）

- `references/stage-rules.md`
- `references/anti-patterns.md`
- `references/boundary-rules.md`
- `references/source-system-mapping.md`

### 辅助模板（按需加载）

- `templates/blocked.md`
- `templates/handoff.md`
- `templates/run-state.md`（可选）

### 维护层（维护或验证时加载）

- `examples/small-bug/README.md`
- `examples/small-feature/README.md`
- `examples/safe-refactor/README.md`
- `examples/blocked-run/README.md`
- `examples/review-scope-drift/README.md`
- `examples/verify-no-evidence/README.md`
- `docs/usage.md`
- `docs/self-check.md`
- `docs/acceptance.md`
- `evals/trigger-cases.md`
- `evals/stage-gate-cases.md`
- `evals/regression-cases.md`

## 运行规则

每次运行开始时：

1. 识别当前所处阶段。
2. 检查上一阶段的输出是否存在且显式。
3. 检查当前阶段的 gate 是否满足。
4. 若不满足，停止并输出 `blocked`，或明确要求返回缺失的上一阶段。
5. 不要在隐藏假设下继续推进。

## 显式触发

- Codex：`$convergent-dev-flow`
- Claude Code：复制后使用 `/convergent-dev-flow`，并加上 `disable-model-invocation: true`

v1 不依赖隐式匹配。

## 允许的结束状态

- `verified`
- `blocked`
- `reframe-needed`

除这三种之外，任何其他状态在 v1 中都不合规。

## 术语表

- **gstack**：提供阶段骨架和角色化提问视角的来源系统。它决定"怎么分阶段想"，不决定产品方向。
- **superpowers**：提供低自由度执行增强的来源系统。只在已获准阶段和已激活 ticket 内提供受控执行能力。
- **harness engineering**：提供 gate、evidence、quick fail、blocked 与 retro 收敛纪律的来源系统。
- **gate**：每个阶段结束时的 go / no-go 检查点。只有 gate 通过才能进入下一阶段。
- **guard**：横切纪律规则，任何阶段都可能触发。guard 可以 veto 一个阶段的通过。
- **blocked**：合规的结束状态之一，表示因缺失条件或环境限制无法继续推进。
- **handoff**：工作流结束后的摘要产物，不是第八个阶段。
