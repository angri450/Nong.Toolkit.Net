# 2026-06-11 multi-plugin marketplace + skills.sh launch

## What changed

Toolkit 从单 plugin + `@angri450` 命名重构为多 plugin marketplace + `@nong-toolkit` 命名，同时接入 skills.sh 生态。

### Multi-plugin marketplace

每个 skill 目录现在有独立的 `.claude-plugin/plugin.json`（`"skills": ["./"]`），用户按需安装：

```
claude plugin install word@nong-toolkit       (~78 tok)
claude plugin install chart@nong-toolkit      (~78 tok)
claude plugin install nong-toolkit@nong-toolkit    (full bundle)
```

Marketplace 17 个 plugin：1 个全量包 + 16 个独立 skill。

### Marketplace 命名统一

| 层 | 旧值 | 新值 |
|----|------|------|
| marketplace name | `angri450` | `nong-toolkit` |
| plugin name | `nong-toolkit` | `nong-toolkit` |

安装命令从 `claude plugin install nong-toolkit@angri450` 变为 `claude plugin install nong-toolkit@nong-toolkit`。`@` 前后一致。

### Plugin Infrastructure 文档

CLAUDE.md 新增"Plugin Infrastructure"部分：
- `marketplace.json` + `plugin.json` 必须共存
- Marketplace name 不能重名（两个仓库同名会互相覆盖）
- Marketplace name = project name，不用人名
- 完整 `marketplace.json` 字段表（5 top-level + 6 per-plugin）

### skills.sh 接入

- `skills.sh.json` 改为标准 `groupings` 格式：Documents / Analysis / Governance
- `npx skills add angri450/Nong.Toolkit.Net` 测试通过 — 发现 16 个 skill，安装到 71 个 agent
- Telemetry 已上报，页面等待索引刷新

### Global CLAUDE.md 模板重构

Section 6-7-8 精简：
- Section 6 Credential（删除）→ 移入项目 CLAUDE.md
- Section 7 Skill lifecycle 完整规则（删除）→ 移入项目 CLAUDE.md
- Section 8 CLI 命令表（删除）→ 移入项目 CLAUDE.md
- Section 6 Shell → 新增，禁止 PowerShell/Bash 工具混用，引用 Nong.Dev.Net
- Section 3 Language → 新增中文引号禁令
- Section 6 Deliverables（原 8）

### Skill governance 规则

Toolkit CLAUDE.md 新增完整 skill 治理规则：
- 五个农业人格表
- Every skill must have（5 条）
- Gate checklist
- CLI-mirror naming rule
- CLI → skill sync

## Problems solved

1. `E Plugin nong-toolkit not found in marketplace angri450` — marketplace name 冲突，改为 `nong-toolkit`
2. `Marketplace file not found` — 新建仓库漏建 `marketplace.json`
3. Token 浪费 — 用户只能全量安装（~1600 tok），现在可按需（~40-80 tok）
4. `@angri450` 不直观 — 改为 `@nong-toolkit`，自解释

## Files touched

- `.claude-plugin/marketplace.json` — 重写，name 改 `nong-toolkit`，plugins 数组 17 条目
- `.claude-plugin/plugin.json` — root bundle plugin
- `*/word, pdf, ..., skill-pruner/.claude-plugin/plugin.json` — 16 个独立 plugin.json，新增
- `skills.sh.json` — 重写为标准 groupings 格式
- `CLAUDE.md` — 新增 Plugin Infrastructure + 字段表 + multi-plugin 结构
- `README.md` / `README.zh-CN.md` — 全量更新，多 plugin 安装语法
- `skill.zh` — 更新安装命令
- `copy-to-your-global-instructions.md` — 精简为纯行为规则，6→7 节
