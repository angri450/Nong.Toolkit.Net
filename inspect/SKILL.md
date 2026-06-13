---
name: inspect
description: Agricultural paper inspection and generation via nong. Trigger on paper diagnosis, 论文诊断, paper type classification, structure extraction, reference check, variable plan, evidence chain, gap grade, data requirements, semantic diagnosis, or paper drafting from JSON spec.
---

# Inspect

Use `nong inspect` for paper-level semantic, structural, evidence, reference, and writing workflows. Inspect consumes text or paper specs; for `.docx` sources, use `word dissect` or `word read` first.

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

Current `nong commands --json` exposes these 10 implemented Inspect commands:

```powershell
nong inspect diagnose <paper.txt> --json
nong inspect refs <paper.txt> --json
nong inspect write-paper <spec.json> -o <out.docx> --json
nong inspect classify <paper.txt> --json
nong inspect structure <paper.txt> --json
nong inspect varplan <paper.txt> --json
nong inspect evidence <paper.txt> --json
nong inspect data-req <paper.txt> --json
nong inspect gap <paper.txt> --json
nong inspect semantics <paper.txt> --json
```

## Dispatch

1. For `.docx` papers, run `nong word dissect <file.docx> --output <slice-dir> --json` and use `<slice-dir>/content.md` as the inspect input. Use `nong word read <file.docx> --json` only for quick plain-text extraction.
2. For full paper quality diagnosis, run `nong inspect diagnose <paper.txt> --json`.
3. For references and citation risk, run `nong inspect refs <paper.txt> --json`.
4. For paper type routing, run `nong inspect classify <paper.txt> --json`.
5. For title, abstract, keywords, section, table, and reference extraction, run `nong inspect structure <paper.txt> --json`.
6. For variable operationalization and data collection planning, run `nong inspect varplan <paper.txt> --json`.
7. For evidence chain checks, run `nong inspect evidence <paper.txt> --json`.
8. For data source, sample, measurement, and method-data fit checks, run `nong inspect data-req <paper.txt> --json`.
9. For empirical paper gap grading, run `nong inspect gap <paper.txt> --json`.
10. For research design semantics, causal wording, mechanism claims, and method alignment, run `nong inspect semantics <paper.txt> --json`.
11. For a Word paper draft, prepare a paper spec JSON and run `nong inspect write-paper <spec.json> -o <out.docx> --json`; then use Word commands for DOCX validation and slicing.

Inspect is not a DOCX parser. Keep Word layout, assets, comments, revisions, validation, and append edits in the `word` skill.

## Paper Spec

Use this minimal shape for `write-paper`:

```json
{
  "title": "Title",
  "abstract": "Abstract text.",
  "keywords": "keyword1; keyword2",
  "sections": [
    {
      "heading": "1 Introduction",
      "level": 1,
      "body": ["Paragraph one.", "Paragraph two."]
    }
  ],
  "references": ["[1] Author. Title. Journal, 2026."]
}
```

`sections[].heading` is required. `level` must be 1-3. Treat `E006 validation_failed` as a spec problem.

## Contract

Always use `--json` when the result will feed another tool or model decision. Treat `status: "error"` as failed.

Reference and semantic outputs are rule-based writing and method diagnostics. Do not present them as external database verification, advisor review, or peer review.
