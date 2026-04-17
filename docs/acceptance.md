# 验收标准

只有以下各项全部成立，这个技能才算可接受。

## 必须满足

- reviewer 即使不看聊天记录，也能看懂阶段顺序、gate 和回退路径。
- `review` 与 `verify` 在阶段文档和模板中都被明确分离。
- `blocked` 被定义为正式结束状态。
- 技能明确写出 v1 不做什么。
- 技能明确防止自己退化成自由发挥型自治智能体。
- 运行时宪法保留了“产品工作期间不得改写 `AGENTS.md` / `CLAUDE.md` / 本技能”这条规则。
- 使用说明明确要求把常驻仓库规则放在技能之外。
- README 的安装节面向 LLM code agent，而不是手工复制说明。
- 仓库根目录存在显式的 `INSTALL.md` 安装说明。
- `INSTALL.md` 明确区分 `bootstrap install` 与 `update existing install`。
- `INSTALL.md` 只在 `bootstrap install` 或显式 reset 时重写宿主 `AGENTS.md` / `CLAUDE.md`。
- `INSTALL.md` 在 `update existing install` 中明确保留宿主现有 `AGENTS.md` / `CLAUDE.md`。
- `INSTALL.md` 要求记录本轮实际使用的 `SOURCE_REF`。
- `INSTALL.md` 在 `update existing install` 中要求记录宿主规则文件的前后校验值，并用它证明未被覆盖。
- 若对外宣称某个已发布 ref 的公开远端安装能力，必须先证明该 ref 的 raw `INSTALL.md` URL 返回 `200`。
- 仓库根目录存在宿主模板：`host-templates/AGENTS.md` 与 `host-templates/CLAUDE.md`。
- 安装说明支持 same-ref / pinned install，而不是只支持 upstream `main`。
- 共享 gate rubric 作为显式工件存在。
- `gstack`、`superpowers` 与 `harness engineering` 的来源映射作为显式工件存在。
- `gstack` 在文档中被落实为阶段骨架和角色化提问视角，而不是需求决策授权。
- `superpowers` 在文档中被落实为受 gate 和 active ticket 约束的执行辅助，而不是决策层。
- 示例显式覆盖四类必需场景：小型缺陷、小型功能、安全重构、阻塞运行。
- 额外负例不只有 happy path；负例需展示回退路径和 guard 拦截。
- 存在用于回归审查的自检文档。
- 评测用例覆盖触发检查、stage-gate 检查、回归检查 以及四类必需场景。
- 仓库根目录是规范技能包，而不是消费端镜像布局。
- 复制说明明确要求 Claude 侧副本加上 `disable-model-invocation: true`。
- 安装说明同时覆盖 Codex 与 Claude Code，而不是只覆盖单一宿主。
- bootstrap 模板存在可验证 marker，安装后可检查宿主文件是否由模板初始化。
- 默认行为是保守收敛，而不是自动扩权。
- `retro` 是强制阶段，不是可选项。
- 存在只用 Codex 的宿主黑盒验证入口，并显式锁定 `gpt-5.4`、`xhigh` 和 `py310`。
- `reframe` / `plan` / gate rubric 显式要求环境基线检查（解释器、包管理、权限/网络、持久化状态）。
- 推荐的阶段产物集中落盘目录作为显式约定存在。

## 不通过条件

若出现以下任意情况，这个技能必须被视为未完成：

- 某个阶段可以在没有显式上游输出的情况下被跳过。
- 可以在没有证据的情况下宣称完成。
- `review` 能被 `verify` 替代，或 `verify` 能被 `review` 替代。
- `blocked` 只是暗示存在，而不是显式存在。
- 技能在 v1 中引入了高自治执行行为。
- `gstack` 被写成了产品方向决策器。
- `superpowers` 可以在没有 gate 或没有活动 ticket 的情况下推进实现。

## review 增强验收条件

- `flows/review.md` 包含结构化审查项（Scope 对照、Plan 一致性、隐式默认搜索）。
- `templates/review.md` 包含复杂度审计和测试契约对照字段。
- `templates/review.md` 包含持久化状态升级风险字段。
- review 的结构化审查项覆盖了 ticket 边界、plan 一致性和隐式默认三个维度。
- review 的结构化审查项覆盖了持久化状态升级影响。
- review 模板输出能帮助 reviewer 判断变更是否超出最小必要范围。

## verify 增强验收条件

- `references/gate-rubric.md` 包含声明类型与证据类型分类（静态结构、行为、外部环境）。
- `flows/verify.md` 的 gate 条件引用了声明类型分类规则。
- `templates/verify.md` 包含证据来源和验证方法字段。
- `templates/verify.md` 包含持久化状态 / 迁移证据字段。
- 行为声明在环境缺失时只能标记为 `blocked` 或 `unverified`，不允许降级验证。

## 若提供可选 run-state，则必须满足

- `templates/run-state.md` 若存在，必须明确标记为可选。
- run-state 不进任何文件的 YAML frontmatter。
- run-state 不提供跨会话恢复协议。
- run-state 不替代阶段模板的正式输出。
