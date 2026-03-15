# Context Economy And Delta Refresh

## 目标

减少 driver 在长阶段里重复读取、重复输出同一批 truth 文件。

## Tiered Discovery

### Phase Start / First Entry

首次进入当前阶段时，最少读取：

- `AGENTS.md` 或等价全局约束页
- 状态页
- `CONTEXT_PACK`
- 当前阶段最相关的 latest
- 当前 ticket

### Fallback

只有在以下情况才扩大读取：

- 阶段标识不稳定
- lane 不稳定
- wrapper 是否存在不清楚
- 当前票需要额外确认 handover / campaign / exit / spec

## Delta Refresh Rule

第一张票之后，不要每票做全量 discovery。默认只刷新：

- 当前 ticket
- 状态页
- 当前阶段 latest
- 当前阶段 campaign（若本票需要写）
- `CONTEXT_PACK`（若本票需要写）

只有在 phase、lane、wrapper 决策或高影响边界变化时，才重新扩展 discovery。

## Compact Output Rule

每票输出优先写：

- 当前票 verdict
- 当前票 blocker / carry-forward delta
- 本票真实 verify 结果
- 下一条命令

不要每票重复复述：

- 整个阶段历史背景
- 已确认不变的 blocker/carry-forward 全表
- 已确认不变的入口索引列表
