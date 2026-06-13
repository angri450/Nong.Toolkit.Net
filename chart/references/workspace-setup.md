# Chart Workspace Setup

Chart workflows in Nong.Toolkit.Net are CLI-first. A separate ChartCore project is not required for the supported command surface.

## Recommended Workspace

Keep specs, grouped data, figures, and optional QA output in a task-local directory:

```text
Nong Toolkit Workspace/
  chart/
    specs/
    data/
    figures/
    analysis/
```

## Smoke Commands

Statistics and bar chart from grouped JSON:

```powershell
nong chart analyze data\groups.json --json
nong chart bar data\groups.json -o figures\bar.png --json
```

Implemented spec-based charts:

```powershell
nong chart line specs\line.json -o figures\line.png --json
nong chart scatter specs\scatter.json -o figures\scatter.png --json
nong chart pie specs\pie.json -o figures\pie.png --json
```

Optional structural image QA:

```powershell
nong ocr analyze-image figures\line.png -o analysis\line --json
```

The QA command checks dimensions, whitespace, blankness, and content regions. It is not OCR, text recognition, or semantic understanding.

## Excel Bridge

When the source data is `.xlsx`, create grouped JSON first:

```powershell
nong excel to-groups data.xlsx --sheet Sheet1 --group Treatment --value Yield --raw > data\groups.json
```

Then pass `data\groups.json` to `chart analyze`, `anova`, `duncan`, or `bar`.

## Error Handling

Use `--json` and treat `status: "error"` as failure. For validation errors, fix the grouped JSON or chart spec and rerun the same command.

## Boundary

Do not install chart libraries or build custom rendering projects for Nong.Toolkit.Net routing. The current implemented chart surface is `analyze`, `bar`, `anova`, `duncan`, `line`, `scatter`, and `pie`.
