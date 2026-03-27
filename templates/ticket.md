# `ticket` 模板

## 目的

定义一个可执行工作单元。一个 ticket，只解决一个问题。

## 输入

- 已通过的 `plan` 输出
- 当前活动范围

## 输出

- Ticket ID
- 目标
- 边界
- 输入
- 预期产物
- 验收点
- 停止条件

## 通过条件

这个 ticket 足够小，能在一次 `build -> review` 循环中关闭，且不会混入无关风险。

## 来源约束

> 来源约束见 references/boundary-rules.md

## 模板

```md
## Ticket

Ticket 编号:
目标:
边界:
输入:
预期产物:
验收点:
- 
停止条件:
```
