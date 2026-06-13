---
name: multimodal
description: OCR and image-structure QA via nong. Trigger on OCR, PaddleOCR, scanned image, image-to-Word, chart visual QA, or multimodal document extraction.
---

# Multimodal / OCR

Use `nong ocr` as the only GroundPA entrypoint for OCR and image-structure analysis. Do not route GroundPA through Python OCR libraries or custom OCR wrappers.

## Prerequisites

Run once before OCR work:

```powershell
nong ocr check-env --json
```

Cloud OCR and image-to-Word require this environment variable:

```powershell
$env:PADDLEOCR_ACCESS_TOKEN = "<access-token>"
```

Do not write real credentials into repository files, logs, or examples.

## Implemented Commands

Exposed CLI commands:

```powershell
nong ocr check-env --json
nong ocr analyze-image <image.png> -o <analysis-dir> --json
nong ocr cloud <image-or.pdf> -o <ocr-out-dir> --json
nong ocr to-word <image-or.pdf> -o <out.docx> --json
nong ocr models --json
nong ocr install-model pp-ocrv5-mobile --json
```

Gated local path:

```powershell
nong ocr local <image.png> --json
```

## Dispatch

1. For environment status, run `nong ocr check-env --json`.
2. For chart or diagram visual QA, run `nong ocr analyze-image <image.png> -o <analysis-dir> --json`.
3. For text/document recognition through PaddleOCR cloud, require `PADDLEOCR_ACCESS_TOKEN`, then run `nong ocr cloud <input> -o <ocr-out-dir> --json`.
4. For Word output from a scan or PDF, require `PADDLEOCR_ACCESS_TOKEN`, then run `nong ocr to-word <input> -o <out.docx> --json`.
5. For model inventory, run `nong ocr models --json`.
6. For model installation, run `nong ocr install-model pp-ocrv5-mobile --json` and treat E009 as an external capability limitation, not a successful install.
7. Use `ocr local` only after `check-env` and an actual image smoke test both exit 0. It may return E005 or E009 when the local PP-OCRv5 path is missing or unsupported.

## Boundaries

`ocr analyze-image` performs structural image QA and does not recognize text. It checks layout-oriented signals such as whitespace, content bounds, and visible content regions.

`ocr cloud` and `ocr to-word` require `PADDLEOCR_ACCESS_TOKEN`.

`ocr local` is an implemented CLI entrypoint but is a gated local path. Do not describe it as a stable OCR route unless the local environment and a real image smoke test have passed.

Treat `status: "error"` as failed. Do not mask E005/E009 as success.
