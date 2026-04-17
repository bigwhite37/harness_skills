# 来源系统映射

这个技能不是凭空定义的流程集合。它由三套来源系统按固定职责拼合而成：

- `gstack`：提供阶段骨架和角色化提问视角。
- `superpowers`：提供低自由度执行增强。
- `harness engineering`：提供 gate、evidence、quick fail、blocked 与 retro 的收敛纪律。

三者都不能越权。这个文件的作用是明确：哪些部分吸收了来源系统，哪些部分没有。

## `gstack` 的落地位置

`gstack` 在这个技能里不是抽象来源，而是被显式调用的外部技能集；它决定“怎么分阶段想”，不决定“要做什么产品方向”。

- `reframe`
  - 必须显式调用 `/office-hours` 做问题澄清与约束识别。
  - 用于把模糊任务压缩成单一目标、成功标准、非目标和关键假设。
- `plan`
  - 必须显式调用 `/plan-ceo-review` 做价值、范围、优先级检查。
  - 必须显式调用 `/plan-eng-review` 做技术路径、依赖、风险、复杂度检查。
- `review`
  - 必须显式调用 `/review` 做对抗式工程审查。
- `verify`
  - 若验收涉及真实 UI / 浏览器用户流，必须显式调用 `/qa` 或 `/qa-only`。
  - 不涉及浏览器用户流时，不强制调用 gstack QA。
- `retro`
  - 必须显式调用 `/retro` 做流程学习。

`gstack` 在这个技能中不能做的事：

- 代替用户做需求取舍。
- 新增第八个阶段或改写阶段顺序。
- 把角色化提问升级成产品决策授权。

## `superpowers` 的落地位置

`superpowers` 是手脚，不是方向盘。它在这个技能里也不是抽象来源，而是被显式调用的外部技能集；它只在“阶段已经过 gate”且“ticket 已经激活”的范围内提供受控执行能力。

允许吸收的能力：

- 文件操作
- 任务拆解
- 多步骤执行
- 上下文组织

按阶段的受控使用方式：

- `reframe`
  - 允许做仓库探索、上下文归拢、问题清单整理。
  - 不允许补默认需求方向。
- `plan`
  - 允许整理探索结果、备选方案、风险和验证契约。
  - 不允许自行改写已通过的 `reframe`。
- `ticket`
  - 允许把已通过的 `plan` 压缩为小 ticket。
  - 不允许开启并行 ticket 或顺手拆出隐藏 scope。
- `build`
  - 必须显式调用 `test-driven-development` 再开始实现。
  - 允许在活动 ticket 内做文件编辑、命令执行和多步骤实现。
  - 不允许越过 ticket 边界顺手扩改。
- `review`
  - 允许收集差异、上下文和辅助证据。
  - 不允许代替审查判断本身。
- `verify`
  - 必须显式调用 `verification-before-completion` 再宣称通过。
  - 允许执行检查、收集输出、整理证据。
  - 不允许用更弱检查静默替代必需检查。
- `retro`
  - 允许整理运行痕迹和学习点。
  - 不允许借复盘直接改写规则。

`superpowers` 在这个技能中不能做的事：

- 决定需求方向。
- 扩 scope。
- 自行改写 `plan`。
- 开启高自由度 agent loop。
- 以“提高效率”为名绕过 `review` / `verify`。
- 在没有 bug、失败或异常现象时滥用 `systematic-debugging` 代替正常推进。

宿主侧收紧建议：

- Codex 侧优先依赖 sandbox / approvals，而不是只靠提示词自律。
- Claude Code 侧优先依赖权限机制、`allowed-tools` 和 `disable-model-invocation: true`。

## `harness engineering` 的落地位置

`harness engineering` 是收敛裁判，不是 architect。

它在这个技能中的主要落点：

- `guards/`
  - quick fail
  - no silent fallback
  - no implicit defaults
  - evidence required
  - phase gate discipline
  - controlled scope
  - no false completion
- `references/gate-rubric.md`
  - 统一的 go / no-go 判断框架。
- `flows/verify.md`
  - 证据优先，不能用信心替代。
- `templates/blocked.md`
  - 显式 blocker，而不是隐藏不确定性。
- `flows/retro.md`
  - 强制结束并沉淀学习。

`harness engineering` 在这个技能中不能做的事：

- 输出具体架构偏好来代替 gate 判断。
- 替 `plan` 选实现方案。
- 替 `reframe` 改写任务方向。

## 越权信号

只要出现以下任意情况，就说明三套来源系统的边界已经被污染：

- `gstack` 开始替用户做需求取舍。
- `superpowers` 开始决定“要不要顺手改更多”。
- `superpowers` 在没有 gate 或没有活动 ticket 时推进实现。
- `harness engineering` 开始输出架构偏好，而不是 gate / evidence / fail 判定。

出现越权信号时，应回退到对应阶段，或在无法恢复时输出 `blocked`。

> 来源系统的边界约束汇总见 references/boundary-rules.md
