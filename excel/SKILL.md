---
name: excel
description: Excel CLI operations via nong. Trigger on .xlsx, worksheet listing, table reading, extracting data, creating workbooks, cell styling, formula writing, pivot tables, or converting treatment/value columns into grouped JSON for statistics.
---

# Excel

Use `nong` for deterministic Excel reads, simple workbook creation, and data preparation. Nong.Toolkit.Net routes to the CLI; do not create ad hoc Excel writer projects or bypass `nong`.

## Nong CLI Preflight

Read [../references/shared/nong-cli-preflight.md](../references/shared/nong-cli-preflight.md) before the first Nong command in a session. Confirm Nong.Cli.Net `4.1.0+` and the needed command group.
## Implemented Commands

```powershell
nong excel sheets <file.xlsx> [--json]
nong excel read <file.xlsx> [--sheet <name>] [--range <A1:D20>] [--json]
nong excel to-groups <file.xlsx> --group <col> --value <col> [--sheet <name>] [--json]
nong excel to-groups <file.xlsx> --group <col> --value <col> --raw > groups.json
nong excel create <spec.json> -o <out.xlsx> [--json]
nong excel dissect <file.xlsx> -o <slice-dir> [--json]
nong excel style <file.xlsx> <spec.json> -o <out.xlsx> [--json]
nong excel formula <file.xlsx> <spec.json> -o <out.xlsx> [--json]
nong excel pivot <file.xlsx> <spec.json> -o <out.xlsx> [--json]
```

## Dispatch

1. To list worksheets, run `nong excel sheets <file> --json`.
2. To inspect data, run `nong excel read <file> --json`; add `--sheet` and `--range` when known.
3. To prepare agricultural experiment data for statistics, run `nong excel to-groups ... --raw > groups.json`.
4. To create a simple workbook from JSON, write an Excel create spec and run `nong excel create spec.json -o out.xlsx --json`.
5. To create a unified NongPandoc package from a workbook, run `nong excel dissect <file.xlsx> -o <slice-dir> --json`, then use the `slice` skill for block-level reads.
6. To apply cell styles from a JSON spec, run `nong excel style <file> spec.json -o out.xlsx --json`.
7. To write formulas, run `nong excel formula <file> spec.json -o out.xlsx --json`.
8. To create a pivot table, run `nong excel pivot <file> spec.json -o out.xlsx --json`.
9. Feed raw grouped JSON directly into `nong chart analyze`, `anova`, `duncan`, or `bar`.
10. Do not promise dashboards, macros, or general Excel editing beyond what `nong commands --json` exposes.

## Create Spec

`excel create` supports simple sheets with headers and rows:

```json
{
  "sheets": [
    {
      "name": "Data",
      "headers": ["Treatment", "Yield"],
      "rows": [
        ["A", 1.2],
        ["A", 1.3],
        ["B", 2.1]
      ]
    }
  ]
}
```

Sheet names are required and must be 31 characters or fewer. `headers` and `rows` are required for each sheet.

## Groups JSON

`chart` commands expect:

```json
{
  "Control": [1.2, 1.3, 1.1],
  "Treatment": [2.0, 2.2, 2.1]
}
```

Use `--raw` for pipeline files. Use `--json` for model-readable reports.
