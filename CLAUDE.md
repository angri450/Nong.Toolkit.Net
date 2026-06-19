# Nong.Toolkit.Net — Skill 层

Claude Code skill 编排层。维护 Nong 家族的 Skills + Agent 编排文档。

项目特有规则见本文件，共享设定见 `../../.claude/CLAUDE.md`。

## 信息源

`../../.claude/PROJECT_STATE.md` 是全家桶唯一真相源。`../../.claude/references/agent-rules.md` 有本项目 agent 行为约束。

本项目的 `PROJECT_STATE.md`、`AGENTS.md` 等开发文件已全部迁到 `../../.claude/`。

## 先读那里

`../../.claude/PROJECT_STATE.md` 是跨仓库真相源。`../../.claude/plans/` 是施工方案。`../../.claude/changelog/` 是变更记录。

本项目的开发文件已全部迁到 `../../.claude/`。项目根目录只保留源码和插件清单。

## 当前开发状态

- 版本线: 与 Nong.Cli.Net 主版本同步（当前适配 12.1.0）
- Skill 同步状态: 已同步到 12.1.0 实际命令面 (332 commands)
- 当前技能数: 18（word / excel / pptx / pdf / chart / diagram / ocr / literature / aminer / metaso / inspect / genre / icons / slice + 4 skill-* lifecycle）
- Skills 缺口: export / markdown / nongcli / search 命令组在 Cli.Net 中已实现（v12.1.0 / 332 commands），Toolkit.Net 尚未建立对应 skill 目录
- 本次更新: v4.5.0→v12.1.0 全线贯通
- 仓库地址: `https://github.com/angri450/Nong.Toolkit.Net`

## 项目特有约束

- pkg 目录: 安装包分发，不走 npm
- 每个 Skill 有独立的 `SKILL.md` + `references/` 目录
- Skill 文档是路由层，详细规则放 references
- 安装方式: `claude plugin install <name>@nong-toolkit`
- 不发 NuGet

## 目录结构

```
Nong.Toolkit.Net/
  .claude-plugin/           ← 插件清单 (marketplace.json + plugin.json)
  word/                     ← Word skill
  pdf/                      ← PDF skill
  literature/               ← 文献搜索 / 本地缓存 skill
  aminer/                   ← AMiner API skill
  metaso/                   ← Metaso 搜索 / reader / chat skill
  inspect/                  ← 论文审查 skill
  excel/                    ← Excel skill
  chart/                    ← 统计图表 skill
  diagram/                  ← 科学绘图 skill
  pptx/                     ← PPTX skill
  ocr/                      ← OCR skill
  genre/                    ← 文档模板 skill
  icons/                    ← 科学图标 skill
  slice/                    ← Pandoc 切片 skill
  slice/                    ← Pandoc 切片 skill
  skill-grader/             ← Skill 生命周期门控
  skill-breeder/            ← Skill 创作指南
  skill-tester/             ← Skill 质量测试
  skill-pruner/             ← Skill 生命周期治理
```
