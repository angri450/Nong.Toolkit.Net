---
name: word
description: Word document workflows through nong. Trigger on .doc/.docx conversion handoff, DOCX reading, formatting/layout inspection, NongMark slicing, existing-document repair, template fill, document edits, validation, merge, protection, comments, images, fonts, or Word-to-paper/official-document preparation.
---

# Word

Use `nong` as the deterministic Word entrypoint. Nong.Toolkit.Net decides the workflow, prepares NongMark or small specs, reads JSON/slice outputs, and reports evidence; it does not recreate DOCX parsing or generation logic in ad hoc scripts.

Do not answer layout or formatting questions from plain text alone. Do not use desktop Word COM automation as the normal editing path.

NongMark is the primary Word authoring language. Do not use Markdown-to-DOCX, `python-docx`, or ad hoc PowerShell/COM scripts for normal Word generation or formatting. If a user asks for a new DOCX, write `document.nongmark` by default and run `nong word create`.

Schema-valid is not visual-quality complete. For formatted deliverables, verify fonts, line spacing, paragraph layout, table borders, and visible content through `dissect`, `format.json`, `content.jsonl`, `fonts`, `styles`, or direct OOXML checks when the slice contract has a gap.

## Nong CLI Preflight

Read [../references/shared/nong-cli-preflight.md](../references/shared/nong-cli-preflight.md) before the first Nong command in a session. Confirm Nong.Cli.Net `4.0.0+` and the needed command group.
## Three-Layer Workflow

### Layer 1: NongMark -> DOCX

Use this for new documents, papers, proposals, reports, and generated Word deliverables:

```powershell
nong word create document.nongmark -o document.docx --json
nong word validate document.docx --json
nong word dissect document.docx --output document.slice --json
```

Do not create `.md` as the Word source. Do not route Markdown through Pandoc, Word COM, or `python-docx`.

### Layer 2: DOCX -> NongMark + Preview

Use this for reading, slicing, analysis, and evidence gathering:

1. For any user-supplied `.doc` or `.docx`, preflight first:

```powershell
nong word check <file.docx|file.doc> --json
```

If `word check` reports legacy `.doc`, convert to explicit `.docx`:

```powershell
nong word convert <file.doc> -o <file.docx> --json
```

2. For complex existing `.docx`, layout questions, table-heavy contracts, or "does this look right" requests, slice after preflight:

```powershell
nong word dissect <file.docx> --output <slice-dir> --json
```

Inspect at least:

- `<slice-dir>/content.nongmark`
- `<slice-dir>/format.json`
- `<slice-dir>/content.jsonl`
- `<slice-dir>/structure.json`
- `<slice-dir>/preview/content.txt`

3. Add targeted inventory/diagnostic commands as needed:

```powershell
nong word fonts <file.docx> --json
nong word styles <file.docx> --json
nong word preview <file.docx> --json
nong word validate <file.docx> --json
```

### Layer 3: DOCX Repair/Format

Use this for existing documents, especially dirty OOXML, WPS/COM/python-docx output, table-heavy files, or academic formatting:

```powershell
nong word fix-order <file.docx> -o <fixed.docx> --json
nong word validate <fixed.docx> --json
```

For existing DOCX academic/paper formatting, do not switch to Word COM. Apply the deterministic formatter first:

```powershell
nong word repair-plan --json
nong word academic-format <input.docx> -o <academic.docx> --json
nong word validate <academic.docx> --json
nong word format-audit <academic.docx> --profile academic --min-score 80 --json
nong word dissect <academic.docx> --output <academic.slice> --json
```

Use `word repair-plan` when the user's request mixes OOXML repair, visible formatting, and table layout. Use `word format-audit` as the read-only visual-format evidence gate for academic deliverables. Use `word table-reflow` when long or wide tables still need explicit continuation tables after formatting:

```powershell
nong word table-reflow <academic.docx> -o <tables.docx> --max-rows 20 --max-cols 6 --repeat-left-cols 1 --json
nong word validate <tables.docx> --json
nong word format-audit <tables.docx> --profile academic --min-score 80 --json
```

For existing DOCX official-document/gongwen formatting, use the public CLI command instead of library calls or COM:

```powershell
nong word format-gongwen <input.docx> -o <gongwen.docx> --json
nong word validate <gongwen.docx> --json
nong word dissect <gongwen.docx> --output <gongwen.slice> --json
```

Write to explicit output paths with `-o`. Never overwrite the user's source unless they explicitly request that.

## Evidence Rules

- `word read` is text-only evidence. It cannot prove fonts, font size, line spacing, indentation, alignment, table borders, margins, captions, or visual layout.
- For formatting/layout claims, cite facts from `format.json`, `content.jsonl`, `structure.json`, `fonts`, `styles`, `preview`, or `validate`.
- For final academic-format claims, prefer `word format-audit` plus slice evidence. `validate`, `preview`, `outline`, `dissect`, and `fix-order` alone do not prove visible formatting quality.
- VML formula/picture content appears as image blocks/assets, not editable text. Do not treat blank plain-text lines as proof that source content was empty.
- If the first extraction was plain text, say so and run the format-oriented path before judging.
- Schema-valid does not mean visually ideal. A formatted DOCX can only be called done after format evidence is reviewed.
- Do not treat `content.md` as a slice artifact. Current slices use `content.nongmark` as the readable semantic stream and `preview/content.txt` as the lossy plain-text preview.

Minimum quality gates for existing-document formatting:

- Fonts: Chinese body/heading and Latin runs are intentional, not default Calibri pollution.
- Paragraphs: title/heading/body spacing, indentation, and alignment match the requested style.
- Line spacing: no unwanted exact/fixed compression unless explicitly requested.
- Tables: three-line/header/body borders, width, merged cells, and readable cell spacing are inspected.
- Content: `preview/content.txt` and `content.jsonl` show no missing sections, tables, formulas, or images.

## Existing Documents

For user-supplied contracts, old Word files, table-heavy forms, or "modify this document's formatting", read [references/existing-document-editing.md](references/existing-document-editing.md).

Core stance:

- `.doc` requires a conversion handoff before OpenXML work. Use Word/LibreOffice conversion only as a boundary step, then return to `nong word`.
- Existing `.docx` should be inspected, repaired, edited through CLI/library-backed operations, and validated.
- Use `word repair-plan` to choose between `academic-format`, `format-audit`, `fix-order`, and `table-reflow` when the request is ambiguous.
- COM is an escape hatch, not the main implementation.

## Reference Routing

Load only the reference needed for the task:

- [references/read-word.md](references/read-word.md): reading, slicing, formatting evidence, assets, comments, revisions.
- [references/write-word.md](references/write-word.md): template fill, add operations, merge, protect, embed fonts, repair, validation after writes.
- [references/api-reference.md](references/api-reference.md): exact command syntax and JSON spec shapes.
- [references/existing-document-editing.md](references/existing-document-editing.md): `.doc` handoff, legacy DOCX repair, real-case contract workflow, official-document transformation.
- [references/com-automation.md](references/com-automation.md): only when installed Microsoft Word must be driven.
- [references/workspace-setup.md](references/workspace-setup.md): case workspace layout and artifact organization.
- [references/paper-analysis.md](references/paper-analysis.md): when Word output feeds inspect/paper workflows.

## Writing And Editing

For long DOCX generation, author NongMark first and let Nong create the document:

```powershell
nong word create document.nongmark -o document.docx --json
nong word validate document.docx --json
nong word dissect document.docx --output document.slice --json
```

Use `.nongmark` or `.nmk`, not `.md`, as the source file. `content.nongmark` is the source-like semantic stream; `preview/content.txt` is only a plain preview.

Use canonical nested add commands:

```powershell
nong word add paragraph <file.docx> --spec paragraph.json -o <out.docx> --json
nong word add table <file.docx> --spec table.json -o <out.docx> --json
nong word add image <file.docx> --src fig.png --caption "Figure 1" -o <out.docx> --json
nong word add comment <file.docx> --text "Review note" -o <out.docx> --json
nong word add math <file.docx> --latex "E=mc^2" --display -o <out.docx> --json
```

### Document Comparison

```powershell
nong word compare <original.docx> <revised.docx> --json
```

Reports paragraph-level differences: added, removed, and modified paragraphs with their text and style IDs.
```

Use `--after <blockId>` only after `word dissect --output` has identified the insertion point.

Use `word add-*` flattened aliases only for compatibility with older scripts; do not teach them as the canonical form.

## COM Escape Hatch

Use desktop Word COM only when all are true:

1. The user explicitly asks to drive installed Word, or the task requires Word's visual/layout engine.
2. `nong` cannot provide the needed fact or transformation.
3. The environment is Windows with Word installed.
4. You can isolate outputs and clean COM objects safely.

Before writing any COM script, read [references/com-automation.md](references/com-automation.md). Do not blanket-kill `WINWORD` without explicit user approval.

## Error Contract

Always pass `--json` when output feeds another tool or model decision. Treat `status: "error"` as failed.

Common codes:

- `E001 file_not_found`: fix input path; do not continue from stale output.
- `E002 unsupported_format`: run `word check`; for `.doc`, run `word convert` first.
- `E003 missing_argument`: supply required `--spec`, `--text`, `--latex`, `--src`, or `-o`.
- `E005 dependency_missing`: install/update `Angri450.Nong.Cli`, or install a boundary converter such as LibreOffice/Word when `word convert` needs it.
- `E006 validation_failed`: repair the spec, format description, or document validation issue before retrying.
- `E009 not_implemented`: do not continue as success; report the limitation and use an implemented Nong command path.

Generated DOCX paths should be explicit with `-o`; use `artifacts.docx` only when no better user-facing path is available.
