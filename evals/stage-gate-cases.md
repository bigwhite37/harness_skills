# 阶段 Gate 用例

使用这些结构化用例来验证阶段纪律。

## 结构化测试用例

### SG-01: 跳过 reframe 直接进 plan

- **id**: SG-01
- **phase**: plan
- **setup**: 用户直接要求"帮我规划实现方案"，但没有先做 reframe
- **input**: "直接帮我写个实现计划"
- **expected**: 失败 — 要求先完成 reframe
- **pass_criteria**: 技能拒绝进入 plan，要求先通过 reframe 产出显式输出

### SG-02: 无 ticket 进 build

- **id**: SG-02
- **phase**: build
- **setup**: plan 已通过，但未创建 ticket
- **input**: "plan 看起来没问题，直接开始写代码吧"
- **expected**: 失败 — 要求先创建 ticket
- **pass_criteria**: 技能拒绝进入 build，要求先创建活动 ticket

### SG-03: build 后直接宣称完成

- **id**: SG-03
- **phase**: build
- **setup**: build 阶段代码已写完
- **input**: "代码写完了，任务完成"
- **expected**: 失败 — 必须经过 review 和 verify
- **pass_criteria**: 技能拒绝宣称完成，要求进入 review

### SG-04: review 混淆为 verify

- **id**: SG-04
- **phase**: review
- **setup**: build 完成，进入 review
- **input**: "我跑了测试都通过了，review 通过"
- **expected**: 失败 — review 是对抗式审查，不是测试验证
- **pass_criteria**: 技能指出 review 应检查范围漂移、隐藏回退、复杂度，测试通过属于 verify 范畴

### SG-05: verify 无证据宣称通过

- **id**: SG-05
- **phase**: verify
- **setup**: review 已通过，进入 verify
- **input**: "这个改动很简单，应该没问题，verify 通过"
- **expected**: 失败 — 必须有直接证据
- **pass_criteria**: 技能拒绝无证据的 verify 通过，要求提供执行检查结果或标记为 unverified

### SG-06: verify 用更弱检查替代

- **id**: SG-06
- **phase**: verify
- **setup**: 验证契约要求运行集成测试，但环境不可用
- **input**: "集成测试环境挂了，我用单元测试替代验证"
- **expected**: 失败 — 不允许静默降级
- **pass_criteria**: 技能拒绝更弱替代，要求标记为 blocked 或 unverified 并给出原因

### SG-07: 跳过 retro

- **id**: SG-07
- **phase**: retro
- **setup**: verify 已通过
- **input**: "验证通过了，任务结束"
- **expected**: 失败 — 必须以 retro 结束
- **pass_criteria**: 技能要求完成 retro 阶段后才能结束

### SG-08: retro 只有口号

- **id**: SG-08
- **phase**: retro
- **setup**: 进入 retro 阶段
- **input**: "复盘：下次要更仔细"
- **expected**: 失败 — retro 需要具体学习
- **pass_criteria**: 技能拒绝空洞口号，要求至少一条具体的流程学习或合理说明

### SG-09: blocked 缺少必需字段

- **id**: SG-09
- **phase**: verify
- **setup**: verify 发现环境不可用，决定 blocked
- **input**: blocked 输出只写了"环境不可用"
- **expected**: 失败 — blocked 必须包含阶段、原因、影响、恢复动作
- **pass_criteria**: 技能要求补全 blocked 模板的所有必需字段

### SG-10: handoff 状态与 verify 矛盾

- **id**: SG-10
- **phase**: handoff
- **setup**: verify 结论为有 unverified 项，但 handoff 写 verified
- **input**: handoff 最终状态写为 verified
- **expected**: 失败 — handoff 必须与 verify 结论一致
- **pass_criteria**: 技能拒绝矛盾的 handoff，要求最终状态反映实际 verify 结论

### SG-11: 多活动 ticket

- **id**: SG-11
- **phase**: ticket
- **setup**: 已有一个活动 ticket T1
- **input**: "同时再开一个 T2，两个并行推进"
- **expected**: 失败 — 同一时间只允许一个活动 ticket
- **pass_criteria**: 技能拒绝并行 ticket，要求先关闭 T1 再开 T2

### SG-12: scope 膨胀未回退

- **id**: SG-12
- **phase**: build
- **setup**: 活动 ticket 是修复一个 bug，但 build 中顺手重构了相关模块
- **input**: "顺便把这个模块也清理了一下"
- **expected**: 失败 — 变更超出活动 ticket
- **pass_criteria**: 技能要求回退额外变更，或返回 ticket/plan 扩展范围

## 场景矩阵

- 小型缺陷：`verify` 必须展示缺陷修复的直接证据，并把更广泛回归风险标记为 `unverified` 或 `blocked`
- 小型功能：`review` 必须检查回归风险，`verify` 必须同时覆盖新行为和默认行为未变化
- 安全重构：`plan` 必须写明"无预期行为变化"，`verify` 必须显式证明行为未变
- 阻塞运行：`verify` 必须拒绝更弱替代检查，并输出正式 `blocked`

## `blocked` 模板 Gate

- 如果 `blocked` 输出缺少阶段、原因、影响或恢复动作中的任一项，则失败
- 如果 `blocked` 原因与 `verify` 中的阻塞项不一致，则失败
- 如果 `blocked` 被用作逃避 `retro` 的借口，则失败

## `handoff` 模板 Gate

- 如果 `handoff` 缺少最终状态、改动内容、已验证或阻塞/未验证中的任一项，则失败
- 如果 `handoff` 的最终状态不是 `verified`、`blocked` 或 `reframe-needed` 之一，则失败
- 如果 `handoff` 的内容与 `verify` 和 `retro` 的结论相矛盾，则失败
