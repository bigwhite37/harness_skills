# Anti-Loop Observation Contract

## 目标

防止 driver 在同一个错误路径上反复编辑、反复跑同一失败命令。

## 推荐阈值

- `repeated_edit_count >= 3`
  - 同一文件在同一票内连续返工
- `repeated_cmd_count >= 2`
  - 同一命令连续失败且失败原因没有变化

## 达到阈值后的要求

必须：

- 给出 `exit_verdict = loop-risk-reconsider-approach`
- 给出 `stop_cause = loop_stuck` 或 `loop_suspected`
- 明确提示回看：
  - `spec`
  - `ticket acceptance`
  - 当前 assumption / boundary

## 数据不可得时

如果当前没有可靠计数来源：

- 不要伪造 `repeated_edit_count / repeated_cmd_count`
- 允许写：
  - `repeated_edit_count = null`
  - `repeated_cmd_count = null`
  - `anti_loop_status = observational_only`
