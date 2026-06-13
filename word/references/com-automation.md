# Word COM Automation Escape Hatch

Nong.Toolkit.Net's normal Word path is `nong word ...`. Do not use desktop Microsoft Word COM automation for ordinary DOCX reading, formatting inspection, table extraction, template filling, or edits.

Use COM only when all of these are true:

1. The user explicitly wants installed Microsoft Word to be driven.
2. The task requires Word's layout/visual engine and `nong` cannot provide the needed fact.
3. The environment is Windows with Microsoft Word installed.
4. The script can tolerate COM flakiness and clean up after itself.

## Known Failure Modes

| Failure | Cause | Required handling |
|---------|-------|-------------------|
| `Marshal.GetActiveObject()` missing | PowerShell 7 runs on .NET Core/.NET, where this API is unavailable | Do not depend on it. Prefer `New-Object -ComObject Word.Application`; if attaching is explicitly required, use a compatibility path such as `Microsoft.VisualBasic.Interaction.GetObject()` with null checks. |
| `$table.Cell($r, $c)` HRESULT failure | Merged cells make some row/column coordinates invalid | Avoid naive row/column traversal. Use `$table.Range` operations, iterate real cells, or wrap each cell lookup in `try/catch`. |
| Output file locked after prior runs | Word COM objects or WINWORD processes were not closed/released | Use unique output paths, close documents, quit the Word instance you created, release COM objects, and force GC. Do not blanket-kill all WINWORD processes unless the user explicitly approves and unsaved work risk is acceptable. |
| `$doc` is null after attaching | Existing Word instance has no active document or has exited | Always verify `$word`, `$word.Documents.Count`, and `$doc` before use. Prefer opening the file yourself instead of relying on the active document. |
| Large object dumps in console | COM methods return objects and PowerShell writes them to the pipeline | Suppress returns with `[void]...` or `| Out-Null`. |
| `Rows.Item(1).Select()` fails on merged rows | Word disallows selecting some complex merged row shapes | Avoid `Select()` and UI selection. Prefer range APIs or split before complex rows when appropriate. |
| `.doc` output instead of `.docx` | `SaveAs(..., 0)` means old binary Word document | Use `SaveAs2(..., 16)` for default DOCX or `12` for XML DOCX. |
| Visible Word windows | `$word.Visible = $true` was set | Use `$word.Visible = $false` for background processing. |
| `Borders.Item("wdBorderTop")` type error | COM expects integer enum values, not enum names as strings | Pass integer constants such as `-1` for top border. |

## Hardened Pattern

Use this pattern only as an escape hatch:

```powershell
#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$inputPath = [System.IO.Path]::GetFullPath($inputPath)
$outputPath = [System.IO.Path]::GetFullPath($outputPath)

if (-not (Test-Path -LiteralPath $inputPath)) {
    throw "Input DOCX not found: $inputPath"
}

if (Test-Path -LiteralPath $outputPath) {
    Remove-Item -LiteralPath $outputPath -Force
}

$word = $null
$doc = $null
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0

    $doc = $word.Documents.Open($inputPath)
    if ($null -eq $doc) {
        throw "Word opened no document: $inputPath"
    }

    # Do work here. Suppress COM return values:
    # [void]$table.ConvertToText(0)

    # 16 = wdFormatDocumentDefault (.docx). 12 = wdFormatXMLDocument (.docx).
    $formatDocx = 16
    [void]$doc.SaveAs2([ref]$outputPath, [ref]$formatDocx)
}
finally {
    if ($null -ne $doc) {
        try { [void]$doc.Close([ref]$false) } catch { }
        [void][System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($doc)
    }
    if ($null -ne $word) {
        try { [void]$word.Quit() } catch { }
        [void][System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($word)
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
```

## Merged Table Rules

Do not assume a merged table is rectangular at the COM coordinate level.

Avoid this as a default:

```powershell
$cell = $table.Cell($r, $c)
```

Safer patterns:

```powershell
try {
    $cell = $table.Cell($r, $c)
    # Use the cell
}
catch {
    # This coordinate may be swallowed by a merged cell.
}
```

or operate on a range:

```powershell
$range = $table.Range
```

Avoid `Select()` unless the user explicitly needs UI selection. It fails on some merged rows and is unnecessary for most automation.

## Word Enum Constants

Use integers for Word COM enum values:

```powershell
$wdFormatDocumentDefault = 16
$wdFormatXMLDocument = 12

$wdBorderTop = -1
$wdBorderLeft = -2
$wdBorderBottom = -3
$wdBorderRight = -4
$wdBorderHorizontal = -5
$wdBorderVertical = -6
```

Example:

```powershell
$top = $section.Borders.Item($wdBorderTop)
```

## Process Cleanup

Do not blindly run:

```powershell
Stop-Process WINWORD -Force
```

That can destroy the user's unsaved work. Only use it in a disposable automation environment or after explicit user approval. The normal fix is to close the document, quit the COM Word instance, release COM objects, and use a fresh output path.
