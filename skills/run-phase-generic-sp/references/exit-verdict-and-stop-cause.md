# Exit Verdict And Stop Cause

## Canonical Exit Verdicts

- `ticket-complete`
- `phase-ready-for-implementation`
- `blocked-waiting-spec`
- `blocked-verify-failed`
- `needs-new-implementation-lane`
- `loop-risk-reconsider-approach`
- `invalid-phase-or-ticket`
- `user-paused`

## 推荐 Stop Cause 映射

- `ticket-complete`
  - `stop_cause = none`
- `phase-ready-for-implementation`
  - `stop_cause = planning_only_stop`
- `blocked-waiting-spec`
  - `stop_cause = high_impact_under_specified`
- `blocked-verify-failed`
  - `stop_cause = verification_failed`
- `needs-new-implementation-lane`
  - `stop_cause = missing_impl_lane`
- `loop-risk-reconsider-approach`
  - `stop_cause = loop_stuck` 或 `loop_suspected`
- `invalid-phase-or-ticket`
  - `stop_cause = invalid_phase_or_ticket`
- `user-paused`
  - `stop_cause = user_pause`

## 记录规则

- `exit_verdict` 与 `stop_cause` 必须同时出现
- 如果暂时无法稳定判定 verdict，可写 `unknown`，但不要退化成自由文本
- `implementation-required` 票不得用 `phase-ready-for-implementation` 掩盖 verify 或 evidence 缺口
