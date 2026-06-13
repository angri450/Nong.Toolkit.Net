# Excel Workspace Setup

Excel workflows in GroundPA are CLI-first. A separate Excel writer project is not required for the supported command surface.

## Recommended Workspace

Keep inputs and outputs in a task-local directory, for example:

```text
GroundPA Toolkit Workplace/
  excel/
    specs/
    input/
    output/
```

Use normal file writes only for JSON specs and output paths, then call `nong`.

## Smoke Commands

Create a workbook from a spec:

```powershell
nong excel create specs\workbook.json -o output\workbook.xlsx --json
```

Inspect the workbook:

```powershell
nong excel sheets output\workbook.xlsx --json
nong excel read output\workbook.xlsx --sheet Data --json
```

Prepare chart input:

```powershell
nong excel to-groups output\workbook.xlsx --sheet Data --group Treatment --value Yield --raw > output\groups.json
```

## Error Handling

Use `--json` for agent-facing commands and treat `status: "error"` as failure. Common fixes are correcting the file path, sheet name, A1 range, group column, value column, or create spec shape.

## Boundary

Do not install Excel libraries or build custom .NET writer projects for GroundPA routing. If the user needs unsupported Excel authoring features, state that the current `nong excel` CLI only exposes `sheets`, `read`, `to-groups`, and `create`.
