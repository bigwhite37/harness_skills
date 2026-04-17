下面把这个 skill 暂定名为 `convergent-dev-flow`。它不是“帮你做事的万能 prompt”，而是一个把开发任务压进固定阶段、显式 gate、证据验证和复盘闭环里的流程引擎。这样设计也符合宿主能力分层：Codex 把 `AGENTS.md` 定位为常驻项目指导，把 skills 定位为可复用工作流；当前 Codex 在仓库内从 `.agents/skills/` 发现 repo-local skills。Claude Code 也以 `SKILL.md` 为 skill 入口，项目技能放在 `.claude/skills/`，可自动匹配或直接 `/skill-name` 调用，并支持通过 frontmatter 禁止模型自动调用。Claude 文档还表明 `CLAUDE.md` 会在会话启动时被加载到上下文中，作为默认系统提示之后的一层项目指令。基于这些宿主事实，最稳的切法是：`AGENTS.md`/`CLAUDE.md` 放“永远成立的仓库规则”，skill 包放“按任务触发的收敛流程”。 ([OpenAI开发者][1])

## 1. 目标、边界、非目标

### 目标

这个 system skill 的目标不是提高“表面自动化”，而是提高**开发任务的可收敛性**。具体体现为：

* 非平凡开发任务必须经过固定阶段，而不是自由跳步。
* 每次运行只能产出三种结果：

  1. 已验证的变更；
  2. 显式阻塞；
  3. 回退到更早阶段重做。
* 每个“完成”判断都必须绑定 evidence，而不是“看起来差不多”。
* 每次运行都留下可审计的过程痕迹，让另一个 engineer 不看聊天记录也能理解为何这样改、为何认为它成立。
* 每次运行结束必须把过程经验沉淀为 retro，而不是只沉淀代码。

### 边界

这个 skill 只负责**单任务开发闭环**：从重新定义任务，到规划、切票、构建、审查、验证、复盘。它不接管：

* 仓库的常驻工程规则；
* 发布、部署、CI/CD、PR 管理；
* 跨任务排期；
* 产品方向裁决；
* 长期记忆系统。

### 非目标

第一版明确不是下面这些东西：

* 不是自由发挥型 agent；
* 不是多 agent 编排器；
* 不是自动 ship / deploy / commit / PR 机器人；
* 不是“帮你顺手把周边问题也一起优化”的 opportunistic refactor 引擎；
* 不是会自我改写流程规则的元系统。

---

## 2. 固定流程：`reframe → plan → ticket → build → review → verify → retro`

这七个阶段是**硬顺序**，不是建议顺序。

### 这条流程的真正作用

它把收敛控制拆成七个不同职责：

* `reframe` 锁定任务边界；
* `plan` 锁定实现路径和验证路径；
* `ticket` 锁定执行粒度；
* `build` 只做当前票据的最小变更；
* `review` 用对抗式视角找问题；
* `verify` 用证据判定成立；
* `retro` 把这次运行转成流程改进素材。

### 允许的回退

允许回退，但不允许自由漂移：

* `plan` 失败，回 `reframe`
* `ticket` 失败，回 `plan`
* `build` 遇到结构性问题，回 `ticket` 或 `plan`
* `review` 失败，回 `build`；若发现方案错误，回 `plan`
* `verify` 失败，回 `build`；若验证契约本身失效，回 `plan`
* `retro` 不回退，它只结束

### 不允许的行为

* 不允许跳过 `ticket`
* 不允许 `build` 完直接宣称完成
* 不允许把 `review` 当成 `verify`
* 不允许以“先做再说”代替 `reframe`/`plan`
* 不允许隐藏内循环，反复试错但不升级阶段

### 为什么没有 `ship`

`ship` 不进第一版阶段机。原因很简单：一旦把发布、提交、部署和对外副作用揉进 v1，这个 skill 很容易从“流程引擎”滑向“自由执行 agent”。第一版的终点应该是**verified handoff**，不是自动外部动作。

---

## 3. 每个阶段的目的、输入、输出、gate、失败条件

### `reframe`

**目的**：把模糊请求压成一个单一、可验证、可拒绝的任务定义。

**输入**：用户请求、仓库常驻规则、当前代码现实、已知约束。

**输出**：当前任务陈述、成功标准、明确非目标、关键假设、未知项、阻塞项、完成定义。

**gate**：

* 只有一个主目标；
* 成功标准能被后续验证；
* 非目标明确；
* 假设被显式写出，而不是偷偷采用。

**失败条件**：

* 同时存在多个互相竞争的任务定义；
* 成功标准不可验证；
* 关键决策缺失但被偷偷默认；
* 任务边界大到无法控制。

**失败去向**：停止并报 blocked，或等待新的 reframe，不准带着隐式默认继续。

---

### `plan`

**目的**：选定最小可行路径，并在写代码前先定义验证契约。

**输入**：`reframe` 产物 + 必要代码探索结果。

**输出**：选定方案、放弃的备选路径、影响面、主要风险、验证契约、回滚思路。

**gate**：

* 只有一个当前方案；
* 影响面可描述；
* 验证方式在编码前就已经存在；
* 没有被包装成“小改动”的跨系统重构。

**失败条件**：

* 没有清晰验证路径；
* 多个方案尚未裁决；
* 影响面失控；
* 实际上需要产品/架构决策但未升级。

**失败去向**：回 `reframe` 或 blocked。

---

### `ticket`

**目的**：把方案拆成小而可关账的执行票据，避免 build 阶段自由扩散。

**输入**：通过 gate 的 `plan`。

**输出**：有顺序的 ticket 列表；每张 ticket 的目标、边界、验收点、停止条件。

**gate**：

* 一次只允许一个 active ticket；
* 每张 ticket 都足够小，能在单轮 build-review 内闭合；
* ticket 总量仍然忠于原始 scope；
* 没有循环依赖。

**失败条件**：

* ticket 只是抽象主题，不可执行；
* 粒度过大；
* 同时跨太多模块；
* 需要并行化才能推进。

**失败去向**：回 `plan`。

---

### `build`

**目的**：在当前 ticket 内做最小必要变更，而不是顺手优化整个系统。

**输入**：active ticket、仓库惯例、现有代码模式。

**输出**：当前 ticket 的代码/测试/文档变更，触达文件说明，新增发现的问题列表。

**gate**：

* 变更严格对应 active ticket；
* 没有夹带未批准的附带优化；
* 改动可解释；
* 已完成基本自检，不把明显坏状态交给 review。

**失败条件**：

* 需要扩 scope 才能完成；
* 遇到新依赖或新决策；
* 为了修一个点开始重写一片区域；
* 同一问题上反复修补但无结构性进展。

**失败去向**：回 `ticket` 或 `plan`。

---

### `review`

**目的**：做对抗式工程审查，专门检查“是不是改偏了、改脏了、改复杂了”。

**输入**：当前 diff、ticket 目标、plan、仓库模式。

**输出**：问题列表、严重度、是否通过、修复建议。

**gate**：

* 没有未解决的高严重度问题；
* 没有 scope drift；
* 没有隐藏 fallback；
* 没有无理由复杂化；
* 改动逻辑能被人类 reviewer 解释。

**失败条件**：

* 实现和 ticket 不一致；
* 方案偏离 plan；
* 出现隐式默认行为；
* 通过清理、抽象、重构名义引入额外复杂度；
* 需要测试却没补。

**失败去向**：通常回 `build`；若发现根本方案错误，则回 `plan`。

---

### `verify`

**目的**：把“我觉得对”变成“有证据表明对”。

**输入**：review 通过的变更、验证契约、可用执行环境。

**输出**：验收点到证据的映射、检查结果、剩余风险、未验证项。

**gate**：

* 每个成功标准都有直接证据，或被显式标记为 blocked / unverified；
* 所有必需检查都被执行，或明确说明为何不能执行；
* 结论与证据一致。

**失败条件**：

* 检查没跑却默认通过；
* 结果不明确却被当成通过；
* 环境不可用却偷偷换成更弱检查；
* 证据与结论冲突；
* 只能说“理论上应该可以”。

**失败去向**：回 `build` 或 `plan`；若环境/权限缺失无法补救，则 blocked。

---

### `retro`

**目的**：把本次运行转成流程学习，而不是只留下代码结果。

**输入**：前六阶段的痕迹、失败点、verify 证据、返工点。

**输出**：保留什么、修改什么、移除什么；对 skill / AGENTS / evals / 流程文档的候选改进。

**gate**：

* 至少形成一个具体的流程学习，或明确说明这次为何不需要流程变更；
* 学习点指向未来流程，而不是补写宣传口径。

**失败条件**：

* 只写空话；
* 把产品 backlog 冒充 retro；
* 未经审查直接篡改流程规则；
* 用“下次注意”代替结构性改进。

**失败去向**：无。`retro` 是强制结束阶段。

---

## 4. gstack、superpowers、harness engineering 的职责边界

### gstack 的职责

在集成版 v1 中，gstack 不是“被内化后消失的方法论来源”，而是**被 skill 显式调用的外部技能集**。它只提供**阶段骨架和角色化提问方式**。

必须显式调用的东西：

* `office-hours` → `reframe` 前必须显式调用，用于问题澄清和约束识别
* `plan-ceo-review` → `plan` 前必须显式调用，用于检查任务价值、范围和优先级合理性
* `plan-eng-review` → `plan` 前必须显式调用，用于检查技术路径、风险、依赖和复杂度
* `review` → `review` 阶段必须显式调用
* `qa` / `qa-only` → 仅当 verify 契约确实依赖真实 UI / 浏览器用户流时显式调用
* `retro` → `retro` 阶段必须显式调用

不能做的事：

* 把这些调用点吸收到 skill 内部，导致运行期看不见显式调用记录；
* 任意新增流程阶段；
* 把角色化对话变成产品决策授权。

一句话：**gstack 决定“怎么分阶段想”，不决定“做什么产品方向”。**

### superpowers 的职责

在集成版 v1 中，superpowers 也不是抽象来源，而是**被 skill 显式调用的外部技能集**。它只提供**低自由度执行增强**：

* 文件操作
* 任务拆解
* 多步骤执行
* 上下文组织

并且它在关键阶段承担显式 gate 前置义务：

* `test-driven-development` → `build` 前必须显式调用
* `systematic-debugging` → 只在 bug、失败或异常行为出现后显式调用，再讨论修复
* `verification-before-completion` → `verify` 前必须显式调用

它只能在“已经过 gate 的阶段”和“已经激活的 ticket”里工作。它不能：

* 决定需求方向；
* 扩 scope；
* 自行改写 plan；
* 开启高自由度 agent loop；
* 以“提高效率”为名绕过 review / verify。
* 在没有 bug、失败或异常现象时把 `systematic-debugging` 变成拖延性 ritual。

一句话：**superpowers 是手脚，不是方向盘。**

### harness engineering 的职责

harness engineering 是**系统级 veto 层**，负责把流程拉回真实工程约束。它只管这些硬规则：

* quick fail
* 无 silent fallback
* 无隐式默认行为
* 必须有 evidence
* 必须有 gate
* 必须有 retro

它不负责选实现方案，也不负责决定需求价值。它只负责说：

* 现在不能继续；
* 现在不能宣称完成；
* 现在必须回退阶段；
* 现在必须留下证据或 blocker。

一句话：**harness 不是 architect，它是收敛裁判。**

### 防污染规则

* gstack 一旦开始替用户做需求取舍，就是越权。
* superpowers 一旦开始决定“要不要顺手改更多”，就是越权。
* harness 一旦开始输出具体架构偏好，而不是 gate / evidence / fail 判定，就是越权。

另外，superpowers 的“受控”最好落在宿主的权限/沙盒机制上，而不是只靠 prompt 自律：Codex 官方把 sandbox 与 approvals 作为核心安全边界，并建议默认保持收紧；Claude Code 侧则支持以权限机制、`allowed-tools` 和 `disable-model-invocation` 缩小 skill 的行为边界。 ([OpenAI开发者][2])

---

## 5. 建议目录结构

两边都支持把 supporting files 放进 skill 目录，并按需读取；所以 `SKILL.md` 不应该塞满所有细节，而应该只放阶段机、宪法和导航，细节放到模板、参考和示例里。 ([OpenAI开发者][3])

```text
Codex:   .agents/skills/convergent-dev-flow/
Claude:  .claude/skills/convergent-dev-flow/

convergent-dev-flow/
  SKILL.md
  templates/
    reframe.md
    plan.md
    ticket.md
    review.md
    verify.md
    retro.md
    blocked.md
    handoff.md
  references/
    stage-rules.md
    gate-rubric.md
    anti-patterns.md
    boundary-rules.md
  examples/
    small-bug/
    small-feature/
    safe-refactor/
    blocked-run/
  evals/
    trigger-cases.md
    stage-gate-cases.md
    regression-cases.md
```

### 目录设计原则

* `SKILL.md`：只做运行时总宪法 + 阶段导航。
* `templates/`：保证每次输出有统一结构。
* `references/`：放阶段解释、反模式、边界说明。
* `examples/`：给模型正反例，降低“自由发挥”。
* `evals/`：让 skill 本身可回归、可迭代。

第一版不放 `scripts/`。不是因为不能有，而是因为现在还不该有。

---

## 6. skill 需要包含的核心模板类型与用途

### 1) `reframe` 模板

用途：把原始请求压缩成任务契约。
关键作用：避免 build 阶段才发现“你理解的是另一个问题”。

### 2) `plan` 模板

用途：记录最小实施路径、放弃的备选方案、验证契约。
关键作用：把“怎么验”前置，防止先改后补理由。

### 3) `ticket` 模板

用途：把 plan 切成小票，并给每张票设置停止条件。
关键作用：把复杂度控制点放在 build 之前，而不是 build 之后。

### 4) `review` 模板

用途：按严重度记录缺陷和修复方向。
关键作用：把 review 从“描述改了什么”改成“专门找错”。

### 5) `verify` 模板

用途：把验收标准映射到证据。
关键作用：防止“测过了”这种无证据结论。

### 6) `retro` 模板

用途：沉淀流程级 learning。
关键作用：避免流程只消费上下文、不产生系统改进。

### 7) `blocked` 模板

用途：当任务不能继续时，输出显式阻塞而不是隐式停滞。
关键作用：把失败转成可处理状态。

### 8) `handoff` 模板

用途：给最终消费者一份简洁可读的交付摘要。
关键作用：让“verified change / blocked / need reframe”三种终态一眼可见。

### 9) `gate-rubric`

它不一定是模板，但必须存在。
用途：作为所有阶段的统一 go/no-go 判定准绳。
关键作用：防止不同阶段使用不同质量标准。

---

## 7. 第一版必须做的功能，以及必须暂缓引入的能力

Codex 和 Claude 都支持更强能力：脚本、附加资源、自动触发、subagents、hooks、MCP 等；但官方材料也明显把 skill 设计成“以 instructions 为核心、按需带入更强执行能力”的扩展机制，而不是默认就把所有自动化打开。Codex 的 skill 创建流程里 instruction-only 是默认分支，OpenAI 也强调“上下文依赖的部分优先交给模型，只在确定性部分再引入脚本”；Claude skills 同样支持 `context: fork`、subagents、hooks 和 tool 限制。第一版应该故意保守。 ([OpenAI开发者][4])

### 第一版必须做

1. instruction-only skill
2. 固定阶段机
3. 显式 gate 与显式失败条件
4. `review` 与 `verify` 强制分离
5. `blocked` 作为一等结果
6. 一次只允许一个 active ticket
7. retro 强制执行
8. 示例与 eval 一起交付
9. 宿主层明确说明：常驻规则进 `AGENTS.md`/`CLAUDE.md`，流程引擎进 skill
10. 结果只能是 verified / blocked / reframe-needed

### 第一版必须暂缓

1. 自动触发默认开启
2. scripts
3. hooks
4. `context: fork` / subagents / agent teams
5. 并行 tickets
6. 自动 commit / PR / deploy / ship
7. MCP 扩展依赖
8. 运行时自我改写 `SKILL.md` / `AGENTS.md` / `CLAUDE.md`
9. 长期 memory 依赖
10. `/loop`、定时轮询、持续自治
11. 绩效式 benchmark / auto-optimization 模式
12. “顺手修复相邻问题”的 opportunistic scope expansion

另外，第一版建议只走**显式调用**：Codex 支持 `$skill-name` 显式触发，也会根据 `name`/`description` 自动挑 skill；Claude 也支持自动触发，但可以用 `disable-model-invocation: true` 彻底关闭模型自动调用。为了避免一开始就变成“自由发挥型 agent”，v1 应明确要求手工调用，不做隐式自动匹配。 ([OpenAI开发者][5])

---

## 8. 可直接写入 `SKILL.md` 的“运行时宪法”

下面这段可以几乎原样写进 `SKILL.md`：

```md
## Runtime Constitution

1. This skill is a workflow governor, not a product-decider.
2. Follow the phase order exactly: reframe → plan → ticket → build → review → verify → retro.
3. Never skip a phase. Never merge review into verify.
4. Prefer quick failure over speculative progress.
5. No silent fallback. If a tool, check, file, or environment is unavailable, say so explicitly.
6. No implicit defaults. Any material behavior choice must be grounded in user request, repo evidence, or an explicit assumption stated in reframe.
7. Lock scope in reframe. Lock verification in plan. If either changes, return to that phase.
8. Ticket before build. No implementation begins without an active ticket.
9. One active ticket at a time.
10. Build the smallest change that satisfies the active ticket. No opportunistic extras.
11. Review is adversarial. It must actively search for scope drift, hidden fallback, unnecessary complexity, regression risk, and missing tests.
12. Verify with evidence, not confidence. If evidence is missing, status is unknown, not done.
13. Do not claim success unless every acceptance criterion has direct evidence or is explicitly marked blocked.
14. If the same ticket fails review or verify repeatedly, stop local patching and return to plan.
15. A blocked run is acceptable. Concealed uncertainty is not.
16. In v1, do not invoke scripts, hooks, subagents, parallel agents, commits, PR creation, deployment, or any external side-effect workflow.
17. Do not rewrite AGENTS.md, CLAUDE.md, or this skill during product work. Record process-change proposals in retro instead.
18. End every run with retro.
```

这套宪法的核心不是“写得严格”，而是把以下几件事钉死：

* 默认不做；
* 做了必须有依据；
* 宣称成立必须有证据；
* 失败必须显式化；
* 学到东西必须沉淀。

---

## 9. 如何驱动 Codex 落地这个 skill 包

Codex 官方把 `AGENTS.md` 作为工作前就生效的项目指导，把 repo-local skills 放在 `.agents/skills/`，并强调 `SKILL.md` 的 `name` 和 `description` 是触发可靠性的主要信号；OpenAI 的 OSS 工作流实践也建议 `AGENTS.md` 保持精简，把可复用流程放进 skills。Claude 侧则用 `.claude/skills/` 承载项目技能，并支持直接 `/skill-name` 触发。 ([OpenAI开发者][6])

### 落地顺序

1. **先定层次，不先写内容**
   先告诉 Codex：`AGENTS.md` 只放仓库永远成立的规则；`convergent-dev-flow` skill 只放流程引擎。

2. **先写 `SKILL.md`，后写 supporting files**
   让 Codex 先产出：目标、边界、阶段机、gate、失败转移、运行时宪法。
   不要一上来生成一堆模板细节。

3. **再补 `templates/`**
   每个阶段一个模板，再加 `blocked` 和 `handoff`。
   模板内容要服务 gate，不要变成文档仪式。

4. **再补 `references/` 和 `examples/`**
   `references/` 解释规则，`examples/` 给正反样本。
   负例很重要，因为它能抑制自由发挥。

5. **最后补 `evals/`**
   至少覆盖四类场景：

   * 小 bug
   * 小 feature
   * 安全重构
   * 明确 blocked
     eval 的目标不是测“聪明”，而是测“会不会跳阶段、会不会偷偷默认、会不会无证据宣称完成”。

6. **只允许显式触发测试**
   Codex 侧用 `$convergent-dev-flow`；
   Claude 侧用 `/convergent-dev-flow` + `disable-model-invocation: true`。
   在 eval 稳定之前，不准打开自动匹配。

7. **只根据失败模式迭代 wording**
   发现 Codex 老是跳过 `ticket`，就收紧 `ticket` 规则；
   发现 verify 老在“无证据通过”，就收紧 verify gate。
   不要用添加更多能力来掩盖流程定义不清。

### 可以直接交给 Codex 的实施说明

你后续可以把下面这段直接给 Codex：

> 为当前仓库创建一个 repo-local skill，名称为 `convergent-dev-flow`。
> 这是一个 instruction-only 的 system-level workflow skill，不是功能 skill。
> 目标是为非平凡开发任务建立固定阶段机：`reframe → plan → ticket → build → review → verify → retro`。
> 要求：
>
> * 每个阶段都必须定义 purpose、inputs、outputs、gate、failure conditions。
> * 必须有显式 blocked 状态。
> * 必须分离 review 与 verify。
> * 必须有 retro。
> * 必须体现 quick fail、no silent fallback、no implicit defaults、evidence required、gate required。
> * 一次只允许一个 active ticket。
> * 只做最小变更，不允许 opportunistic extras。
> * 只支持显式触发，不允许第一版自动触发。
> * 第一版不允许 scripts、hooks、subagents、parallel work、commit、PR、deploy、MCP、长期 memory。
>   交付物应包含：
> * `SKILL.md`
> * `templates/`
> * `references/`
> * `examples/`
> * `evals/`
>   同时补一个极简 `AGENTS.md`，只放仓库常驻规则和对该 skill 的引用，不要把阶段逻辑塞进 `AGENTS.md`。
>   完成后，用自审方式检查：是否存在跳阶段、隐式默认、无证据宣称完成、无 retro、无 blocked 语义、或把 skill 做成自由 agent 的问题。

---

## 10. 这份设计的交付验收标准

只要 Codex 产出的 skill 包不满足以下任一项，就算**未达标**：

1. reviewer 不看聊天记录，也能看懂阶段顺序、gate 和失败转移。
2. `review` 和 `verify` 被清晰分离。
3. `blocked` 被定义为正式终态之一。
4. 明确写出第一版不做什么。
5. 明确写出如何防止 skill 退化成自由发挥型 agent。
6. `AGENTS.md`/`CLAUDE.md` 与 skill 的职责被清晰切开。
7. 存在正例和负例，不只有 happy path。
8. 存在 eval，用来回归“流程是否守规”，而不是只测任务成功率。
9. skill 的默认行为是保守的，而不是自动扩权。
10. retro 是强制阶段，不是附录。


[1]: https://developers.openai.com/codex/concepts/customization/?utm_source=chatgpt.com "Customization – Codex"
[2]: https://developers.openai.com/codex/agent-approvals-security/?utm_source=chatgpt.com "Agent approvals & security – Codex"
[3]: https://developers.openai.com/blog/skills-agents-sdk/?utm_source=chatgpt.com "Using skills to accelerate OSS maintenance"
[4]: https://developers.openai.com/codex/skills/?utm_source=chatgpt.com "Agent Skills – Codex"
[5]: https://developers.openai.com/codex/changelog?date=2026-01-06&utm_source=chatgpt.com "Codex changelog"
[6]: https://developers.openai.com/codex/guides/agents-md/?utm_source=chatgpt.com "Custom instructions with AGENTS.md – Codex"
