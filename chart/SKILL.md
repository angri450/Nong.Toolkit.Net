---
name: chart
description: Agricultural statistics and chart CLI via nong. Trigger on ANOVA, Duncan MRT, 方差分析, 显著性, treatment groups, error bars, bar charts, line charts, scatter plots, or pie charts.
---

# Chart

Use `nong` for statistical analysis and implemented figure generation. GroundPA routes to the CLI; do not recreate chart rendering logic in scripts or temporary projects.

## Prerequisites

Run once before work:

```powershell
nong commands --json
```

If `nong` is missing, tell the user to install:

```powershell
dotnet tool install --global Angri450.Nong.Cli
```

## Implemented Commands

```powershell
nong chart analyze <groups.json> [--alpha 0.05] [--json]
nong chart anova <groups.json> [--json]
nong chart duncan <groups.json> [--alpha 0.05] [--json]
nong chart bar <groups.json> -o <out.png> [--title <text>] [--ylabel <text>] [--error sem|none] [--no-significance] [--json]
nong chart line <spec.json> -o <out.png> [--json]
nong chart scatter <spec.json> -o <out.png> [--json]
nong chart pie <spec.json> -o <out.png> [--json]
```

## Dispatch

1. For one-shot agricultural treatment analysis, run `nong chart analyze <groups.json> --json`.
2. For ANOVA only, run `nong chart anova <groups.json> --json`.
3. For Duncan multiple comparison only, run `nong chart duncan <groups.json> --json`.
4. For a publication-style bar chart with optional significance letters, run `nong chart bar <groups.json> -o <out.png> --json`.
5. For trends, use `nong chart line <spec.json> -o <out.png> --json`.
6. For x/y relationships, use `nong chart scatter <spec.json> -o <out.png> --json`.
7. For composition shares, use `nong chart pie <spec.json> -o <out.png> --json`.
8. If data starts in Excel, use `excel to-groups --raw` first for analysis/bar charts.
9. Do not promise box plots, histograms, heatmaps, radar charts, combined panels, or figure editing unless a future `nong commands --json` exposes those as implemented CLI commands.

## Input Contracts

Grouped JSON for `analyze`, `anova`, `duncan`, and `bar`:

```json
{
  "Control": [1.2, 1.3, 1.1],
  "Treatment": [2.0, 2.2, 2.1]
}
```

Line chart spec:

```json
{
  "title": "Growth",
  "xLabel": "Days",
  "yLabel": "Height",
  "series": [
    { "name": "A", "x": [0, 7, 14], "y": [1.0, 2.0, 3.0] }
  ]
}
```

Scatter plot spec:

```json
{
  "title": "Correlation",
  "xLabel": "pH",
  "yLabel": "Yield",
  "points": [
    { "x": 6.1, "y": 12.3, "group": "A" }
  ],
  "trendline": true
}
```

Pie chart spec:

```json
{
  "title": "Composition",
  "values": [
    { "label": "A", "value": 30 },
    { "label": "B", "value": 70 }
  ]
}
```

Treat `E006 validation_failed` as a data or spec problem to fix before analysis or rendering.

## Optional Visual QA

After generating a PNG, you may suggest:

```powershell
nong ocr analyze-image fig.png -o fig.analysis --json
```

This is structural image QA for dimensions, blankness, whitespace, and content regions. It is not OCR, text recognition, or semantic understanding of the figure.
