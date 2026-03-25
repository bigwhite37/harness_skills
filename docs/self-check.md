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
- `gstack` 是否仍然只承担阶段骨架和角色化提问视角？
- `superpowers` 是否仍然只承担受 gate 和 active ticket 约束的执行辅助？
- `harness engineering` 是否仍然只承担 gate、evidence、fail 和 retro 的 veto 纪律？

## 防漂移检查

- 是否有改动把 脚本、hooks、subagents、并行工作、部署、发布或其他副作用工作流 带入了 v1？
- 是否有改动让 `gstack` 从阶段骨架变成需求方向决策者？
- 是否有改动让 superpowers 从执行辅助变成决策者？
- 是否有改动让这个技能表现得像通用自治智能体？
- 是否有改动删掉了四类必需示例或对应的 eval 覆盖？
- 是否有改动把消费端 `.agents/` 或 `.claude/` 镜像目录重新引入为 repo 主布局？
- 复制说明是否丢失了 Claude 的 `disable-model-invocation: true` 要求？

如果防漂移检查中任意一项答案为“是”，这个技能就不再合规。
