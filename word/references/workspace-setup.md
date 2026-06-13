# Word Workspace Setup

This workspace is for CLI inputs and outputs. Do not scaffold a local Word library project for normal GroundPA work.

## Recommended Layout

Use a task-specific directory outside the plugin files:

```text
GroundPA Toolkit Workplace/
  word/
    <task-id>/
      input/
      slices/
      specs/
      output/
      assets/
```

Keep source documents in `input/`, JSON specs in `specs/`, NongMark slices in `slices/`, generated DOCX files in `output/`, and extracted media in `assets/`.

## First Commands

Verify the CLI:

```powershell
nong commands --json
```

Slice complex DOCX files:

```powershell
nong word dissect input/paper.docx --output slices/paper --json
```

Read the slice before editing:

```text
slices/paper/document.json
slices/paper/content.jsonl
slices/paper/structure.json
slices/paper/format.json
slices/paper/assets/manifest.json
slices/paper/content.md
slices/paper/summary.json
```

## Edit Cycle

1. Create or update a JSON spec in `specs/`.
2. Run the relevant `nong word add ...`, `fill`, `merge`, `protect`, `embed-font`, `fix-order`, or `rebuild` command with an explicit `-o output/<name>.docx`.
3. Validate the generated file:

```powershell
nong word validate output/paper.docx --json
nong word preview output/paper.docx --json
```

4. Slice the final DOCX if another model or tool needs stable block IDs:

```powershell
nong word dissect output/paper.docx --output slices/paper-final --json
```

## Format Profiles

Existing format JSON files live in `word/formats/`. Use them as reusable documentation for common layouts, but do not update them unless the user explicitly asks to save a newly discovered format.

When a reference document has useful formatting, extract it with:

```powershell
nong word dissect input/reference.docx --output slices/reference --json
```

Review `slices/reference/format.json` before deciding whether to create a new format profile.

## Failure Rules

Do not continue from prior artifacts after `status: "error"`. Fix the path, required option, JSON spec, or validation issue, then rerun the Nong command that failed.
