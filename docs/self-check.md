# 自检清单

每次编辑这个技能后，都应使用这份清单。

## 阶段纪律

- 这个技能是否仍然强制执行 `reframe -> plan -> ticket -> build -> review -> verify -> retro`？
- 是否仍然显式禁止隐藏式跳阶段？
- 是否定义了回退路径，同时不允许自由漂移？

## Harness 纪律

- 快速失败是否仍作为显式停止规则存在？
- 是否仍然明确禁止静默回退？
- 是否仍然禁止隐式默认？
- 是否仍然要求先有证据才能宣称完成？
- 是否仍然明确禁止在产品工作中自我改写？
- `retro` 是否仍然是强制阶段？

## 输出纪律

- `review` 和 `verify` 是否仍然清晰分离？
- `blocked` 是否仍然是一等结果？
- 是否仍然强制同一时间只有一个活动 ticket？
- 是否仍然存在共享的 gate rubric？
- `verify` 是否仍然要求“验收点到证据”的映射？

## 来源系统检查

- `references/source-system-mapping.md` 是否仍然存在且与当前文档一致？
- `gstack` 是否仍然通过显式技能调用承担阶段骨架和角色化提问视角？
- `superpowers` 是否仍然通过显式技能调用承担受 gate 和 active ticket 约束的执行辅助？
- `harness engineering` 是否仍然只承担 gate、evidence、fail 和 retro 的 veto 纪律？

## 防漂移检查

- 是否有改动把 脚本、hooks、subagents、并行工作、部署、发布或其他副作用工作流 带入了 v1？
- 是否有改动让 `gstack` 从阶段骨架变成需求方向决策者？
- 是否有改动让 superpowers 从执行辅助变成决策者？
- 是否有改动把 `convergent-dev-flow` 退回成“只吸收方法论、不显式调用外部技能”的 standalone 版本？
- 是否有改动让这个技能表现得像通用自治智能体？
- 是否有改动删掉了四类必需示例或对应的 eval 覆盖？
- 是否有改动把消费端 `.agents/` 或 `.claude/` 镜像目录重新引入为 repo 主布局？
- 复制说明是否丢失了 Claude 的 `disable-model-invocation: true` 要求？
- `INSTALL.md` 是否仍然存在，并要求代码代理只在 `bootstrap install` 或显式 reset 时重写宿主 `AGENTS.md` / `CLAUDE.md`？
- `host-templates/AGENTS.md` 与 `host-templates/CLAUDE.md` 是否仍然存在并显式引用 skill 触发方式？
- README 安装节是否仍然使用面向 agent 的 `Fetch and follow instructions .../INSTALL.md` 入口？
- README / INSTALL 的最小安装校验是否仍然覆盖 `docs/usage.md`、`docs/self-check.md`、`docs/acceptance.md`？
- 安装后随 skill 包复制的 `docs/usage.md` 是否仍然避免引用不会被安装进去的相对路径（如 `../INSTALL.md`）？
- README / INSTALL 是否清晰区分了 `bootstrap install` 与保留宿主规则的 `update` 路径？
- README / INSTALL 是否支持按同一 branch/tag/commit 安装，而不是强制漂到 upstream `main`？
- `INSTALL.md` 是否要求记录本轮实际使用的 `SOURCE_REF`？
- `INSTALL.md` 是否要求安装或校验 `gstack` 与 `superpowers` 依赖？
- 若对外宣称某个已发布 ref 的公开安装入口可用，是否要求先证明该 ref 的 raw `INSTALL.md` 返回 `200`？
- `INSTALL.md` 是否要求在 `update existing install` 中记录宿主规则文件的前后校验值，并用它证明未被覆盖？
- README、`Makefile` 注释和 `scripts/tier2_selfcheck.sh` 的 Tier 2 断言数量是否一致？
- 是否存在只用 Codex 的宿主黑盒验证入口，并显式锁定 `gpt-5.4`、`xhigh` 和 `py310`？

## run-state 检查

- `templates/run-state.md` 是否明确标记为可选？
- run-state 是否未被写入任何文件的 YAML frontmatter？
- 是否给出了推荐的阶段产物集中落盘目录，例如 `.convergent-dev-flow/runs/<run_id>/`？

## review/verify 增强检查

- `flows/review.md` 是否包含结构化审查项（Scope 对照、Plan 一致性、隐式默认搜索）？
- `flows/review.md` 是否显式检查持久化状态升级影响？
- `flows/reframe.md` / `flows/plan.md` / `flows/review.md` / `flows/retro.md` 是否都显式要求对应的 `gstack` 调用？
- `flows/build.md` / `flows/verify.md` 是否显式要求对应的 `superpowers` 调用？
- `references/gate-rubric.md` 是否包含声明类型与证据类型分类？
- `templates/verify.md` 是否包含证据来源和验证方法字段？
- `templates/review.md` 和 `templates/verify.md` 是否都覆盖了持久化状态 / 迁移风险记录？

## 环境基线检查

- `flows/reframe.md`、`flows/plan.md` 与 `references/gate-rubric.md` 是否都要求显式检查解释器、包管理、权限/网络和持久化状态基线？
- `templates/reframe.md` 与 `templates/plan.md` 是否都为环境基线和状态升级路径预留了字段？

如果防漂移检查中任意一项答案为”是”，这个技能就不再合规。
