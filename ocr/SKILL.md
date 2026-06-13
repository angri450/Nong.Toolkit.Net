---
name: ocr
description: OCR and image-structure QA via nong. Trigger on OCR, PaddleOCR, scanned image, image-to-Word, chart visual QA, or image structure analysis.
---

# OCR

Use `nong ocr` as the only entrypoint for OCR and image-structure analysis. Do not route through Python OCR libraries or custom OCR wrappers.

## Nong CLI Preflight

Read [../references/shared/nong-cli-preflight.md](../references/shared/nong-cli-preflight.md) before the first Nong command in a session. Confirm Nong.Cli.Net `4.0.0+` and the `ocr` command group.

## Prerequisites

Run once before OCR work:

```powershell
nong ocr check-env --json
```

Cloud OCR and image-to-Word require this environment variable:

```powershell
$env:PADDLEOCR_ACCESS_TOKEN = "<access-token>"
```

Get the cloud token from `https://aistudio.baidu.com/account/accessToken`. If the user has no token, use local OCR only after its smoke test passes.

Do not write real credentials into repository files, logs, or examples.

## Route Table

| User wants | Command | Reference |
|------------|---------|-----------|
| Environment check | `nong ocr check-env --json` | — |
| Single-image text OCR | `nong ocr local <img> --json` | [ocr-local.md](references/ocr-local.md) |
| Cloud OCR with layout | `nong ocr cloud <input> -o <dir> --json` | [ocr-cloud.md](references/ocr-cloud.md) |
| Image to Word | `nong ocr to-word <input> -o <out.docx> --json` | [ocr-cloud.md](references/ocr-cloud.md) |
| Image structure QA | `nong ocr analyze-image <img> -o <dir> --json` | [image-analyzer.md](references/image-analyzer.md) |
| Model inventory | `nong ocr models --json` | — |
| Install local model | `nong ocr install-model pp-ocrv5-mobile --source <mirror> --json` | [runtime-chain.md](references/runtime-chain.md) |

## Implemented Commands

```powershell
nong ocr check-env --json
nong ocr analyze-image <image.png> -o <analysis-dir> --json
nong ocr cloud <image-or.pdf> -o <ocr-out-dir> --json
nong ocr to-word <image-or.pdf> -o <out.docx> --json
nong ocr models --json
nong ocr install-model pp-ocrv5-mobile --source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json --json
nong ocr install-model pp-ocrv5-mobile --dry-run --json
```

Gated local path:

```powershell
nong ocr local <image.png> --json
nong ocr local <image.png> --force --json
```

## Dispatch

1. For environment status, run `nong ocr check-env --json`.
2. For chart or diagram visual QA, run `nong ocr analyze-image <image.png> -o <analysis-dir> --json`.
3. For PDF, multi-page scans, table/layout reconstruction, page-aligned OCR, or Word/NongMark annotation alignment, require `PADDLEOCR_ACCESS_TOKEN`, then run `nong ocr cloud <input> -o <ocr-out-dir> --json`.
4. For Word output from a scan or PDF, require `PADDLEOCR_ACCESS_TOKEN`, then run `nong ocr to-word <input> -o <out.docx> --json`.
5. For model inventory, run `nong ocr models --json`.
6. For local deployment, run `nong ocr install-model pp-ocrv5-mobile --source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json --json`. See [runtime-chain.md](references/runtime-chain.md) for the full install chain.
7. Use `ocr local` only for single-image text recognition after `check-env` reports `localDotNetPpOcrV5.status=ok` and an actual image smoke test exits 0.

## Boundaries

- `ocr local` is single-image text recognition only. No PDF, no layout analysis, no table structure, no Word formatting. See [ocr-local.md](references/ocr-local.md).
- `ocr cloud` and `ocr to-word` require `PADDLEOCR_ACCESS_TOKEN`. They support PDF, multi-page, table/layout reconstruction, page-level structure, and Word/NongMark annotation alignment.
- `ocr analyze-image` performs structural image QA and does NOT recognize text.
- If local OCR returns E005, do not suggest Python or pip. Check the runtime chain in [runtime-chain.md](references/runtime-chain.md).
- If runtime packages are missing, see [runtime-chain.md](references/runtime-chain.md) for the `Nong.OcrRuntime` repository link.
