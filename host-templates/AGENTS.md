<!-- convergent-dev-flow bootstrap-template: AGENTS -->

# Repository Instructions

本仓库默认使用 `convergent-dev-flow` 处理非平凡开发任务。

## Permanent Rules

- 永远成立的仓库规则写在这里，不要把按任务触发的阶段机、gate、guards、模板或运行时流程抄回 `AGENTS.md`。
- 对非平凡开发任务，先显式触发 `$convergent-dev-flow`。
- 对闲聊、翻译、纯总结、一次性问答或极小的单步变更，不要强制套用这个 skill。
- 工作流逻辑保留在 `.agents/skills/convergent-dev-flow/`，不要把 `flows/`、`guards/`、`templates/` 的内容重新内联到宿主常驻说明文件。
- 产品工作期间，不要改写 `AGENTS.md`、`CLAUDE.md` 或 skill 本体；流程改进建议记录到 `retro`。
- 依赖 Codex 的 sandbox / approvals 收紧执行边界，不要把这个 skill 放进高自治默认配置。
- 这是 `convergent-dev-flow` 的 bootstrap 模板；重复执行 bootstrap 会重写本文件。
- 如果宿主仓库需要额外永久规则，继续追加在本文件中；后续升级请走 update 路径，不要重新 bootstrap。
