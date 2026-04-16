# Convergent Dev Flow 宿主侧验证设计

## 背景

当前仓库已经具备源码侧验证能力：

- Tier 1 回归断言
- Tier 2 自检断言
- Tier 3 LLM-as-judge 用例
- 面向宿主的 `INSTALL.md`
- 面向宿主的 `AGENTS.md` / `CLAUDE.md` 模板

这些验证主要证明 skill 包结构、安装契约和规则文本本身没有漂移，但还不能证明：

1. 一个全新的宿主仓库能否按文档完成双宿主安装。
2. 安装后的 Codex 是否真的会在 skill 约束下完成一次非平凡开发任务。

因此需要一次宿主侧端到端验证。

## 验证目标

这次验证必须同时覆盖两类目标。

### 目标 A：安装链路成立

需要证明以下事实：

- 宿主仓库能够通过当前 skill 仓库的安装入口完成安装，而不是手工复制文件伪装安装成功。
- 宿主中会生成 `AGENTS.md` 与 `CLAUDE.md`。
- 宿主中会生成 `.agents/skills/convergent-dev-flow/` 与 `.claude/skills/convergent-dev-flow/`。
- Claude 副本的 `SKILL.md` frontmatter 中存在 `disable-model-invocation: true`。
- 安装过程会显式记录实际使用的 `SOURCE_REF`。

### 目标 B：开发闭环成立

需要证明以下事实：

- Codex 在宿主仓库中能够显式触发 `convergent-dev-flow`。
- Codex 会遵守固定阶段顺序：
  - `reframe -> plan -> ticket -> build -> review -> verify -> retro`
- Codex 不会跳过 `ticket`。
- Codex 不会把 `review` 与 `verify` 合并。
- 最终状态会诚实落到 `verified`、`blocked` 或 `reframe-needed` 之一。

## 强约束

本次验证需要满足以下固定约束：

- 宿主代码目录位于 `~/code/python/` 下。
- 验证过程中所有实际执行任务都使用 `gpt-5.4` + `xhigh`。
- 安装链路优先验证真实的远端 / pinned 安装入口，不允许把“本地手工复制 skill”伪装成安装成功。
- 若网络、权限或环境条件不足以完成远端安装，应显式进入 `blocked`，或申请额外权限；不得静默回退。

## 目标宿主仓库

选择开源项目 `Pytest-with-Eric/pytest-fastapi-crud-example` 作为宿主基底。

选择理由：

- `FastAPI + SQLite + pytest`，本地运行和测试成本低。
- 仓库体量较小，便于观察 skill 对流程的约束，而不是把精力耗在基础设施上。
- 具备明确的数据模型、API 层和测试层，适合设计一条跨层需求。
- 足够真实，能够验证 `reframe / plan / ticket / build / review / verify / retro` 是否真的发生。

宿主仓库建议路径：

- `~/code/python/convergent-dev-flow-validation`

## skill 安装来源

本次安装应优先使用当前 skill 仓库的 pinned ref，而不是“latest main”。

当前待验证 ref：

- `e0b3024e2208e407bd97c12a98792adca8128d2b`

目标等价安装入口：

```text
Fetch and follow instructions from https://raw.githubusercontent.com/bigwhite37/harness_skills/e0b3024e2208e407bd97c12a98792adca8128d2b/INSTALL.md
```

验证时需要确认：

- 实际安装使用的 `SOURCE_REF` 与上述 pinned ref 一致。
- 安装不是从任意本地残留目录偷取内容。
- 如果远端 raw 或 clone 不可达，结果必须是显式失败或 `blocked`。

## 待验证需求

在宿主仓库中执行一条中等复杂度需求：

- 为现有实体引入软删除能力
- 默认列表查询隐藏已删除数据
- 支持显式 `include_deleted` 过滤
- 提供恢复接口
- 补齐或更新测试

### 选择这条需求的原因

- 会跨越数据模型、查询逻辑、API 语义与测试。
- 需要先在 `reframe` 锁定删除语义与默认行为，不能直接开写。
- 需要在 `plan` 中明确验证契约，例如默认列表行为、删除后的读取语义、恢复后的可见性。
- 足以触发一次完整的 `build -> review -> verify` 循环。
- 不会把项目拖入重型环境或额外基础设施。

## 预期流程证据

这次验证不是只看最终代码是否通过测试，还需要采集流程证据。

### 安装证据

至少需要确认：

- `AGENTS.md` 存在，且宿主可见 `$convergent-dev-flow`
- `CLAUDE.md` 存在，且宿主可见 `/convergent-dev-flow`
- `.agents/skills/convergent-dev-flow/` 完整存在
- `.claude/skills/convergent-dev-flow/` 完整存在
- `.claude/skills/convergent-dev-flow/SKILL.md` 包含 `disable-model-invocation: true`
- 本轮实际使用的 `SOURCE_REF` 明确记录

### 工作流证据

至少需要确认：

- Codex 明确进入 `reframe`
- `plan` 中出现单一方案与验证契约
- `ticket` 明确活动 ticket、验收点与停止条件
- `build` 只围绕活动 ticket 产生最小修改
- `review` 独立于 `verify`
- `verify` 提供直接执行证据，而不是主观信心
- 最后出现 `retro`

### 功能证据

至少需要确认：

- 软删除后默认列表行为正确
- `include_deleted` 行为与约定一致
- 恢复接口行为正确
- 相关测试通过

## 成功判定

只有同时满足以下条件，才算验证成功：

1. 安装链路通过。
2. 宿主仓库中 skill 落地完整。
3. Codex 显式按阶段机推进。
4. 中等复杂度需求实现完成。
5. `review` 与 `verify` 独立存在。
6. `verify` 拥有直接执行证据。
7. 结论与证据一致。

## 失败判定

出现以下任一情况，都算验证失败：

- 安装成功的说法无法对应到真实安装入口。
- 实际执行时不是 `gpt-5.4` + `xhigh`。
- 直接跳过 `reframe`、`plan` 或 `ticket`。
- `review` / `verify` 被合并成单个阶段。
- 通过主观判断代替执行证据。
- 网络或权限失败后，偷偷改成本地手工复制继续推进。
- 最终状态不是 `verified`、`blocked` 或 `reframe-needed`。

## 执行顺序

执行应分为两个连续子任务：

1. 在 `~/code/python/convergent-dev-flow-validation` 建立宿主仓库并完成 skill 安装验证。
2. 在该宿主仓库中，用安装好的 `convergent-dev-flow` 完成“软删除 + 过滤 + 恢复 + 测试补齐”需求验证。

## 风险与处理

### 风险 1：远端安装入口不可达

处理原则：

- 先显式报告失败原因。
- 若任务仍然要求继续，应申请运行权限或网络权限。
- 在未获得权限前，不得把本地复制当作远端安装验证成功。

### 风险 2：基底开源项目本身失效

处理原则：

- 若项目无法本地启动或测试基线已损坏，需要先判断是项目基线问题还是 skill 问题。
- 若无法在合理成本内恢复基线，应记录为宿主选择失败，并更换候选仓库后重新验证。

### 风险 3：功能验证通过但流程证据不足

处理原则：

- 这种情况不能算成功。
- 必须按 `convergent-dev-flow` 的验收要求判为未完成或流程验证失败。

## 后续步骤

当本设计获得确认后，下一步不是直接编码，而是输出实施计划，明确：

- 宿主仓库创建步骤
- 安装验证步骤
- 需求实现步骤
- 证据采集步骤
- 失败回退和 `blocked` 判定点
