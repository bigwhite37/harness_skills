# Context Economy

## 目标

在不损失判断稳定性的前提下，控制 discovery 和输出的上下文体积。

## Tiered Discovery

优先使用 `Tier-1`，只有在不足以判断边界时才进入 `Tier-2`。

### Tier-1

- `_STATUS` 或等价状态页
- `CONTEXT_PACK` 或等价上下文页
- 当前最相关的 `latest`
- 用户直接点名的文件

### Tier-2

仅在以下情况才扩大读取：

- `phase` 仍然不明确
- `lane` 仍然不明确
- 高影响边界仍然不明确
- 需要确认 index / handover / campaign 命名

## 输出压缩规则

- `must_read_truth_files` 默认最多 `5` 条
- `related_paths` 默认最多 `6` 条
- `preferred_reuse_skills` 默认最多 `3` 条
- 同一结论不要在人话摘要和机器骨架里各写一长遍

## Reuse-First 原则

当方向已经稳定时，应尽快把后续动作交给 repo-local 执行 skill，而不是继续膨胀 planning 上下文。
