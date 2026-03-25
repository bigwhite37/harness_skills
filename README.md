# convergent-dev-flow

这是一个公开的系统级技能 git repo。仓库根目录就是技能包本体，不是消费端镜像目录。

这个技能用于把单个非平凡开发任务固定在以下阶段机内推进：

`reframe -> plan -> ticket -> build -> review -> verify -> retro`

它融合了三层能力：

- `gstack`：阶段骨架和角色化审视视角
- `superpowers`：受 gate 和活动 ticket 约束的低自由度执行增强
- `harness engineering`：gate、evidence、quick fail、blocked、retro 纪律

这个仓库的规范源码结构见：

- [SKILL.md](SKILL.md)
- [docs/usage.md](docs/usage.md)
- [AGENTS.md](AGENTS.md)

## 给代码智能体的结论

如果你要安装这个技能，不要把整个仓库继续嵌套成“repo 里再放 `.agents/skills/...`”。正确做法是：

1. 把当前仓库根目录视为规范技能包。
2. 把这个根目录下的技能文件复制到目标仓库的技能目录。
3. 在目标仓库里显式触发，不依赖自动匹配。

## 安装到 Codex

在目标仓库根目录执行：

```bash
mkdir -p .agents/skills/convergent-dev-flow
rsync -a --exclude '.git' /path/to/harness_skills/ .agents/skills/convergent-dev-flow/
```

安装后触发：

```text
$convergent-dev-flow
```

Codex 侧还应配合宿主安全边界：

- 优先使用 sandbox
- 优先使用 approvals
- 不要把这个技能放到高自治默认配置里

## 安装到 Claude Code

这份 git repo 可以被 Claude Code 使用，但不是“直接把当前仓库根目录当成已安装 skill 目录”来使用。正确方式是：

- 把当前仓库根目录当作规范技能包来源；
- 复制到目标仓库的 `.claude/skills/convergent-dev-flow/`；
- 给复制后的 `SKILL.md` 增加 `disable-model-invocation: true`；
- 然后在目标仓库里用 `/convergent-dev-flow` 显式触发。

在目标仓库根目录执行：

```bash
mkdir -p .claude/skills/convergent-dev-flow
rsync -a --exclude '.git' /path/to/harness_skills/ .claude/skills/convergent-dev-flow/
```

然后编辑复制后的 `SKILL.md`，在 frontmatter 中加入：

```yaml
disable-model-invocation: true
```

安装后触发：

```text
/convergent-dev-flow
```

Claude Code 侧还应配合宿主安全边界：

- 使用权限机制收紧这个技能
- 配置 `allowed-tools`
- 保留 `disable-model-invocation: true`

如果你只是想验证这个公开 repo 的技能能否被 Claude Code 消费，可以在单独的测试仓库里按上面的方式复制安装。不要把 `.claude/skills/convergent-dev-flow/` 目录直接提交回这个源码仓库作为主布局。

## 最小安装校验

复制完成后，目标仓库中至少应存在：

- `SKILL.md`
- `flows/`
- `guards/`
- `templates/`
- `references/`
- `examples/`
- `docs/`
- `evals/`

如果缺少以上任一项，就不是完整技能包。

## 安装后怎么用

最小读取顺序：

1. 先读 [SKILL.md](SKILL.md)
2. 再读 [flows/phase-order.md](flows/phase-order.md)
3. 再读 [references/gate-rubric.md](references/gate-rubric.md)
4. 根据当前阶段加载对应 `flows/*.md`
5. 根据需要加载 `guards/*.md` 和 `templates/*.md`

安装后必须保持这些纪律：

- 显式触发，不依赖自动匹配
- 不跳过 `ticket`
- 不混合 `review` 和 `verify`
- 不在没有证据时宣称完成
- 不在没有 gate 或没有活动 ticket 时让 `superpowers` 推进实现

## 不要这样安装

以下方式都不合规：

- 在这个公开 skill repo 里直接保留 `.agents/skills/convergent-dev-flow/` 或 `.claude/skills/convergent-dev-flow/` 作为主布局
- 只复制 `SKILL.md`，不复制支撑文件
- Claude 侧复制后不加 `disable-model-invocation: true`
- 把宿主仓库的永久规则写回这个 skill 里
- 让这个技能以隐式自动调用的方式运行

## 进一步说明

- 运行方式见 [docs/usage.md](docs/usage.md)
- 来源系统映射见 [references/source-system-mapping.md](references/source-system-mapping.md)
- 自检见 [docs/self-check.md](docs/self-check.md)
- 验收标准见 [docs/acceptance.md](docs/acceptance.md)
