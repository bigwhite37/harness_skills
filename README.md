# harness_skills

这个仓库只用于维护可复用的、仓库无关的 harness skills。

当前提供：

- `skills/harness-engineering`
- `skills/run-phase-generic-sp`

## 设计目标

- 不绑定单一仓库的 phase 命名、目录命名、truth 页面命名
- 保留 harness 风格的需求编译能力
- 通过 `repo-adapter` 适配不同仓库的文档入口与验证命令
- 输出结构稳定，便于人读与 grader / eval 抓取

## 当前目录结构

```text
harness_skills/
├── README.md
└── skills/
    └── harness-engineering/
        ├── SKILL.md
        ├── agents/
        │   └── openai.yaml
        └── references/
            ├── compact-context-packet-contract.md
            ├── context-economy.md
            ├── output-contract-template.md
            ├── repo-adapter.md
            └── trigger-boundary.md
    └── run-phase-generic-sp/
        ├── SKILL.md
        ├── agents/
        │   └── openai.yaml
        └── references/
            ├── anti-loop-observation-contract.md
            ├── completion-gate-contract.md
            ├── context-economy-and-delta-refresh.md
            ├── exit-verdict-and-stop-cause.md
            └── repo-adapter.md
```

## 使用方式

把 `skills/harness-engineering` 复制到目标仓库的 `.agents/skills/` 下，然后由目标仓库自己的：

- `AGENTS.md`
- phase / tasks / reports / latest / spec 结构
- repo 本地验证命令

共同决定最终行为。

这个仓库本身不绑定任何单独项目事实。
