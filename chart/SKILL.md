---
name: chart
description: >
  Statistical analysis and chart generation for academic papers. MUST use this skill
  when the user wants to create bar charts with error bars, run ANOVA + Duncan multiple
  range test, generate publication-quality figures, analyze experimental data, or
  combine multiple charts. Also trigger when the user mentions chart, 图表, 柱形图,
  箱线图, 统计分析, ANOVA, 方差分析, Duncan, 显著性, 误差线, 实验数据, or 作图 —
  even if they do not explicitly say "chart". This skill works with the word skill
  (insert charts into papers) and the excel skill (prepare data for analysis).
---

# ChartCore — Statistical Chart Intelligence

Two capabilities, loaded on demand:

- **Analyze** (ANOVA + Duncan) — load [chart-api.md](references/chart-api.md)
- **Chart** (generate figures) — load [chart-api.md](references/chart-api.md)

## Dependencies

- .NET SDK (`dotnet` command available)

If missing, stop immediately and tell the user to install. Do not attempt to fix.

## Dispatch Logic

1. User mentions "analyze", "ANOVA", "Duncan", "方差分析", "显著性" → statistical analysis
2. User mentions "画图", "柱形图", "图表", "chart", "bar", "误差线", "figure" → chart generation
3. Both → analyze first (stats inform chart labels), then chart
4. User mentions "拼接", "combine", "合并" → chart combine

## Cross-Skill Flow

| Step | Skill | Role |
|------|-------|------|
| 1. Data preparation | Excel | Create .xlsx with raw data |
| 2. Statistical analysis | Chart | ANOVA + Duncan → significance letters |
| 3. Chart generation | Chart | Bar charts with error bars + significance |
| 4. Chart combine | Chart | Merge multiple figures into one panel |
| 5. Paper insertion | Word | Insert figures into academic paper |

## Core Operations

### Analyze (ANOVA + Duncan)

Write a `Program.cs` that uses `StatsEngine`, then:

```powershell
dotnet run --project <project-path> -- analyze <data.json>
```

Output: ANOVA table (F, p, group stats) + Duncan MRT groups with significance letters. Also outputs structured JSON for downstream use.

### Chart (generate figure)

```powershell
dotnet run --project <project-path>
```

Generates PNG charts. Typical flow: `DataLoader` → `StatsEngine` → `ChartBuilder` → PNG output.

### Combine

```powershell
dotnet run --project <project-path> -- combine <fig1.png> <fig2.png> <fig3.png> <out.png>
```

Merges multiple charts horizontally with A/B/C labels.

### Validate

```powershell
.\scripts\validate-chart.ps1 <output.png>
```

Checks: file exists → non-zero size → reasonable dimensions. Reports PASS/FAIL.

## Workspace

First use: create the .NET project:

```powershell
dotnet new console -n ChartWriter -o <target-dir> --force
dotnet add <target-dir> package Angri450.Nong.Chart
```

Then write a `Program.cs` template. See [workspace-setup.md](references/workspace-setup.md) for the full template and details.

After setup, each session only modifies `Program.cs`. Output goes to `~/Documents/GroundPA Toolkit Workplace/output/`.

## Color Schemes

See [formats/INDEX.md](formats/INDEX.md). Default scheme is colorblind-friendly (blue/orange/green/yellow).
