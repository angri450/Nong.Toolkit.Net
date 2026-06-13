# Word existing-document progressive disclosure update

Date: 2026-06-05

## Background

The Word skill needed to absorb the real contract workflow without turning `word/SKILL.md` into a long incident report. The key lesson from the `.doc` contract case is practical:

- `nong word read` is text-only evidence and cannot judge layout.
- Legacy `.doc` needs a conversion boundary before OpenXML tooling can work.
- After conversion, GroundPA should return to `nong word` for inspection, repair, writing, preview, and validation.
- Raw Word COM automation is a fallback boundary tool, not the normal editing engine.

## Changes

Updated `word/SKILL.md` for progressive disclosure:

- Broadened the trigger description to include `.doc/.docx` conversion handoff, existing-document repair, and Word-to-paper/official-document preparation.
- Kept only the default workflow, evidence rules, reference routing, canonical write commands, COM escape-hatch gate, and error contract in the main skill file.
- Routed existing contracts, old Word files, table-heavy forms, and formatting-change requests to `word/references/existing-document-editing.md`.

Added `word/references/existing-document-editing.md`:

- Defines the `.doc -> .docx -> nong word` boundary.
- Documents the real-case pipeline: `dissect`, `preview`, `validate`, `fonts`, `styles`, `fix-order`, `rebuild`, and final validation.
- Lists known legacy Word/WPS OOXML artifacts that recent Nong repair code handles.
- Captures the contract transformation workflow for repaired DOCX, extracted fields, template, filled template, paper draft, official-document draft, and report artifacts.
- Records the consumer feedback response: the COM-only path was a valid complaint; the correct GroundPA behavior is conversion-only COM followed by deterministic Nong operations.
- States the remaining product gap: first-class existing-document editing should become `DocumentReader -> rule matcher -> DocumentEditor -> writer`.

Updated reference routing:

- `word/references/read-word.md`
- `word/references/write-word.md`
- `word/references/api-reference.md`

Each now points agents to the existing-document reference before handling legacy/table-heavy repair or layout-change work.

## Validation Context

This guidance was based on the real file:

Repository-local real-case source:

`改-技术服务合同---内蒙古沸石土传病害研制项目.doc`

The Nong real-case matrix produced 46/46 passing checks after repair, with artifacts including:

- repaired/rebuilt contract DOCX
- official-letter draft
- paper draft
- extracted contract template
- filled template
- command/report evidence

## Result

GroundPA now has a clearer Word routing contract:

1. Use COM or LibreOffice only to cross the legacy `.doc` boundary when needed.
2. Use `nong word` for deterministic inspection, repair, generation, validation, and reporting.
3. Load detailed existing-document instructions only when the task actually needs them.
