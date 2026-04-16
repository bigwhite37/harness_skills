# Installing `convergent-dev-flow` Into a Host Repository

这份文档面向 **LLM code agent**。默认假设你当前位于 **宿主仓库根目录**，而不是 `harness_skills` 源码仓库。

## Goal

完成一次双宿主安装或升级：

- `bootstrap install`
  - 安装 Codex skill：`.agents/skills/convergent-dev-flow/`
  - 安装 Claude Code skill：`.claude/skills/convergent-dev-flow/`
  - 直接按本仓库模板重写宿主 `AGENTS.md`
  - 直接按本仓库模板重写宿主 `CLAUDE.md`
- `update existing install`
  - 更新 Codex / Claude Code 的 skill 包
  - 保留宿主现有 `AGENTS.md` / `CLAUDE.md`

`bootstrap install` 是 **破坏性** 操作。若目标仓库里已有宿主永久规则，重复执行 bootstrap 会覆盖这些规则。

## Source Repo

- canonical repo: `https://github.com/bigwhite37/harness_skills.git`
- default ref when no explicit ref is provided: `refs/heads/main`

ref 选择规则：

1. 若用户显式给出 branch / tag / commit，使用该 ref。
2. 若 `INSTALL.md` 来自 branch / tag / commit 特定 URL，使用与该 URL 相同的 ref。
3. 只有在以上两项都不存在时，才默认使用 `refs/heads/main`。

也就是说：能保持 `same ref` 时，就保持 `same ref`；不要把 branch/tag/commit 安装偷偷改写成 `main`。

优先把源码 clone 或更新到一个临时目录，再从临时目录复制安装内容。不要依赖不明来源的本地残留副本，也不要在指定了 same-ref / pinned install 时偷偷漂到 `origin/main`。

## Install Contract

你必须先判定模式，再执行：

在任何模式下，先记录：

- `SOURCE_REPO`
- `SOURCE_REF`

`SOURCE_REF` 必须是这次安装实际使用的 branch/tag/commit。不要只在脑中判断；要把它写进安装过程记录和最终汇报。

### Bootstrap install

满足以下任一条件时，使用 bootstrap：

- 宿主尚未安装 `convergent-dev-flow`
- 用户明确要求 reset 宿主 `AGENTS.md` / `CLAUDE.md`

bootstrap 必须完成：

1. 获取指定 ref 的源码到临时目录。
2. 在宿主仓库中创建或重建以下目录：
   - `.agents/skills/convergent-dev-flow/`
   - `.claude/skills/convergent-dev-flow/`
3. 复制 skill 包内容到两个目录：
   - `SKILL.md`
   - `flows/`
   - `guards/`
   - `templates/`
   - `references/`
   - `examples/`
   - `evals/`
   - `docs/usage.md`
   - `docs/self-check.md`
   - `docs/acceptance.md`
4. 用源码仓库中的宿主模板 **直接重写**：
   - `AGENTS.md` <- `host-templates/AGENTS.md`
   - `CLAUDE.md` <- `host-templates/CLAUDE.md`
5. 编辑 Claude 副本的 `SKILL.md` frontmatter，加入：
   - `disable-model-invocation: true`
6. 做安装后校验，并向用户汇报。

### Update existing install

若宿主已安装过该 skill，且用户没有明确要求 reset 宿主规则文件，则使用 update。

update 必须完成：

1. 获取指定 ref 的源码到临时目录。
2. 更新：
   - `.agents/skills/convergent-dev-flow/`
   - `.claude/skills/convergent-dev-flow/`
3. 在更新前记录宿主规则文件快照或校验值，例如：
   - `AGENTS_BEFORE_SHA`
   - `CLAUDE_BEFORE_SHA`
4. 保留现有：
   - `AGENTS.md`
   - `CLAUDE.md`
5. 继续确保 Claude 副本的 `SKILL.md` frontmatter 中存在：
   - `disable-model-invocation: true`
6. 更新后再次记录：
   - `AGENTS_AFTER_SHA`
   - `CLAUDE_AFTER_SHA`
7. 对照前后值，确认宿主规则文件未被本轮覆盖。
8. 做安装后校验，并向用户汇报。

## Files You Must Not Copy Into Host Skill Dirs

以下文件或目录不属于宿主 skill 包：

- 源码仓库根目录的 `README.md`
- 源码仓库根目录的 `AGENTS.md`
- `INSTALL.md`
- `host-templates/`
- `docs/raw/`
- `scripts/`
- `Makefile`
- 本地配置文件

## Required Host Layout

安装后，宿主仓库至少应包含：

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

## Frontmatter Requirement For Claude Copy

`.claude/skills/convergent-dev-flow/SKILL.md` 的 frontmatter 必须包含：

```yaml
disable-model-invocation: true
```

如果该字段缺失，Claude Code 侧安装不合规。

## Suggested Procedure

你可以使用等价命令，但必须满足上面的安装契约。

### 1. Clone or refresh source

使用一个临时路径，例如：

```bash
TMP_DIR="${TMPDIR:-/tmp}/harness_skills_install"
```

如果目录不存在，则 clone；如果已存在，则 fetch 并切换到目标 ref。只有在 ref 未指定时，才默认到 `refs/heads/main`；若已指定 same-ref / pinned install，不得偷偷刷新到 `origin/main`。安装记录中必须保留最终使用的 `SOURCE_REF`。

### 2. Rebuild target skill directories

只重建以下两个目标目录，不要碰宿主仓库里的无关路径：

- `.agents/skills/convergent-dev-flow/`
- `.claude/skills/convergent-dev-flow/`

### 3. Copy the package

把规范 skill 包复制到两个目标目录。`docs/` 只复制下列 3 个文件：

- `docs/usage.md`
- `docs/self-check.md`
- `docs/acceptance.md`

### 4. Rewrite host permanent-rule files

直接覆盖：

- `AGENTS.md`
- `CLAUDE.md`

仅在 `bootstrap install` 或用户明确要求 reset 时执行。不要做 merge，不要保留旧内容，不要把 skill 的阶段机内联进这两个文件。

### 4b. Preserve host permanent-rule files during update

在 `update existing install` 中：

- 不要改写 `AGENTS.md`
- 不要改写 `CLAUDE.md`
- 若宿主已在这两个文件中追加永久规则，必须保留
- 用 update 前后的快照或校验值证明这两个文件未被本轮覆盖

### 5. Patch the Claude skill copy

只改 Claude 副本：

- path: `.claude/skills/convergent-dev-flow/SKILL.md`
- change: insert `disable-model-invocation: true` into frontmatter

Codex 副本不要添加该字段。

## Post-Install Verification

至少验证以下事实：

1. 两侧 skill 目录都存在。
2. 安装记录中存在：
   - `SOURCE_REPO`
   - `SOURCE_REF`
3. 两侧 skill 目录都包含 `SKILL.md`、`flows/`、`guards/`、`templates/`、`references/`、`examples/`、`evals/` 和 `docs/`。
4. 两侧 skill 目录都包含：
   - `docs/usage.md`
   - `docs/self-check.md`
   - `docs/acceptance.md`
5. 若本轮是 `bootstrap install` 或显式 reset，`AGENTS.md` 中存在：
   - `convergent-dev-flow bootstrap-template: AGENTS`
6. 若本轮是 `bootstrap install` 或显式 reset，`CLAUDE.md` 中存在：
   - `convergent-dev-flow bootstrap-template: CLAUDE`
7. `AGENTS.md` 中显式出现 `$convergent-dev-flow`。
8. `CLAUDE.md` 中显式出现 `/convergent-dev-flow`。
9. `.claude/skills/convergent-dev-flow/SKILL.md` 中存在 `disable-model-invocation: true`。
10. 若本轮是 `update existing install`，存在：
    - `AGENTS_BEFORE_SHA`
    - `AGENTS_AFTER_SHA`
    - `CLAUDE_BEFORE_SHA`
    - `CLAUDE_AFTER_SHA`
11. 若本轮是 `update existing install`，确认：
    - `AGENTS_BEFORE_SHA == AGENTS_AFTER_SHA`
    - `CLAUDE_BEFORE_SHA == CLAUDE_AFTER_SHA`

## Report Back To The User

完成后，用简短结果汇报：

- 你创建或重写了哪些路径
- 这次安装实际使用的 `SOURCE_REF`
- Codex / Claude Code 两侧是否都安装成功
- Claude 副本是否已补 `disable-model-invocation: true`
- 若本轮是 `update existing install`，宿主规则文件的前后校验结果
- 是否发现任何阻塞

不要在汇报里粘贴整份文件全文；只列关键路径和结果。
