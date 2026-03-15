# Compact Context Packet Contract

## 目标

在正式编译需求前，先生成一份紧凑、稳定、可复用的 `Context Packet`。

## 必填字段

- `request_summary`
- `phase_guess`
- `lane_guess`
- `current_blockers`
- `current_carry_forward`
- `must_read_truth_files`
- `preferred_reuse_skills`
- `high_impact_boundaries`
- `related_paths`
- `minimum_verify`
- `recommended_next_step`

## 字段含义

- `request_summary`
  - 用一句话概括用户真正要什么。
- `phase_guess` / `lane_guess`
  - 无法稳定判断时允许写 `unknown`。
- `current_blockers` / `current_carry_forward`
  - 来自仓库 truth page，而不是主观猜测。
- `must_read_truth_files`
  - 当前最值得读取的事实文件，默认不超过 `5` 个。
- `preferred_reuse_skills`
  - 最相关的后续 skills，默认不超过 `3` 个。
- `high_impact_boundaries`
  - 只列与这次请求直接相关的语义边界。
- `related_paths`
  - 本轮最需要读写的路径，默认不超过 `6` 个。
- `minimum_verify`
  - 本轮最小验证动作。
- `recommended_next_step`
  - 下一条可执行动作。

## 推荐展示格式

```text
## Context Packet
- request_summary:
- phase_guess:
- lane_guess:
- current_blockers:
- current_carry_forward:
- must_read_truth_files:
- preferred_reuse_skills:
- high_impact_boundaries:
- related_paths:
- minimum_verify:
- recommended_next_step:
```

## 紧凑性规则

- 超过上限时，用 `(+N more)` 汇总
- phase/lane 已稳定时，不要为了“完整”继续追加 index 清单
