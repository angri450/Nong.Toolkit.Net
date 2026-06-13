# Word format-reading routing regression

Date: 2026-06-05

## Problem

A real user workflow asked about DOCX formatting, but the model answered from plain text extraction and said formatting details such as fonts, font sizes, table borders, and alignment could not be judged without manually opening Word.

This is a routing regression. `nong word read` is a text-only command. It is not the primary evidence path for layout or formatting.

## Existing CLI capability

The current Word slice path is:

```powershell
nong word dissect paper.docx --output paper.slice --json
```

The slice writes:

- `format.json`
- `content.jsonl`
- `structure.json`
- `content.md`
- `document.json`
- `assets/manifest.json`
- `summary.json`

Current extracted formatting evidence includes run-level fonts and font sizes, paragraph alignment, paragraph spacing and indentation, style IDs and names, document font inventory, page and section dimensions, table style IDs, table widths, table borders, cell widths, cell vertical alignment, structure, and OOXML validation warnings.

## Limitations

Some details are still partial in the CLI model:

- resolved style inheritance
- exact Word visual rendering

These should be reported as current CLI limitations, not guessed.

## Fix Applied

Updated:

- `word/SKILL.md`
- `word/references/read-word.md`
- `word/references/api-reference.md`
- `README.md`
- `README.zh-CN.md`

New rule: for layout, formatting, fonts, font size, margins, alignment, table borders, styles, captions, or "looks right" questions, GroundPA must not answer from `word read`, `content.md`, or plain text alone. It must run `word dissect --output`, inspect the slice files, and add `fonts`, `styles`, `preview`, or `validate` when useful.

## Follow-up

Stage 18 should continue expanding the NongMark format model, especially resolved style properties and higher-level format audit/apply workflows.
