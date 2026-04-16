# `ticket` 阶段

## 目的

将 `plan` 拆成小而可执行的单元，避免 `build` 自由膨胀。

## 输入

- 已通过 gate 的 `plan` 输出

## 必需输出

- 有顺序的 ticket 列表
- 一个活动 ticket
- 对每个 ticket：目标、边界、验收点、停止条件

## Gate

- 只能有一个活动 ticket
- 每个 ticket 都足够小，能在一次 `build -> review` 循环中关闭
- ticket 集合忠于原始范围
- ticket 之间不存在循环依赖

## 来源视角

> 来源系统视角映射见 references/source-system-mapping.md

## 失败条件

- ticket 只是主题，不是可执行单元
- ticket 体量过大
- 单个 ticket 横跨过多模块
- 推进需要并行 ticket 执行

## 失败去向

返回 `plan`。
