# Write Word

Use Nong CLI commands for Word generation and edits. GroundPA should prepare JSON specs and route the work to `nong`; it should not recreate the DOCX writer pipeline in local code.

## 1. Choose the Output Path

Before creating or changing a document, choose the output path explicitly:

```powershell
$out = "paper.out.docx"
```

Use `-o <out.docx>` on every command that writes a DOCX.

## 2. Template Fill

Use template fill when the source document already contains placeholders:

```powershell
nong word fill template.docx data.json -o filled.docx --json
```

`data.json` should contain the values needed by the template. Keep the data file small enough to review, and validate the result with:

```powershell
nong word preview filled.docx --json
nong word validate filled.docx --json
```

## 3. Append Content

Use the nested `word add ...` commands as the canonical editing path:

```powershell
nong word add paragraph paper.docx --spec paragraph.json -o paper.p1.docx --json
nong word add table paper.p1.docx --spec table.json -o paper.table.docx --json
nong word add image paper.table.docx --src fig.png --caption "Figure 1" -o paper.fig.docx --json
nong word add math paper.fig.docx --latex "E=mc^2" --display -o paper.math.docx --json
```

Use `--after <blockId>` when a prior `word dissect --output` slice identified the insertion point.

Paragraph spec:

```json
{
  "text": "This paragraph was added by Nong.",
  "style": "Normal",
  "bold": false,
  "italic": false
}
```

Table spec:

```json
{
  "caption": "Table 1. Main results",
  "headers": ["Group", "Mean", "SD"],
  "rows": [
    ["Control", "10.1", "1.0"],
    ["Treatment", "13.4", "1.2"]
  ]
}
```

Other add leaves:

```powershell
nong word add footnote paper.docx --text "Footnote text" -o out.docx --json
nong word add endnote paper.docx --text "Endnote text" -o out.docx --json
nong word add toc paper.docx --title "Contents" -o out.docx --json
nong word add xref paper.docx --to "_Toc001" --text "see Table 1" -o out.docx --json
nong word add link paper.docx --url "https://example.com" --text "Example" -o out.docx --json
nong word add bookmark paper.docx --name "_Toc001" -o out.docx --json
nong word add comment paper.docx --text "Review note" -o out.docx --json
```

`word add-*` is a compatibility alias pattern only.

## 4. Merge, Protect, Embed, and Repair

```powershell
nong word merge intro.docx body.docx appendix.docx -o merged.docx --json
nong word protect merged.docx -o protected.docx --mode readonly --json
nong word embed-font merged.docx simsun.ttf -o embedded.docx --json
nong word fix-order merged.docx -o fixed.docx --json
nong word rebuild merged.docx -o rebuilt.docx --json
```

Run validation after each destructive or structural edit:

```powershell
nong word validate rebuilt.docx --json
nong word preview rebuilt.docx --json
```

## 5. Paper Drafts

For full paper drafting from a JSON spec, use Inspect:

```powershell
nong inspect write-paper paper-spec.json -o paper.docx --json
```

Then use Word commands for DOCX-level validation, slicing, and post-editing:

```powershell
nong word dissect paper.docx --output paper.slice --json
nong word validate paper.docx --json
```

## 6. Error Handling

Treat `status: "error"` as a hard stop. Common fixes:

- `E001`: verify the input file exists.
- `E003`: supply the required option such as `--spec`, `--text`, `--latex`, `--src`, or `-o`.
- `E006`: repair invalid JSON specs, invalid format descriptions, or validation failures.
