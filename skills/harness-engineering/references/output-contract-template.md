# Output Contract Template

## 目标

统一 `harness-engineering` 的输出骨架，让人和评估器都能稳定读取。

## 必需区块

```text
## 人话摘要
- 本轮做了什么:
- 结果是什么:
- 还剩什么:
- 下一步是什么:

## Classification
- request_type:
- lane:
- chosen_phase:
- high_impact:

## Reuse Decision
- routed_to_existing_skill:
- why_not_direct_execution:

## Artifacts
- create:
- update:

## Implementation Lane
- implementation_lane_required:
- why:

## Verify Plan
- blocking_checks:
- commands:

## Propagation Plan
- latest_updates:
- report_updates:
- context_updates:

## Next Action
- recommended_skill:
- command_or_prompt:
```

## 规则

- `人话摘要` 必须放最前面
- 字段名保持稳定，方便 grader 抓取
- `implementation_lane_required` 必须显式写 `true / false`
- `routed_to_existing_skill` 建议只用固定枚举值，例如：
  - `none`
  - `phase-wrapper`
  - `run-phase-generic-sp`
  - `phase-kickoff-generic`
  - `run-tickets-sp`
  - `verify-correctness`

## 紧凑规则

- `create / update` 默认每组最多显式列 `3` 条路径
- `latest_updates / report_updates / context_updates` 默认每组最多显式列 `2` 条路径
- 路径很多时先按 artifact class 汇总，剩余用 `(+N more)` 表达
