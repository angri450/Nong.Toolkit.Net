---
name: excel
description: >
  Read and write Excel spreadsheets (.xlsx, .xlsm, .csv) with full formatting intelligence.
  MUST use this skill when the user wants to create spreadsheets, financial models, dashboards,
  or trackers; read, parse, or extract data from .xlsx files; edit or update workbooks; work
  with formulas, charts, or templates; import CSV/TSV data; add data validation and dropdown menus.
  Trigger when the user mentions spreadsheet, workbook, Excel, .xlsx, financial model, tracker,
  dashboard, 电子表格, 图表, 下拉, 数据验证, or 数据透视 — even if they do not explicitly say
  "excel". Do NOT trigger when the primary deliverable is a Word document, HTML report, or Python script.
---

# ExcelCore — Excel Document Intelligence

Two independent capabilities, loaded on demand:

- **Read Excel** → load [read-excel.md](references/read-excel.md)
- **Write Excel** → load [write-excel.md](references/write-excel.md)

## Dependencies

- .NET SDK 11.0 (`dotnet --version` must work)

If missing, stop immediately and tell the user to install. Do not attempt to fix.

## Dispatch Logic

1. User mentions "analyze", "read", "extract", "data", "structure" → **load read-excel.md**
2. User mentions "generate", "create", "write", "build", "report", "chart" → **load write-excel.md**
3. Both → read first, then write

## Core Operations

### Preview

Always run a text preview after generating xlsx — this is the AI's "eyes":

```csharp
var result = ExcelPreview.Preview(path);
Console.WriteLine(result.Text);
```

Formulas shown as `[=SUM(A1:A10)]`, errors as `#ERR:`, truncation as `###`. Warnings must be fixed, never ignored.

### Validate

```powershell
.\scripts\validate-xlsx.ps1 <output.xlsx>
```

4 checks: ZIP structure → formula error markers → column width overflow → file size. Only deliver after PASS.

### Safe Write

For files with non-ASCII content, use Base64 encoding to avoid tool-layer corruption:

```powershell
.\scripts\safe-write.ps1 <target-path> <base64-content>
```

**CRITICAL: safe-write.ps1 must use the PowerShell tool, never Bash.** Prefer the Write tool for direct file writes when possible; use safe-write only when Write is unavailable.

## Workspace

First use: create the .NET project with two commands:

```powershell
dotnet new console -n ExcelWriter -o <target-dir> --force
dotnet add <target-dir> package Angri450.Nong.Excel
```

Then write a `Program.cs` template. See [workspace-setup.md](references/workspace-setup.md) for the full template and details.

After setup, each session only modifies `Program.cs`. Output always goes to `~/Documents/GroundPA Toolkit Workplace/output/`.

## Format Library

See [formats/INDEX.md](formats/INDEX.md). Color schemes, number format reference, conditional formatting templates.

## Formula Safety

Three iron rules when writing formulas:

1. All computable values must use formulas, never hardcode results
2. All `/` operations must wrap in `IFERROR(x/y, 0)` or `IF(y=0, 0, x/y)`
3. All VLOOKUP must wrap in `IFERROR(VLOOKUP(...), "")`
