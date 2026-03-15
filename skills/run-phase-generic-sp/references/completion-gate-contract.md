# Completion Gate Contract

## 目标

在 `run-phase-generic-sp` 宣布当前票完成前，做一轮固定 completion gate，避免误把实现票收成 docs-only。

## 必答检查项

- `ticket_acceptance_satisfied`
- `verify_plan_present`
- `required_verify_commands_executed`
- `verify_passed`
- `evidence_sufficient`
- `latest_synced`
- `report_synced`
- `context_synced`
- `implementation_required`
- `docs_only_completion_detected`

## 允许的成功结论

- `ticket-complete`
  - acceptance 满足
  - verify 已执行且通过
  - evidence 足够
  - 所需 truth surface 已同步

## 允许的非最终结论

- `phase-ready-for-implementation`
- `needs-new-implementation-lane`
- `blocked-waiting-spec`
- `blocked-verify-failed`

## 禁止的伪完成

以下情况不得给出 `ticket-complete`：

- `implementation_required = true` 但没有真实实现改动
- 只更新了 `_STATUS / latest / CONTEXT_PACK`
- 只新增 scaffold / skeleton
- verify plan 存在但 required commands 未执行
- required commands 已执行但失败或证据不足
