# Word COM automation failure report

Date: 2026-06-05

## Problem

A real Word workflow escaped from `nong word` into ad hoc PowerShell + desktop Word COM automation. It produced nine failures:

1. `Marshal.GetActiveObject()` unavailable in PowerShell 7/.NET.
2. Merged table cell traversal failed with COM HRESULT errors.
3. Repeated document save failures from stale Word file locks.
4. Null document references after attaching to an empty or exited Word instance.
5. `ConvertToText()` returned COM objects to the pipeline and polluted logs.
6. `Rows.Item(1).Select()` failed on a merged row.
7. `SaveAs(..., 0)` produced old `.doc` instead of `.docx`.
8. `$word.Visible = $true` opened unnecessary visible windows.
9. `Section.Borders.Item()` received string enum names instead of integer Word enum values.

## Root Cause

The workflow violated GroundPA's Word contract. Normal Word work should use `nong word ...` and pure OpenXML behavior, not desktop Word COM. COM automation is Windows-only, sensitive to merged tables, vulnerable to stale process/file locks, and easy to misuse from PowerShell 7.

## Fix Applied

Updated:

- `word/SKILL.md`
- `word/references/api-reference.md`
- `word/references/write-word.md`
- `powershell/SKILL.md`

Added:

- `word/references/com-automation.md`

New rule: do not use desktop Word COM automation for ordinary Word reading, formatting inspection, or edits. Use `nong word ...` first. COM is only an explicit escape hatch when the user requires installed Microsoft Word or Word's visual/layout engine and `nong` cannot provide the needed result.

## Safety Note

Do not use `Stop-Process WINWORD -Force` as a default cleanup step. It can destroy unsaved user work. Only use it in a disposable automation environment or with explicit user approval.

## Remaining Work

Any future task that wants COM-only behavior should be converted into a `nong word` capability when practical, especially for format audit, table handling, and document repair.
