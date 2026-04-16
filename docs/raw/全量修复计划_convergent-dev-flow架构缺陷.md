# 全量修复计划：convergent-dev-flow 架构缺陷（修订版）

## 背景

现有 `convergent-dev-flow` 已经形成可用的 system-level skill 包，但仍存在一些真实问题需要修复：

- **P0**：上下文预算偏高，维护时容易一次加载过多文件。
- **P1**：部分规则仍有重复表达，`review` 的对抗性和 `verify` 的证据口径还可以继续收紧。
- **P2**：`evals/` 仍偏人工阅读格式，可结构化程度不足。
- **P3**：来源系统术语对初次接触者仍有理解门槛，README 和 docs 需要继续压缩成更清晰的加载路径。

这些问题都是真的，但**修复方式必须服从当前设计依据**，不能为了降重复而改掉 skill 的架构边界。

---

## 本版修订原则

本计划以 [system_skill_设计说明.md](system_skill_设计说明.md) 和仓库根 [AGENTS.md](../../AGENTS.md) 为硬约束。

必须保持不变的东西：

- 固定流程仍为 `reframe -> plan -> ticket -> build -> review -> verify -> retro`
- 仍保留 `flows/`、`guards/`、`templates/`、`references/`、`examples/`、`docs/`、`evals/`
- 仍保留 `review` 与 `verify` 的严格分离
- 仍保持 v1 为纯指令型 skill
- 仍保持 harness 约束：quick fail、no silent fallback、no implicit defaults、evidence required、phase gate discipline、retro mandatory

本版明确**不采用**以下做法：

- 不引入 `phases/` 去替换 `flows/ + guards/ + templates/`
- 不删除 `references/stage-rules.md` 或 `references/boundary-rules.md`
- 不删除整个 `guards/` 目录
- 不引入 `small-fix-track` 或任何替代阶段机
- 不把 `reframe + plan + ticket` 合并成快捷通道
- 不假设存在可依赖的 `context:` frontmatter 自动加载
- 不把 `run-state` 设计成必需恢复协议
- 不把 `grep/diff/文件内容` 升格为所有验证场景的通用证据

一句话：**本次修复只做增量收紧，不做架构翻修。**

---

## 重新分组后的问题定义

### P0：加载策略和上下文预算

当前问题不是“目录层级太多”，而是：

- `SKILL.md`、`docs/usage.md`、各 phase 文档之间的加载边界还可继续压缩
- 维护者容易把 supporting files 一次性全读入，而不是按阶段加载

修复方向：

- 收紧“核心文件 / 阶段文件 / 维护文件”的加载策略说明
- 保留现有目录分层，不通过目录合并来降 token

### P1：规则重复与审查力度

当前问题不是“有多个目录”，而是：

- 部分规则在 `SKILL.md`、`flows/`、`docs/` 中重复表达但强弱不一
- `review` 虽已独立，但对抗式审查协议还不够结构化
- `verify` 的证据类型还不够按“声明类型”区分

修复方向：

- 将全局规则进一步收束到 `references/` 与 `guards/`
- phase 文档尽量引用共享准绳，而不是重复长段解释

### P2：Eval 与示例可执行性

当前问题不是“没有 eval”，而是：

- `evals/` 还可改为更清晰的结构化 case 格式
- 示例对“为什么这样做”仍有继续标准化的空间

修复方向：

- 改造 eval case 结构
- 保留当前 4 个必需示例
- 如确有必要，再追加负例示例，但不预设一定扩到 6 个

### P3：状态追踪与恢复

当前问题不是“必须做持久化”，而是：

- 缺少一个轻量的状态记录模板，帮助长对话中的阶段定位

修复方向：

- 可增加一个**可选** `run-state` 模板
- 不把它写成必需恢复协议
- 不把宿主前端能力假设为已经支持自动恢复

---

## 修复总策略

核心策略改为：

1. **保留当前 canonical 目录结构**
2. **通过共享准绳与更强交叉引用减少重复**
3. **把增强集中在 `review`、`verify`、`evals/`、README 与 usage**
4. **将 run-state 降为可选辅助模板，而不是运行时基础设施**

目标是把 skill 变得更稳、更清晰、更少误用，而不是让它更像自治系统。

---

## Step 1：先做基线测量，不预设夸张收益

新增一个“基线测量”步骤，先记录当前真实情况，而不是直接写死预计数值。

需要记录：

- 当前运行时通常加载哪些文件
- 典型单次运行的文件数量和大致 token 级别
- 哪些规则在 3 处以上重复出现
- 哪些重复是“同义重复”，哪些是“必要重复”

产出：

- 一份简短基线表
- 一份重复热点清单

产出位置：

- 放在 `docs/raw/` 下，作为一次性分析记录，不进入 skill 包主体
- 推荐命名：
  - `docs/raw/基线测量_convergent-dev-flow.md`
  - `docs/raw/重复热点_convergent-dev-flow.md`

注意：

- 在没有测量前，不再使用“运行时 ~10K token”“修复后 ~3.5K”这类未经验证的数字

---

## Step 2：保留目录分层，做交叉引用式去重

保留以下目录不变：

- `flows/`
- `guards/`
- `templates/`
- `references/`

改法不是合并目录，而是收紧职责：

- `flows/` 只保留阶段定义、gate、失败去向和阶段级来源视角
- `guards/` 保留 veto 规则，不内联删除
- `templates/` 保留输出结构，不塞过多阶段解释
- `references/` 保留全局准绳、边界和反模式

具体动作：

- 让 `flows/phase-order.md` 与 `references/stage-rules.md` 形成主从关系
  - `phase-order.md` 保留流程顺序、回退路径、禁止动作
  - `stage-rules.md` 保留全局阶段属性与横切纪律
- 让 `references/boundary-rules.md` 与 `references/source-system-mapping.md` 形成互补关系
  - 前者保留允许/禁止边界
  - 后者保留来源系统映射与越权信号

执行时必须补一张“重复规则处理表”，避免执行者再次自行分析一遍：

Step 2 开始前，必须先完成 Step 1，并将本表填完；未填表时，不得开始去重编辑。

| 重复规则 | 当前出现位置 | 保留位置 | 其他位置改为 |
|---|---|---|---|
| 待 Step 1 测量后填入 | 待填 | 待填 | 待填 |

对 `flows/` 七个阶段文件的具体编辑指引：

- `flows/reframe.md`
  - 保留：任务边界、成功标准、非目标、假设、失败去向
  - 收紧：减少对全局 quick fail / no implicit defaults 的重复长句，改为引用共享准绳
- `flows/plan.md`
  - 保留：单方案、验证契约、回退条件
  - 收紧：减少对全局 evidence / phase gate 纪律的重复解释
- `flows/ticket.md`
  - 保留：一票一活跃、粒度、停止条件
  - 收紧：避免重复解释全局 single-ticket discipline
- `flows/build.md`
  - 保留：最小必要变更、发现新决策时回退
  - 收紧：避免重复 guards 中已有的 veto 语义
- `flows/review.md`
  - 保留：对抗式审查目标、gate、失败去向
  - 增强：加入结构化的范围/方案/隐式默认对照项
- `flows/verify.md`
  - 保留：证据优先、blocked / unverified 去向
  - 收紧：只保留验证阶段定义，把证据分类细则主要下沉到 `references/gate-rubric.md`
- `flows/retro.md`
  - 保留：流程学习、强制结束
  - 收紧：减少与全局 retro mandatory 规则的重复表述

---

## Step 3：强化 `review`，但不引入人类分支协议

对 [flows/review.md](../../flows/review.md) 和 [templates/review.md](../../templates/review.md) 做增量增强。

补强内容：

1. Scope 对照
   - 每个变更文件是否仍落在 ticket 边界内
2. Plan 一致性
   - 实现路径是否仍对应 plan 的已选方案
3. 隐式默认搜索
   - 是否引入了未在 reframe/plan 中声明的行为选择
4. 复杂度审计
   - 是否超过当前 ticket 所需最小变更
5. 测试契约对照
   - plan 约定的测试或检查是否已落实

放置分工：

- 放入 `flows/review.md`
  - Scope 对照
  - Plan 一致性
  - 隐式默认搜索
- 放入 `templates/review.md`
  - 复杂度审计
  - 测试契约对照

原因：

- `flows/review.md` 负责阶段 gate、失败条件和审查目标
- `templates/review.md` 负责把审查结果组织成可复用输出结构

明确不做：

- 不引入 `review_needs_human: true` 这种新状态
- 不把 review 写成额外的人类介入分支协议

失败仍只允许：

- 回 `build`
- 或在发现方案错误时回 `plan`

---

## Step 4：强化 `verify`，按声明类型收紧证据口径

对 [flows/verify.md](../../flows/verify.md)、[templates/verify.md](../../templates/verify.md) 和 [references/gate-rubric.md](../../references/gate-rubric.md) 做增量增强。

需要补清楚的不是“有哪些工具”，而是“哪类声明需要哪类证据”：

- **静态结构声明**
  - 可接受：文件内容、diff、配置文本、明确的静态检查输出
- **行为声明**
  - 优先要求执行得到的检查结果
  - 若环境缺失，只能 `blocked` 或 `unverified`
- **外部环境声明**
  - 可接受：用户提供的外部证据，但必须明确标注来源

放置分工：

- `references/gate-rubric.md`
  - 作为 verify gate 的共享准绳，承载“声明类型 -> 证据类型”分类
- `flows/verify.md`
  - 只保留阶段目标、gate、失败去向，并引用 `gate-rubric` 的分类规则
- `templates/verify.md`
  - 要求输出中显式写明验收点、证据、未验证项、blocked 项和证据来源

明确不做：

- 不把 `grep/diff/文件内容` 当作所有行为声明的默认证据
- 不放宽“没有执行检查也可算验证通过”的口子

---

## Step 5：新增可选 `run-state` 模板，但不绑定 frontmatter 与恢复协议

可以新增：

- `templates/run-state.md`

用途：

- 作为长对话中的轻量状态记录模板
- 帮助说明“当前处于哪个阶段、活动 ticket 是什么、上一阶段是否完成”

但必须明确：

- 它是**可选辅助模板**
- 不写入 `SKILL.md` frontmatter 的 `context:`
- 不作为“找不到就自动恢复”的协议基础
- 不把宿主自动加载能力当成前提

推荐字段：

- `run_id`
- `current_phase`
- `phase_status`
- `active_ticket`
- `completed_outputs`
- `blockers`

不推荐字段：

- `review_needs_human`
- `track: small-fix`
- 任何暗示存在替代阶段机的字段

---

## Step 6：重构 `evals/` 为结构化格式

这一部分可以保留原计划方向，但去掉与错误目录重构绑定的内容。

### evals/trigger-cases.md

每个 case 统一为：

- `id`
- `input`
- `expected`
- `pass_criteria`
- `category`
- `rationale`

最低覆盖：

- 应触发：小 bug、小功能、安全重构、blocked
- 不应触发：纯解释、开放式头脑风暴、部署操作、自治清理

### evals/stage-gate-cases.md

每个 case 统一为：

- `id`
- `phase`
- `setup`
- `input`
- `expected`
- `pass_criteria`

重点覆盖：

- 跳阶段
- 混淆 `review` / `verify`
- 无 ticket 进入 build
- 无证据宣称完成
- `blocked` / `handoff` 的误用

### evals/regression-cases.md

每个 case 统一为：

- `id`
- `target_files`
- `assertion`
- `check_method`
- `severity`

重点补充：

- 防 phases/ 式目录重构回潮
- 防 quick-track / small-fix 绕过阶段机
- 防 `context:` frontmatter 越权引入

---

## Step 7：更新示例，但先守住当前 4 个必需示例

当前第一优先不是把示例数量做大，而是把现有必需示例做稳：

- `examples/small-bug/`
- `examples/small-feature/`
- `examples/safe-refactor/`
- `examples/blocked-run/`

本轮对示例的建议动作：

- 统一示例中的阶段表达和终态表述
- 统一示例中的来源系统说明方式
- 如新增 `run-state` 模板，只在示例中展示“可选写法”，不把它写成每阶段强制块

可选第二轮：

- 只有在 `evals/stage-gate-cases.md` 暴露出未被现有示例覆盖的失败模式时，再新增 `review-scope-drift` 或 `verify-no-evidence` 负例

---

## Step 8：更新 `SKILL.md` 与 docs，但不重写技能边界

对 [SKILL.md](../../SKILL.md)、[docs/usage.md](../usage.md)、[docs/acceptance.md](../acceptance.md)、[docs/self-check.md](../self-check.md)、[README.md](../../README.md) 做增量更新。

允许的修改：

- 更清楚的文件加载策略
- 更清楚的 `review` / `verify` 分工
- 更清楚的来源系统术语解释
- 如果采用 `run-state`，明确它是可选辅助模板
- 可在 `SKILL.md` 末尾追加一个轻量术语表，解释 `gstack` / `superpowers` / `harness engineering`

术语表要求：

- 只作为参考附录，不写成宪法条款
- 只解释职责边界，不新增行为规则
- 长度应控制在一屏内，避免把 `SKILL.md` 再次写重

不允许的修改：

- 不新增 `context:` frontmatter
- 不把前端/宿主能力当成既有事实写进宪法
- 不新增 small-fix 快速通道
- 不把“一次 plan 最多 3 个 ticket”写进宪法作为新规则

---

## 最终目录结构（保持 canonical shape）

```text
convergent-dev-flow/
  SKILL.md
  AGENTS.md
  README.md
  flows/
    phase-order.md
    reframe.md
    plan.md
    ticket.md
    build.md
    review.md
    verify.md
    retro.md
  guards/
    quick-fail.md
    no-silent-fallback.md
    no-implicit-defaults.md
    evidence-required.md
    phase-gate-discipline.md
    controlled-scope.md
    no-false-completion.md
    retro-mandatory.md
  templates/
    reframe.md
    plan.md
    ticket.md
    build.md
    review.md
    verify.md
    retro.md
    blocked.md
    handoff.md
    run-state.md              (可选新增)
  references/
    stage-rules.md
    gate-rubric.md
    anti-patterns.md
    boundary-rules.md
    source-system-mapping.md
  examples/
    small-bug/
    small-feature/
    safe-refactor/
    blocked-run/
  docs/
  evals/
```

---

## 涉及文件清单（修订后）

| 操作 | 文件 |
|---|---|
| 可选新建 | `templates/run-state.md` |
| 编辑 | `flows/reframe.md`, `flows/plan.md`, `flows/ticket.md`, `flows/build.md`, `flows/review.md`, `flows/verify.md`, `flows/retro.md`, `templates/review.md`, `templates/verify.md`, `references/gate-rubric.md`, `references/stage-rules.md`, `references/boundary-rules.md` |
| 编辑 | `evals/trigger-cases.md`, `evals/stage-gate-cases.md`, `evals/regression-cases.md` |
| 编辑 | `docs/usage.md`, `docs/acceptance.md`, `docs/self-check.md`, `README.md`, `SKILL.md` |
| 编辑 | 当前 4 个必需示例 |
| 不删除 | `flows/`, `guards/`, `templates/`, `references/` 的现有核心目录与文件 |

本版计划的关键变化是：**以编辑和可选新增为主，不以删除目录为主。**

---

## 量化预期（修订后）

只保留能通过测量验证的目标，不预设夸张收益：

- 运行时最小加载路径更清晰
- 重复规则的“强弱不一致”减少
- `review` 和 `verify` 的输出更可审计
- `evals/` 更适合持续回归

在未完成 Step 1 前，不承诺：

- 固定 token 数字
- 固定文件数降幅
- 固定总行数降幅

---

## 验证方式

1. 对照 [system_skill_设计说明.md](system_skill_设计说明.md) 的固定阶段机要求，确认没有新增替代流程
2. 对照 [AGENTS.md](../../AGENTS.md) 的期望结构，确认 `flows/`、`guards/`、`templates/`、`references/` 仍保留
3. 逐项检查 `review` / `verify` 是否比修复前更收紧，而不是更模糊
4. 确认 `SKILL.md` frontmatter 仍只使用已支持的最小字段集合，不假设宿主自动上下文能力
5. 在 4 个必需示例上走读，确认 fixed flow、blocked 语义、evidence discipline 仍完整
6. 运行 `docs/self-check.md` 清单做最终自检

---

## 结论

这份修订版保留了原文中最有价值的修复目标：

- 降重复
- 收紧 `review`
- 收紧 `verify`
- 提高 `evals/` 结构化程度
- 增加轻量状态记录能力

但放弃了会破坏 v1 边界的做法：

- 不做 `phases/` 架构替换
- 不做 `small-fix-track`
- 不做 `context:` frontmatter 依赖
- 不把守卫层和模板层压扁成阶段附属物

如果后续要执行，应按本修订版推进，而不是按旧版“目录重构优先”的方案推进。
