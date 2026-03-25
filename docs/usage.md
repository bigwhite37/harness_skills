# 使用说明

这个技能必须显式触发。不要依赖自动匹配。

- Codex：`$convergent-dev-flow`
- Claude Code：复制后使用 `/convergent-dev-flow`，并加上 `disable-model-invocation: true`

## 适用场景

当单个非平凡开发任务需要以下特性时，使用 `convergent-dev-flow`：

- 清晰的阶段控制
- 显式 gate
- 以证据为基础的验证
- 强制 `retro`

以下场景不要使用：

- 没有任务边界的开放式 头脑风暴
- 并行自治智能体工作
- 部署或发布流程
- 顺手展开的大范围 refactor

## 运行方式

1. 从 `reframe` 开始。
2. 使用对应模板产出当前阶段输出。
3. 检查 `flows/` 中对应阶段的 gate。
4. 应用 `guards/` 中相关守卫。
5. 只有在以上条件满足后，才能进入下一阶段。
6. 以 `retro` 结束。
7. 只有在 工作流已经结束后，才输出 `handoff` 作为摘要产物。

## 来源系统分工

- `gstack`
  - 提供阶段骨架和角色化提问视角。
  - 它帮助这个技能决定“怎么分阶段想”，不决定产品方向。
- `superpowers`
  - 提供文件操作、任务拆解、多步骤执行和上下文组织这类低自由度执行增强。
  - 它只能在已经过 gate 的阶段和已经激活的 ticket 内工作。
- `harness engineering`
  - 提供 gate、evidence、quick fail、blocked 和 retro 纪律。
  - 它只负责 veto，不负责替 `reframe` 或 `plan` 选方向。

具体映射见 `references/source-system-mapping.md`。

## Vendoring

将这个技能复制到其他仓库时：

1. 将本仓库根目录视为规范技能包。
2. 将该包文件复制到宿主仓库的技能目录中。
3. Codex 侧放入 `.agents/skills/convergent-dev-flow/`。
4. Claude Code 侧放入 `.claude/skills/convergent-dev-flow/`，并在 `SKILL.md` frontmatter 中加入 `disable-model-invocation: true`。
5. 同时使用宿主权限机制收紧执行边界：
   - Codex 侧优先使用 sandbox / approvals。
   - Claude Code 侧优先使用权限机制、`allowed-tools` 和 `disable-model-invocation: true`。
6. 宿主仓库永远生效的规则应保留在它自己的 `AGENTS.md` 或 `CLAUDE.md` 中。
7. 不要把 flow 文件内联进宿主仓库指令。
8. 在新宿主中的评测还未稳定前，始终显式触发这个技能。

## 最小加载集

始终加载：

- `SKILL.md`
- `flows/phase-order.md`
- `references/gate-rubric.md`
- 当前阶段文件
- 相关 guard 文件

只有在生成对应输出时，才加载相应模板。

## 必守纪律

- 同一时间只允许一个活动 ticket
- 不得混合 `review` / `verify`
- 不得无证据宣称完成
- 不得 静默回退
- 不得隐藏式扩范围

## 宿主职责分离

- 永远生效的仓库规则应放在 `AGENTS.md` 或 `CLAUDE.md`
- 这个技能只负责工作流控制
