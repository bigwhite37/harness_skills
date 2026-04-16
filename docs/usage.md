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

将这个技能安装到其他仓库时：

1. 在宿主仓库根目录，让代码代理读取源码仓库根的 `INSTALL.md` 并执行安装。
2. 安装器必须先判定当前是：
   - `bootstrap install`
   - `update existing install`
3. 安装器会 clone / 更新源码仓库，并同时安装：
   - `.agents/skills/convergent-dev-flow/`
   - `.claude/skills/convergent-dev-flow/`
4. 只有在 `bootstrap install` 或用户明确要求 reset 时，安装器才会按 `host-templates/` 下的模板重写宿主：
   - `AGENTS.md`
   - `CLAUDE.md`
5. 在 `update existing install` 中，安装器必须保留宿主现有 `AGENTS.md` / `CLAUDE.md`。
6. Claude Code 侧副本必须在 `SKILL.md` frontmatter 中加入 `disable-model-invocation: true`。
7. 同时使用宿主权限机制收紧执行边界：
   - Codex 侧优先使用 sandbox / approvals。
   - Claude Code 侧优先使用权限机制、`allowed-tools` 和 `disable-model-invocation: true`。
8. 宿主仓库永远生效的规则应保留在它自己的 `AGENTS.md` 或 `CLAUDE.md` 中；安装后若需要补充，继续在宿主文件中追加。
9. 宿主已经追加了永久规则后，后续升级走 `update existing install`，不要重新做 `bootstrap install`。
10. 不要把 flow 文件内联进宿主仓库指令。
11. 不要把源码仓库根目录的 `AGENTS.md` 直接复制成宿主 `AGENTS.md`。
12. 若用户需要与当前 branch/tag/commit 一致的安装结果，应使用 same-ref / pinned install，不要默认漂到 upstream `main`。
13. 在新宿主中的评测还未稳定前，始终显式触发这个技能。

## 最小加载集

加载策略详见 SKILL.md 分层加载策略。简要说明：

### 始终加载

- `SKILL.md`
- `flows/phase-order.md`
- `references/gate-rubric.md`

### 按阶段加载

- 当前阶段的 `flows/{阶段}.md`
- 当前阶段的 `templates/{阶段}.md`（生成输出时）
- 相关 `guards/*.md`

### 按需加载

- `references/stage-rules.md`、`boundary-rules.md`、`source-system-mapping.md`
- `templates/blocked.md`、`handoff.md`
- `templates/run-state.md`（可选轻量状态记录）

## 必守纪律

- 同一时间只允许一个活动 ticket
- 不得混合 `review` / `verify`
- 不得无证据宣称完成
- 不得 静默回退
- 不得隐藏式扩范围

## 宿主职责分离

- 永远生效的仓库规则应放在 `AGENTS.md` 或 `CLAUDE.md`
- 这个技能只负责工作流控制
- 安装器在 `bootstrap install` 中负责生成宿主 `AGENTS.md` / `CLAUDE.md` 的最小基线
- 安装器在 `update existing install` 中必须保留宿主已有业务规则
