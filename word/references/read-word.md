# Read Word

Use `nong word dissect` as the main path for complex `.docx` reading. It creates a NongMark slice that separates readable content, structural hierarchy, formatting facts, and assets.

## Primary Path

```powershell
nong word dissect paper.docx --output paper.slice --json
```

Slice files:

| File | Purpose |
|------|---------|
| `document.json` | Document metadata, package facts, relationships, and top-level counts. |
| `content.jsonl` | Ordered block stream with stable IDs for paragraphs, tables, images, comments, and other content units. |
| `structure.json` | Heading tree, section hierarchy, outline order, and block-to-section mapping. |
| `format.json` | Styles, fonts, page setup, paragraph/run formatting, and detected format features. |
| `assets/manifest.json` | Media assets and their relationship IDs, paths, captions, and linked blocks. |
| `content.md` | Readable Markdown projection for review, summarization, and inspect workflows. |
| `summary.json` | Compact counts, warnings, errors, generated artifacts, and recommended next steps. |

When you need to insert content later, keep block IDs from `content.jsonl` or `structure.json` and pass them with `--after <blockId>`.

## Lightweight Reads

Use these commands when a full slice is unnecessary:

```powershell
nong word read paper.docx --json
nong word preview paper.docx --json
nong word outline paper.docx --json
nong word stats paper.docx --json
```

- `read`: plain text extraction for quick inspection.
- `preview`: seven-step document structure diagnostics and OOXML warnings.
- `outline`: heading and section outline.
- `stats`: document statistics.

## Format and Asset Reads

```powershell
nong word fonts paper.docx --json
nong word styles paper.docx --json
nong word images paper.docx --json
nong word comments paper.docx --json
nong word revisions paper.docx --json
nong word validate paper.docx --json
```

Only export media when needed:

```powershell
nong word extract paper.docx -o paper.images --json
```

## Feature Deposition

Do not save extracted format facts or assets into `word/formats/` by default. After reading, report the useful findings and ask whether the user wants to save a reusable format profile.

Only write to `formats/` and update [INDEX.md](../formats/INDEX.md) when the user explicitly asks to save or record the format. Skip this step when the user says no.

## Boundaries

Do not parse raw OOXML with ad hoc scripts as a Word reading path. If `nong word dissect`, `read`, or `preview` returns `status: "error"`, fix the input or command arguments and rerun the CLI.
