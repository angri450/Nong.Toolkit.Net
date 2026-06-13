# skill cli package map

## What changed

- Added a Chinese HTML report that maps each Toolkit skill to:
  - its `nong` CLI command group;
  - its core package/project;
  - its direct dependency packages;
  - runtime repositories/packages when relevant.
- Clarified the OCR line explicitly:
  - Toolkit skill currently named `multimodal`
  - CLI group `nong ocr`
  - core package `Angri450.Nong.MultiModal`
  - runtime repository `Nong.OcrRuntime`
  - runtime packages `Angri450.Nong.OcrRuntime.*`
- Corrected the earlier OCR diagnosis: the three OCR sub-routes are already split into references; the remaining problem is naming and top-level alignment, not missing sub-materials.
- Updated the existing Toolkit skill-system audit so the OCR recommendation reflects the real repository state.

## Why

The user wants a clear "skill -> cli -> package" control axis. The current repository is only partially aligned, so the new report makes the exact routing chain explicit and highlights where names or ownership boundaries still require translation.

## Files touched

- `log/reports/toolkit-skill-cli-package-map.html`
- `log/reports/toolkit-skill-system-audit.html`
- `log/plans/2026-06-10-skill-cli-package-map.md`
- `log/changelog/2026-06-10-skill-cli-package-map.md`
- `log/plans/index.md`
- `log/changelog/index.md`

## Tests

- Targeted read audit only; no CLI behavior changed.

## Remaining risks

- This is still documentation and architecture clarification only.
- OCR naming drift remains in the actual skill files and README until the Toolkit renames `multimodal` or adds an explicit `ocr` skill entry.
