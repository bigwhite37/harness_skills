# `verify` 阶段

## 目的

把"我觉得对"变成"有证据表明对"。

## 输入

- 已通过 `review` 的变更
- 来自 `plan` 的验证契约
- 可用执行环境
- `superpowers:verification-before-completion`
- 若验收涉及真实 UI / 浏览器用户流，则需要 `gstack` 的 `/qa` 或 `/qa-only`

## 必需输出

- `superpowers:verification-before-completion` 的验证命令与结果
- 若适用，`gstack` `/qa` 或 `/qa-only` 的结论
- 验收点到证据的映射
- 检查结果
- 剩余风险
- 未验证项

## Gate

- 已显式使用 `superpowers:verification-before-completion`
- 若验收依赖真实 UI / 浏览器用户流，已显式使用 `gstack` 的 `/qa` 或 `/qa-only`，或因其不可用而进入 `blocked`
- 每条成功标准都必须有直接证据，或被明确标记为 `blocked` / `unverified`
- 必需检查要么已执行，要么其未执行原因被明确正当化
- 结论必须与证据严格一致
- 证据类型应匹配声明类型，分类规则见 references/gate-rubric.md
- 若任务依赖环境基线或持久化状态升级，这些声明也必须有直接证据，或被明确标记为 `blocked` / `unverified`

## 来源视角

> 来源系统视角映射见 references/source-system-mapping.md

## 失败条件

- 未使用 `superpowers:verification-before-completion` 就宣称通过
- 需要真实 UI / 浏览器验收时，没有运行 `gstack` 的 `/qa` 或 `/qa-only`
- 没有运行检查，却假定其会通过
- 结果含糊，却被当作通过
- 环境不可用时，静默用更弱检查替代
- 证据与结论相矛盾
- 最强表述只能是“应该可以”

## 失败去向

返回 `build` 或 `plan`；若环境/权限缺失无法补救，则输出 `blocked`。
