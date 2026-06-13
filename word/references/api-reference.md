# Word CLI Reference

This reference describes the Word command surface exposed by `nong`. Use the CLI directly; do not build a temporary project to access Word internals.

## Read and Inspect

```powershell
nong word read paper.docx --json
nong word preview paper.docx --json
nong word dissect paper.docx --output paper.slice --json
nong word stats paper.docx --json
nong word fonts paper.docx --json
nong word styles paper.docx --json
nong word outline paper.docx --json
nong word images paper.docx --json
nong word comments paper.docx --json
nong word revisions paper.docx --json
```

Use `word dissect --output` for complex documents. Use `read` only when plain text is enough, and `preview` or `validate` when you need OOXML diagnostics.

## Validate, Repair, and Infer

```powershell
nong word validate paper.docx --json
nong word infer-format "宋体 小五号 首行缩进" --json
nong word fix-order paper.docx -o fixed.docx --json
nong word rebuild paper.docx -o rebuilt.docx --json
```

`validate` reports schema issues. `fix-order` corrects OOXML child ordering. `rebuild` cleans style pollution. `infer-format` maps a natural-language Chinese formatting description to an OpenXML-oriented format result.

## Generate and Combine

```powershell
nong word fill template.docx data.json -o filled.docx --json
nong word merge intro.docx body.docx appendix.docx -o merged.docx --json
nong word extract paper.docx -o extracted-images --json
nong word protect paper.docx -o protected.docx --mode readonly --json
nong word embed-font paper.docx simsun.ttf -o embedded.docx --json
```

Use `fill` for template placeholders, `merge` for ordered DOCX composition, `extract` for media export, `protect` for document protection, and `embed-font` when a real font file is available.

## Add Leaves

Canonical add examples use nested commands:

```powershell
nong word add paragraph paper.docx --spec paragraph.json -o out.docx --json
nong word add table paper.docx --spec table.json -o out.docx --json
nong word add footnote paper.docx --text "Footnote text" -o out.docx --json
nong word add endnote paper.docx --text "Endnote text" -o out.docx --json
nong word add image paper.docx --src fig.png --caption "Figure 1" -o out.docx --json
nong word add toc paper.docx --title "Contents" -o out.docx --json
nong word add xref paper.docx --to "_Toc001" --text "see Table 1" -o out.docx --json
nong word add link paper.docx --url "https://example.com" --text "Example" -o out.docx --json
nong word add bookmark paper.docx --name "_Toc001" -o out.docx --json
nong word add comment paper.docx --text "Review note" -o out.docx --json
nong word add math paper.docx --latex "E=mc^2" --display -o out.docx --json
```

The flattened `word add-*` forms are compatibility aliases. Prefer the nested form in documentation and automation.

## Spec Shapes

Paragraph spec:

```json
{
  "text": "New paragraph text.",
  "style": "Normal",
  "bold": false,
  "italic": false
}
```

Table spec:

```json
{
  "caption": "Table 1. Treatment summary",
  "headers": ["Treatment", "Mean", "SD"],
  "rows": [
    ["A", "12.4", "1.1"],
    ["B", "15.2", "0.9"]
  ]
}
```

Both specs can be passed as a file path or inline JSON through `--spec`.

## JSON Contract

All automation paths should include `--json`. A successful command returns `status: "ok"` and may include `data`, `issues`, `artifacts`, `metrics`, and `meta`. A failed command returns `status: "error"` and structured `errors`.

Common Word-facing error codes:

| Code | Meaning | Action |
|------|---------|--------|
| `E001` | `file_not_found` | Fix the path and rerun. |
| `E003` | `missing_argument` | Add the required argument or option. |
| `E006` | `validation_failed` | Repair the spec, document, or format input. |

Do not continue from stale output after any `status: "error"` response.
