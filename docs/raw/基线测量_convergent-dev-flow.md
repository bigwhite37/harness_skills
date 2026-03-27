# 基线测量：convergent-dev-flow

## 运行时文件清单

### 核心文件（始终加载）

| 文件 | 行数 |
|---|---|
| SKILL.md | 134 |
| flows/phase-order.md | 38 |
| references/gate-rubric.md | 79 |
| **小计** | **251** |

### 阶段文件（按当前阶段加载）

完整运行中会依次触达：
- 7 个 phase flow 文件：290 行
- 7 个 phase template 文件：336 行
- 8 个 guard 文件：120 行
- **阶段层与守卫层小计**：746 行

### 参考文件（按需加载）

| 文件 | 行数 |
|---|---|
| references/stage-rules.md | 30 |
| references/boundary-rules.md | 50 |
| references/source-system-mapping.md | 122 |
| references/anti-patterns.md | 按需，不纳入典型完整运行统计 |

## 全量统计

- 技能包主体文件数：44（按 README 的宿主安装范围，不含 `README.md`、`AGENTS.md`、`docs/raw/` 与本地配置文件）
- 技能包主体总行数：2,907
- 典型完整运行唯一加载文件数：28
- 典型完整运行唯一加载行数：1,199

## 典型单次运行加载路径

以 `reframe -> plan -> ticket -> build -> review -> verify -> retro` 完整运行为例：

1. **核心层**：`SKILL.md` + `flows/phase-order.md` + `references/gate-rubric.md` = 251 行
2. **阶段层**：7 个 phase flow 文件 + 7 个 phase template 文件 = 626 行
3. **守卫层**：8 个 guard 文件 = 120 行
4. **参考层**：`stage-rules` + `boundary-rules` + `source-system-mapping` = 202 行
5. **总计**：1,199 行（不含 examples、evals、可选辅助模板和 `docs/raw/`）

## 重复热点摘要

重复内容详见 `docs/raw/重复热点_convergent-dev-flow.md`。

主要重复区域：
- "来源视角" 在 7 个 flows 中重复（每处 ~6-8 行）
- "来源约束" 在 9 个 templates 中重复（每处 ~3-4 行）
- "允许回退" 和 "禁止动作" 在 phase-order 和 stage-rules 间重复
