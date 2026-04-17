# `build` 阶段

## 目的

在当前 ticket 内做最小必要变更，而不是顺手优化整个系统。

## 输入

- 活动 ticket
- 仓库约定
- 现有代码模式
- `superpowers:test-driven-development`
- 出现异常时的 `superpowers:systematic-debugging`

## 必需输出

- `superpowers:test-driven-development` 的 RED/GREEN 证据
- 针对活动 ticket 的代码、测试或文档变更
- 触达文件说明
- 新发现的问题

## Gate

- 已在进入实现前显式使用 `superpowers:test-driven-development`
- 变更与活动 ticket 直接对应
- 没有未经批准的额外内容
- 变更可以被清楚解释
- 在进入 `review` 前已完成基础自检，不把明显坏状态交给 review

## 来源视角

> 来源系统视角映射见 references/source-system-mapping.md

## 失败条件

- 未使用 `superpowers:test-driven-development` 就直接写实现
- 发生测试失败、bug 或意外行为时，没有先用 `superpowers:systematic-debugging`
- 要完成当前工作必须扩范围
- 出现了新的依赖或新的决策
- 局部修补膨胀成区域性重写
- 在没有结构性进展的情况下反复打补丁

## 失败去向

返回 `ticket` 或 `plan`。
