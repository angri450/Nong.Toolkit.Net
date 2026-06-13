---
name: multimodal
description: OCR and image-structure QA via nong. Trigger on OCR, PaddleOCR, scanned image, image-to-Word, chart visual QA, or multimodal document extraction.
---

# Multimodal / OCR

Use `nong ocr` as the only GroundPA entrypoint for OCR and image-structure analysis. Do not route GroundPA through Python OCR libraries or custom OCR wrappers.

## Nong CLI Preflight

Claude Plugin Marketplace installs the skills, not the `nong` CLI. Verify the CLI before OCR work:

```powershell
nong commands --json
```

If `nong` is missing, install or update:

```powershell
dotnet tool install --global Angri450.Nong.Cli --add-source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json
dotnet tool update --global Angri450.Nong.Cli --add-source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json
```

Use Nong 3.2.5+ for the pure .NET PP-OCRv5 runtime bundle flow. If the .NET host says no compatible framework was found, update to Nong 3.2.5+ or set `DOTNET_ROLL_FORWARD=LatestMajor` for the current shell and retry.

## OCR Prerequisites

Run once before OCR work:

```powershell
nong ocr check-env --json
```

Cloud OCR and image-to-Word require this environment variable:

```powershell
$env:PADDLEOCR_ACCESS_TOKEN = "<access-token>"
```

Get the cloud token from the PaddleOCR/AI Studio access-token page: `https://aistudio.baidu.com/account/accessToken`. If the user has no token, use local OCR only after its smoke test passes.

Do not write real credentials into repository files, logs, or examples.

## Implemented Commands

Exposed CLI commands:

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
6. For local deployment, run `nong ocr install-model pp-ocrv5-mobile --source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json --json`; it should report `noPython: true`, `upstreamFallbackDefault: "disabled"`, and an `Angri450.Nong.OcrRuntime.*` package for the current platform. Runtime package versions track the CLI version, so Nong 3.2.5 expects first-party runtime bundles at 3.2.5.
7. Use `ocr local` only for single-image text recognition after `check-env` reports `localDotNetPpOcrV5.status=ok` and an actual image smoke test exits 0.

## Boundaries

`ocr analyze-image` performs structural image QA and does not recognize text. It checks layout-oriented signals such as whitespace, content bounds, and visible content regions.

`ocr cloud` and `ocr to-word` require `PADDLEOCR_ACCESS_TOKEN`. Use cloud OCR when the user needs page-level structure, table/layout labels, image/PDF input, Word output, or output aligned with Word's `nongmark/v1` slice fields such as `content.jsonl`, `blockId`, and page/block evidence.

`ocr local` is an implemented CLI entrypoint through Nong's pure .NET PP-OCRv5 runtime. It is text-only and single-image only. It does not support PDF, cross-page image stitching, layout analysis, table structure, Word formatting, or pandoc/NongMark annotation alignment. Do not describe it as a stable OCR route unless the local environment and a real image smoke test have passed.

Before local PP-OCRv5 inference, `ocr local` runs a lightweight preflight: ZXing.Net barcode/QR decoding first, then image-structure heuristics. If it returns `E006 validation_failed` with issue `local_ocr_preflight_skipped`, the input is a decoded barcode/QR or looks code-like/graphic-heavy rather than text-like. Do not retry repeatedly. Use the decoded barcode/QR value when `data.preflight.barcode` is present, inspect the image as an asset, or rerun with `--force` only when the user explicitly wants text OCR despite the warning.

If `ocr local --json` reports `local_ocr_invalid_confidence`, `local_ocr_invalid_geometry`, or `local_ocr_numeric_fallback`, keep the recognized text if useful but report that local OCR confidence/geometry evidence is degraded. Do not turn those warnings into layout or formatting claims.

Treat `status: "error"` as failed. Do not mask dependency or not-implemented errors as success.

If local OCR returns E005, do not suggest Python or pip. Install/check the current-platform first-party runtime bundle with the Huawei NuGet source. If that reports the first-party bundle is unavailable, tell the user the NuGet/Huawei mirror has not synced yet; retry with NuGet.org only when the user accepts the non-mirror source. Use `--allow-upstream-fallback` only when the user explicitly accepts downloading upstream Sdcb/OpenCvSharp native packages.
