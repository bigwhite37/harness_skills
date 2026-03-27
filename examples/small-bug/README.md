# 小型缺陷示例

这个示例展示了一个 小型缺陷修复 的合规运行闭环。

## 来源系统体现

- `gstack`：用固定阶段机推进，并在 `reframe` / `plan` / `review` / `verify` 中采用问题澄清、风险检查和对抗式审查视角。
- `superpowers`：只在活动 ticket 内做受控实现和检查，不决定需求方向，也不扩 scope。
- `harness engineering`：要求显式 gate、显式证据、显式未验证项，并以 `retro` 强制收尾。

## `reframe`

> 可选轻量状态记录（见 templates/run-state.md）：
>
> ```
> run_id: small-bug-001
> current_phase: reframe
> phase_status: in_progress
> active_ticket:
> completed_outputs:
> blockers:
> ```

任务陈述:
修复一个小型 parser 缺陷：当前空输入会直接崩溃，而不是返回受控错误。

成功标准:
- 空输入不再崩溃
- 该行为有直接证据验证

非目标:
- 不做 parser 重设计
- 不做无关清理

假设:
- 空输入应被处理，而不是由调用方契约拒绝

未知项:
- 现有测试是否已经覆盖这条路径

阻塞项:
- 无

完成定义:
ticket 被实现、review、verify 并以 `retro` 收尾。

## `plan`

已选方案:
在 parser 入口加最小 guard，并用聚焦测试验证。

被拒绝的替代方案:
- 更大范围的 parser refactor
- 输入 normalization 重写

影响区域:
- parser 入口
- 一个聚焦测试文件

主要风险:
- 行为变化超出空输入场景

验证契约:
- acceptance: 空输入返回受控错误
  evidence: 聚焦测试结果

回滚思路:
如果入口 guard 意外扩展了行为，就回滚它。

## `ticket`

Ticket 编号: T1
目标: 在不崩溃的情况下处理空输入
边界: parser 入口加一个聚焦测试
输入: 已批准的 plan
预期产物: 最小代码改动与一个定向测试
验收点:
- 空输入不再崩溃
- 定向测试证明返回了受控结果
停止条件:
如果必须改变更广泛的 parser 行为，则返回 `plan`。

## `build`

当前 Ticket: T1

变更文件:
- 路径: parser 入口文件
  原因: 增加最小空输入 guard
- 路径: 聚焦 parser 测试
  原因: 固定所需行为

新发现问题:
- 无

## `review`

状态: 通过

问题:
- 严重度: 低
  问题: 确保新 guard 只影响空输入
  修复: 在 `verify` 中确认范围

范围漂移:
- 无

隐藏回退:
- 无

## `verify`

验收点 -> 证据:
- 空输入不再崩溃 -> 聚焦测试通过并返回受控错误
- 定向测试证明返回了受控结果 -> 测试输出显示断言符合预期

已执行检查:
- 命令: 聚焦 parser 测试命令
  结果: 通过

未验证项:
- 本最小示例未运行完整 parser 回归套件

阻塞项:
- 无

剩余风险:
- 更广泛回归在运行更全面测试前仍未验证

结论:
`verified`

## `retro`

保留:
- 在 `build` 前先写验证契约

修改:
- 增加一个提醒：在未运行更大范围回归时，应显式标记为未验证

移除:
- 任何把聚焦测试等同于完整 parser 信心的表述

流程后续:
- 继续让 `verify` 明确写出哪些内容没有检查

## 交接

最终状态: `verified`
改动内容:
- 为空输入增加了最小 parser guard
- 增加了定向回归测试

已验证:
- 空输入处理行为

阻塞或未验证:
- 本示例中的完整 parser 回归套件仍未验证
