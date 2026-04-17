# `verify` 模板

## 目的

把验收标准转化为显式证据。

## 输入

- 已通过 `review` 的变更
- 验证契约
- 新鲜的检查结果

## 输出

- `superpowers:verification-before-completion` 证据
- 若适用，`gstack /qa` 或 `/qa-only` 结论
- 验收点到证据的映射
- 检查状态
- 剩余风险
- `unverified` 或 `blocked` 项

## 通过条件

已显式运行 `superpowers:verification-before-completion`，且每个验收点都有直接证据，或被显式标记为 `blocked` / `unverified`。

## 来源约束

> 来源约束见 references/boundary-rules.md

## 模板

```md
## 验证

verification-before-completion:
- 调用结果:
- 使用的最终验证命令:

gstack /qa or /qa-only:
- 是否适用:
- 调用结果:
- 关键发现:

验收点 -> 证据:
-

证据来源:
-

验证方法:
-

已执行检查:
- 命令:
  结果:

持久化状态/迁移证据:
- 

未验证项:
- 

阻塞项:
- 

剩余风险:
- 

结论:
```
