# `run-state` 模板

## 目的

提供可选的轻量状态记录，帮助跟踪单次运行的进度。这不是必需文件，也不是恢复协议。

## 使用限制

- **可选**：运行时可以不使用此模板，不影响工作流合规性。
- **不进 frontmatter**：run-state 信息不写入任何文件的 YAML frontmatter。
- **不做恢复协议**：run-state 只记录当前状态，不提供跨会话恢复能力。
- **不替代阶段输出**：每个阶段的正式输出仍由对应模板产出。
- **推荐集中落盘**：若要把阶段产物写入仓库，优先放在 `.convergent-dev-flow/runs/<run_id>/` 下，避免散落在业务目录中。

## 推荐字段

```md
## 运行状态

run_id:
current_phase:
phase_status: pending | in_progress | passed | failed | blocked
active_ticket:
completed_outputs:
-
blockers:
-
artifacts_dir:
```

## 字段说明

- `run_id`：本次运行的标识，建议用时间戳或短 hash。
- `current_phase`：当前所处阶段（reframe / plan / ticket / build / review / verify / retro）。
- `phase_status`：当前阶段的状态。
- `active_ticket`：当前活动 ticket 编号（如有）。
- `completed_outputs`：已通过 gate 的阶段输出列表。
- `blockers`：当前阻塞项（如有）。
- `artifacts_dir`：推荐的阶段产物目录，例如 `.convergent-dev-flow/runs/<run_id>/`。

## 不推荐字段

- `history`：不记录完整阶段历史，避免膨胀。
- `retry_count`：不跟踪重试次数，重试应通过阶段回退显式处理。
- `elapsed_time`：不记录耗时，与工作流纪律无关。

## 模板

```md
## 运行状态

run_id:
current_phase:
phase_status:
active_ticket:
completed_outputs:
-
blockers:
-
artifacts_dir:
```
