---
name: word
description: Word document CLI operations via nong. Trigger on .docx, Word text extraction, NongMark slicing, structure/format inspection, validation, merge, template fill, or Word edits.
---

# Word

Use `nong` as the only deterministic Word entrypoint. GroundPA routes Word work to the CLI and does not reimplement DOCX parsing or generation logic.

## Prerequisites

Verify the installed command surface before work:

```powershell
nong commands --json
```

If `nong` is missing, install the CLI:

```powershell
dotnet tool install --global Angri450.Nong.Cli
```

## Implemented Commands

Current `nong commands --json` exposes these 30 implemented Word leaf commands.

Read and inspect:

```powershell
nong word read <file.docx> --json
nong word preview <file.docx> --json
nong word dissect <file.docx> --output <slice-dir> --json
nong word stats <file.docx> --json
nong word fonts <file.docx> --json
nong word styles <file.docx> --json
nong word outline <file.docx> --json
nong word images <file.docx> --json
nong word comments <file.docx> --json
nong word revisions <file.docx> --json
```

Validate, repair, and infer:

```powershell
nong word validate <file.docx> --json
nong word infer-format "黑体 四号 居中" --json
nong word fix-order <file.docx> -o <out.docx> --json
nong word rebuild <file.docx> -o <out.docx> --json
```

Generate, combine, and protect:

```powershell
nong word fill <template.docx> <data.json> -o <out.docx> --json
nong word merge <file1.docx> <file2.docx> -o <out.docx> --json
nong word extract <file.docx> -o <images-dir> --json
nong word protect <file.docx> -o <out.docx> --mode readonly --json
nong word embed-font <file.docx> <font-file> -o <out.docx> --json
```

Append content. Use this nested `word add ...` form in examples, scripts, and automation:

```powershell
nong word add paragraph <file.docx> --spec paragraph.json -o <out.docx> --json
nong word add table <file.docx> --spec table.json -o <out.docx> --json
nong word add footnote <file.docx> --text "Footnote text" -o <out.docx> --json
nong word add endnote <file.docx> --text "Endnote text" -o <out.docx> --json
nong word add image <file.docx> --src fig.png --caption "Figure 1" -o <out.docx> --json
nong word add toc <file.docx> --title "Contents" -o <out.docx> --json
nong word add xref <file.docx> --to "_Toc001" --text "see Table 1" -o <out.docx> --json
nong word add link <file.docx> --url "https://example.com" --text "Example" -o <out.docx> --json
nong word add bookmark <file.docx> --name "_Toc001" -o <out.docx> --json
nong word add comment <file.docx> --text "Review note" -o <out.docx> --json
nong word add math <file.docx> --latex "E=mc^2" --display -o <out.docx> --json
```

`word add-*` remains a compatibility alias pattern only. Do not use flattened add aliases as canonical examples.

## Primary DOCX Slice Path

For complex `.docx` files, use NongMark one-cut three-stream slicing before making model decisions:

```powershell
nong word dissect paper.docx --output paper.slice --json
```

The slice directory separates content, structure, formatting, and assets:

- `document.json`: document identity, package-level metadata, relationships, and top-level counts.
- `content.jsonl`: ordered block stream with stable block IDs for paragraphs, tables, images, comments, and other content units.
- `structure.json`: heading tree, section hierarchy, outline order, and block-to-section mapping.
- `format.json`: styles, fonts, paragraph/run formatting, page setup, and detected format features.
- Media manifest JSON in the slice output: extracted or referenced media assets, relationship IDs, source paths, captions, and content links.
- `content.md`: readable Markdown projection for paper-level analysis, review, and summarization.
- `summary.json`: compact counts, warnings, errors, artifact paths, and recommended next commands.

Use block IDs from the slice with `--after <blockId>` when inserting paragraphs, tables, images, notes, links, bookmarks, comments, or math.

## Dispatch

1. For a complex source document, run `nong word dissect <file> --output <slice-dir> --json` first, then inspect the slice files.
2. For quick plain text only, run `nong word read <file> --json`.
3. For structural warnings and OOXML diagnostics, run `nong word preview <file> --json`, `nong word validate <file> --json`, or `nong word outline <file> --json`.
4. For format inventory, run `nong word fonts`, `nong word styles`, `nong word stats`, and `nong word infer-format`.
5. For embedded media, run `nong word images <file> --json`; only extract files with `nong word extract <file> -o <dir> --json` when the user asks for assets or the workflow needs them.
6. For document edits, use `nong word add ...`, `fill`, `merge`, `protect`, `embed-font`, `fix-order`, or `rebuild`; do not edit OOXML directly.
7. For paper diagnosis, reference checks, or semantic analysis, create text or a NongMark slice first, then use the `inspect` skill.

## Contract

Always pass `--json` when output will feed another tool or model decision. Treat `status: "error"` as failed even if stdout contains useful text.

Handle common error codes explicitly:

- `E001 file_not_found`: verify the input path and do not continue with stale output.
- `E003 missing_argument`: add the required option or argument, such as `--spec`, `--text`, `--latex`, `--src`, or `-o`.
- `E006 validation_failed`: fix the JSON spec, format description, or document validation issue before retrying.

Generated DOCX paths should be explicit with `-o`; use `artifacts.docx` only when no better user-facing path is available.
