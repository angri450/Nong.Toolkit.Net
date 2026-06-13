---
name: word
description: Word document workflows through nong. Trigger on .doc/.docx conversion handoff, DOCX reading, formatting/layout inspection, NongMark slicing, existing-document repair, template fill, document edits, validation, merge, protection, comments, images, fonts, or Word-to-paper/official-document preparation.
---

# Word

Use `nong` as the deterministic Word entrypoint. Do not use desktop Word COM automation, `python-docx`, Markdown-to-DOCX, or ad hoc PowerShell scripts as the normal editing path. NongMark is the primary authoring language — write `.nongmark` and run `nong word create`.

Schema-valid is not visual-quality complete. Cite format evidence from slice artifacts (format.json, content.jsonl, structure.json) — not plain text alone.

## Nong CLI Preflight

Read [../references/shared/nong-cli-preflight.md](../references/shared/nong-cli-preflight.md) before the first Nong command in a session. Confirm Nong.Cli.Net `4.1.0+` and the `word` command group.

**Image analysis routing (4.1.0+):** `nong word images --analyze`, `--crop`, and `nong word crop` route to the standalone `Angri450.Nong.Tool.Imaging` dotnet tool. First use auto-installs. Other word commands run inline in the main CLI.

## Three-Layer Workflow

### New documents

```powershell
nong word create document.nongmark -o document.docx --json
nong word validate document.docx --json
nong word dissect document.docx --output document.slice --json
```

### Existing documents — read & inspect

```powershell
nong word check <file.docx> --json                      # preflight
nong word convert <file.doc> -o <file.docx> --json       # .doc boundary
nong word dissect <file.docx> --output <slice> --json    # full slice
nong word fonts <file.docx> --json
nong word styles <file.docx> --json
nong word preview <file.docx> --json
nong word validate <file.docx> --json
```

### Existing documents — repair & format

```powershell
nong word fix-order <file.docx> -o <fixed.docx> --json
nong word academic-format <input.docx> -o <academic.docx> --json
nong word format-gongwen <input.docx> -o <gongwen.docx> --json
nong word format-audit <academic.docx> --profile academic --min-score 80 --json
nong word table-reflow <file.docx> -o <out.docx> --max-rows 20 --max-cols 6 --json
```

Write to explicit `-o` paths. Never overwrite the user's source.

### Page layout & compaction

For tightening layout, blank space, split tables, image pairs, or page-break control — load [references/page-layout.md](references/page-layout.md).

Key commands: `word estimate`, `word fit-images`, `word compact-tables`, `word regroup-images`, `word crop`, `word page-setup`, `word indent`, `word paragraph-control`.

## Evidence Rules

- `word read` is text-only — cannot prove fonts, size, spacing, indentation, borders.
- Format claims must cite format.json, content.jsonl, fonts, styles, preview, or validate.
- Schema-valid ≠ visually ideal. `word format-audit` is the read-only visual evidence gate.
- `content.nongmark` is the semantic stream; `preview/content.txt` is lossy plain text.

## Existing Documents

For contracts, old .doc, table-heavy forms, or format repairs — load [references/existing-document-editing.md](references/existing-document-editing.md).

Core stance: `.doc` → convert boundary → return to `nong word`. Use `word repair-plan` to disambiguate repair vs format requests. COM is a developer escape hatch in Nong.Dev.Net — do not use for document workflows.

## Reference Routing

Load only the reference needed for the task:

| Task | Reference |
|------|-----------|
| Reading, slicing, evidence, assets | [read-word.md](references/read-word.md) |
| Template fill, add, merge, protect | [write-word.md](references/write-word.md) |
| .doc handoff, legacy repair, contracts | [existing-document-editing.md](references/existing-document-editing.md) |
| Page layout, compaction, images, tables | [page-layout.md](references/page-layout.md) |
| CLI syntax & JSON spec shapes | [api-reference.md](references/api-reference.md) |
| Workspace layout | [workspace-setup.md](references/workspace-setup.md) |
| Word→inspect/paper feed | [paper-analysis.md](references/paper-analysis.md) |

## COM Escape Hatch

COM automation lives in **Nong.Dev.Net** (`references/word-com-automation.md`). It is a developer tool — not a document-skill concern. Do not write PowerShell + Word COM scripts for normal editing. If installed Word must be driven, load that reference from Dev.Net.

## Error Contract

Always pass `--json`. Treat `status: "error"` as failed.

- `E001 file_not_found`: fix path.
- `E002 unsupported_format`: `word check`; `.doc` → `word convert`.
- `E003 missing_argument`: supply `--spec`, `--text`, `--latex`, `--src`, or `-o`.
- `E005 dependency_missing`: install/update `Angri450.Nong.Cli`.
- `E006 validation_failed`: repair spec or document before retry.
- `E009 not_implemented`: do not continue as success; use implemented path.
