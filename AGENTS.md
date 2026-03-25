# AGENTS 说明

本仓库用于存放可复用的系统级技能库，不是业务应用仓库。

## 常驻规则

- 永远成立的仓库规则放在这里，不要塞进技能的运行时流程文件。
- 将 `docs/raw/system_skill_设计说明.md` 视为 `convergent-dev-flow` 第一版的设计依据。
- `convergent-dev-flow` 在 v1 中必须保持为纯指令型。
- v1 不要加入脚本、hooks、subagents、并行 ticket、部署流程或其他高自治行为。
- 保持固定流程：`reframe -> plan -> ticket -> build -> review -> verify -> retro`。
- 保持 harness 约束：快速失败、禁止静默回退、禁止隐式默认、必须提供证据、显式 phase gate、强制 retro。
- 必须分离 `review` 和 `verify`。
- 不要把工作流逻辑重新塞回这个文件。按任务触发的工作流行为应保留在仓库根目录技能包中：`SKILL.md`、`flows/`、`guards/`、`templates/`、`references/`、`examples/`、`docs/`、`evals/`。

## 期望的技能包结构

`convergent-dev-flow` 技能包应保持以下结构：

- `SKILL.md`
- `flows/`
- `guards/`
- `templates/`
- `references/`
- `examples/`
- `docs/`
- `evals/`

本仓库是规范源码包。宿主侧技能路径只是下游复制目标，不是本仓库的主布局：

- Codex 目标路径：`.agents/skills/convergent-dev-flow/`
- Claude Code 目标路径：`.claude/skills/convergent-dev-flow/`
- Claude 侧复制时，必须在 `SKILL.md` frontmatter 中加入 `disable-model-invocation: true`。
- 下游安装时，应使用宿主权限机制收紧这个技能的执行边界：
  - Codex 侧优先依赖 sandbox / approvals。
  - Claude Code 侧优先依赖权限机制、`allowed-tools` 和 `disable-model-invocation: true`。

## 变更纪律

- 优先做增量收紧，不要为“更强”而扩功能。
- 任何新能力都必须先保护收敛性和可控性。
- 如果一项改动让技能更像自治智能体，默认应视为可疑。
