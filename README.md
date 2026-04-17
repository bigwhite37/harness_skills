# convergent-dev-flow

这是一个公开的系统级技能 git repo。仓库根目录就是技能包本体，不是消费端镜像目录。

这个技能用于把单个非平凡开发任务固定在以下阶段机内推进：

`reframe -> plan -> ticket -> build -> review -> verify -> retro`

它编排三层能力：

- `gstack`：通过显式技能调用提供阶段骨架和角色化审视视角
- `superpowers`：通过显式技能调用提供受 gate 和活动 ticket 约束的低自由度执行增强
- `harness engineering`：gate、evidence、quick fail、blocked、retro 纪律

这个仓库的规范源码结构见：

- [SKILL.md](SKILL.md)
- [INSTALL.md](INSTALL.md)
- [docs/usage.md](docs/usage.md)
- [AGENTS.md](AGENTS.md)

## 给代码智能体的结论

如果你要把这个技能装进一个宿主仓库，不要手工拼接安装步骤，也不要把整个源码仓库继续嵌套成“repo 里再放 `.agents/skills/...`”。正确做法是：

1. 在目标仓库根目录，把安装 prompt 直接交给代码代理。
2. 让代理读取 [INSTALL.md](INSTALL.md) 并自动 clone / 更新源码、创建宿主目录、安装 skill。
3. 让代理先确保当前 host 的 `gstack` / `superpowers` 依赖已按官方方式安装。
4. 首次安装或显式 reset 时走 `bootstrap install`：按本仓库模板重写宿主 `AGENTS.md` 与 `CLAUDE.md`。
5. 已有安装且需要保留宿主永久规则时走 `update existing install`：只更新 skill 包，不重写宿主 `AGENTS.md` / `CLAUDE.md`。
6. 在目标仓库里显式触发，不依赖自动匹配。

## 安装

以下安装入口面向 **LLM code agent**，不是给人手工逐条敲 shell 命令的。

这个安装流分两种模式：

- `bootstrap install`
  - 适用于首次安装，或你明确要把宿主 `AGENTS.md` / `CLAUDE.md` 重置为本仓库模板。
  - 这是 **破坏性** 操作，会重写宿主常驻规则文件。
- `update existing install`
  - 适用于宿主已经安装过本 skill，且你要保留宿主已有永久规则。
  - 这条路径只更新 skill 包，不重写宿主 `AGENTS.md` / `CLAUDE.md`，除非用户明确要求 reset。

此外，安装 prompt 分两类：

- `latest main`
  - 总是拉取 canonical upstream `main`
- `same-ref / pinned`
  - 使用与当前 `branch/tag/commit` 相同的 ref
  - 换句话说，就是 `same ref` 安装
  - 适用于 PR、release、tag、fork 或需要可复现安装的场景

在目标仓库根目录，把下面 prompt 直接交给对应代理：

### Codex / Claude Code, latest main

```text
Fetch and follow instructions from https://raw.githubusercontent.com/bigwhite37/harness_skills/refs/heads/main/INSTALL.md
```

### Codex / Claude Code, same-ref or pinned install

```text
Fetch and follow instructions from https://raw.githubusercontent.com/bigwhite37/harness_skills/<REF>/INSTALL.md
```

`<REF>` 可以替换为：

- `refs/heads/<branch>`
- `refs/tags/<tag>`
- `<commit-sha>`

如果你要宣称某个 **已发布** ref 的公开安装入口已经可用，先证明它的 raw `INSTALL.md` 能直接返回 `200`。不要因为“本地候选版本能装”就倒推出“公开安装链路也没问题”。

安装器会自动完成以下动作：

- 先安装或校验当前 host 上的 `gstack` 与 `superpowers`
- clone 或更新 `harness_skills` 源码
- 创建 `.agents/skills/convergent-dev-flow/`
- 创建 `.claude/skills/convergent-dev-flow/`
- 在 `bootstrap install` 中按本仓库模板重写宿主 `AGENTS.md`
- 在 `bootstrap install` 中按本仓库模板重写宿主 `CLAUDE.md`
- 在 `update existing install` 中保留宿主 `AGENTS.md` / `CLAUDE.md`
- 给 Claude 副本的 `SKILL.md` 加上 `disable-model-invocation: true`
- 记录本轮使用的 `SOURCE_REF`
- 在 `update existing install` 中记录宿主规则文件的前后校验结果
- 做安装后校验并汇报结果

不要把源仓库根目录里的 `AGENTS.md` 直接复制成宿主技能目录文件。宿主 `AGENTS.md` / `CLAUDE.md` 只应在 `bootstrap install` 时由安装器根据宿主模板生成。

## 安装后结果

安装完成后：

- Codex 侧用 `$convergent-dev-flow`
- Claude Code 侧用 `/convergent-dev-flow`
- 当前 host 上应已可直接使用：
  - `gstack`: `office-hours`、`plan-ceo-review`、`plan-eng-review`、`review`、`retro`
  - `superpowers`: `test-driven-development`、`systematic-debugging`、`verification-before-completion`
- 宿主常驻规则落在生成后的 `AGENTS.md` / `CLAUDE.md`
- 任务触发型工作流逻辑留在 `.agents/skills/convergent-dev-flow/` 与 `.claude/skills/convergent-dev-flow/`

## 最小安装校验

安装完成后，目标仓库中至少应存在：

- `AGENTS.md`
- `CLAUDE.md`
- `.agents/skills/convergent-dev-flow/SKILL.md`
- `.claude/skills/convergent-dev-flow/SKILL.md`
- `.agents/skills/convergent-dev-flow/flows/`
- `.claude/skills/convergent-dev-flow/flows/`
- `.agents/skills/convergent-dev-flow/guards/`
- `.claude/skills/convergent-dev-flow/guards/`
- `.agents/skills/convergent-dev-flow/templates/`
- `.claude/skills/convergent-dev-flow/templates/`
- `.agents/skills/convergent-dev-flow/references/`
- `.claude/skills/convergent-dev-flow/references/`
- `.agents/skills/convergent-dev-flow/examples/`
- `.claude/skills/convergent-dev-flow/examples/`
- `.agents/skills/convergent-dev-flow/evals/`
- `.claude/skills/convergent-dev-flow/evals/`
- `.agents/skills/convergent-dev-flow/docs/usage.md`
- `.claude/skills/convergent-dev-flow/docs/usage.md`
- `.agents/skills/convergent-dev-flow/docs/self-check.md`
- `.claude/skills/convergent-dev-flow/docs/self-check.md`
- `.agents/skills/convergent-dev-flow/docs/acceptance.md`
- `.claude/skills/convergent-dev-flow/docs/acceptance.md`

若缺少以上任一项，就不是完整安装。

若本轮执行的是 `bootstrap install` 或显式 reset，还应额外看到：

- `AGENTS.md` 中的 `convergent-dev-flow bootstrap-template: AGENTS`
- `CLAUDE.md` 中的 `convergent-dev-flow bootstrap-template: CLAUDE`

此外，当前 host 上还应有直接证据表明：

- `gstack` 依赖已可用
- `superpowers` 依赖已可用

不要把 `README.md`、源码仓库根目录的 `AGENTS.md`、`INSTALL.md`、`docs/raw/`、`host-templates/`、`scripts/`、`Makefile` 或本地配置文件复制到宿主技能目录。

## 安装后怎么用

文件加载采用分层策略（详见 SKILL.md 分层加载策略）：

1. **核心层**（始终加载）：[SKILL.md](SKILL.md) + [flows/phase-order.md](flows/phase-order.md) + [references/gate-rubric.md](references/gate-rubric.md)
2. **阶段层**（按当前阶段加载）：对应 `flows/*.md` + `templates/*.md`
3. **守卫层**（按阶段加载相关守卫）：`guards/*.md`
4. **参考层**（按需加载）：`references/stage-rules.md`、`boundary-rules.md`、`source-system-mapping.md`
5. **辅助模板**（按需加载）：`templates/blocked.md`、`handoff.md`、`run-state.md`（可选）

安装后必须保持这些纪律：

- 显式触发，不依赖自动匹配
- `reframe` 显式调用 `gstack /office-hours`
- `plan` 显式调用 `gstack /plan-ceo-review` 与 `/plan-eng-review`
- 不跳过 `ticket`
- `build` 显式调用 `superpowers:test-driven-development`
- 发生故障或意外行为时，先调用 `superpowers:systematic-debugging`
- `review` 显式调用 `gstack /review`
- 不混合 `review` 和 `verify`
- `verify` 显式调用 `superpowers:verification-before-completion`
- 若验收依赖真实 UI / 浏览器用户流，`verify` 还要显式调用 `gstack /qa` 或 `/qa-only`
- `retro` 显式调用 `gstack /retro`
- 不在没有证据时宣称完成
- 不在没有 gate 或没有活动 ticket 时让 `superpowers` 推进实现
- 宿主新增永久规则时，只追加到 `AGENTS.md` / `CLAUDE.md`，不要改写 skill 包
- 宿主追加了永久规则后，后续升级走 `update existing install`，不要重新做 `bootstrap install`

## 不要这样安装

以下方式都不合规：

- 在这个公开 skill repo 里直接保留 `.agents/skills/convergent-dev-flow/` 或 `.claude/skills/convergent-dev-flow/` 作为主布局
- 只复制 `SKILL.md`，不复制支撑文件
- 直接把整个源码仓库根目录原样 `rsync` 到宿主技能目录
- 跳过 `INSTALL.md`，手工只装一侧宿主
- 在首次安装需要模板基线时不重写宿主 `AGENTS.md` / `CLAUDE.md`
- 在已有宿主永久规则时重复做 `bootstrap install`
- Claude 侧复制后不加 `disable-model-invocation: true`
- 把源码仓库自己的 `AGENTS.md` 直接当成宿主 `AGENTS.md`
- 把宿主仓库的永久规则写回这个 skill 里
- 让这个技能以隐式自动调用的方式运行

## 验证

本仓库提供 5 个可执行验证入口（维护工具，非 skill 运行时）：

| 层 | 命令 | 内容 | API 依赖 |
|---|---|---|---|
| Published Ref Probe | `make probe-install REF=refs/heads/main` | 验证某个已发布 ref 的 raw `INSTALL.md` 是否可直接访问 | 网络 |
| Tier 1 | `make tier1` | 14 个回归断言（RC-01~RC-14） | 无 |
| Tier 2 | `make tier2` | 21 个自检断言（SC-01~SC-21） | 无 |
| Tier 3 | `make tier3` | 27 个 LLM-as-judge 用例（TC + SG） | ANTHROPIC_API_KEY |
| Tier 4 | `make tier4` | 只用 Codex 的宿主黑盒验证，覆盖安装链路、显式下层 skill 调用审计与真实开发闭环 | Codex CLI + OpenAI auth + `conda` `py310` |

快速验证（无 API）：

```bash
make test
```

已发布 ref 的公开安装入口探测：

```bash
make probe-install REF=refs/heads/main
```

完整验证（含 LLM eval）：

```bash
export ANTHROPIC_API_KEY=sk-...
make all
```

Codex 黑盒宿主验证：

```bash
make tier4
make tier4 ARGS="--mode remote --source-ref refs/heads/main"
```

`make all` 仍然只覆盖 Tier 1-3；`probe-install` 与 `tier4` 单独执行，因为它们分别依赖已发布 ref 和 Codex CLI / OpenAI 额度。

Tier 3 支持单例运行：

```bash
make tier3 ARGS="--case TC-05"
make tier3 ARGS="--category trigger --verbose"
make tier3 ARGS="--output results.json"
```

## 进一步说明

- 运行方式见 [docs/usage.md](docs/usage.md)
- 来源系统映射见 [references/source-system-mapping.md](references/source-system-mapping.md)
- 自检见 [docs/self-check.md](docs/self-check.md)
- 验收标准见 [docs/acceptance.md](docs/acceptance.md)
