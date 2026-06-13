# Local OCR Reference

Local OCR is a Nong CLI path through Nong's pure .NET PP-OCRv5 runtime:

```powershell
nong ocr local scan.png --json
nong ocr local scan.png --force --json
```

It does not require Python, pip, or external OCR executables. Do not bypass Nong by calling OCR libraries directly from GroundPA.

## Required Gate

Run environment checks first:

```powershell
nong ocr check-env --json
nong ocr models --json
```

Expect `localDotNetPpOcrV5.status` to be `ok` and model entries to include `noPython: true`.

For deployment planning on a new client machine:

```powershell
nong ocr install-model pp-ocrv5-mobile --dry-run --json
```

This reports the .NET/NuGet deployment plan. Nong bundles the managed PP-OCRv5 model metadata; `install-model` deploys the current platform `Angri450.Nong.OcrRuntime.*` native runtime bundle into the Nong runtime cache from the Huawei NuGet source or a local NuGet cache. Runtime package versions track the CLI version; for Nong 3.2.5, expect `Angri450.Nong.OcrRuntime.*` 3.2.5. Upstream Sdcb/OpenCvSharp fallback is disabled by default and requires explicit `--allow-upstream-fallback`. A successful non-dry-run install/check cleans the temporary `runtimeCache\downloads` directory and reports `downloadCleanup`.

Preferred install command:

```powershell
nong ocr install-model pp-ocrv5-mobile --source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json --json
```

## Smoke Test

Only describe local OCR as available after a real image command exits 0:

```powershell
nong ocr local scan.png --json
```

If it returns E005, report the missing .NET native runtime dependency and run the Huawei-source `install-model` command above. If the first-party bundle is unavailable, report a NuGet publish/mirror-sync issue instead of silently falling back. Retry with NuGet.org only when the user accepts the non-mirror source. Use `--allow-upstream-fallback` only when the user explicitly accepts downloading upstream Sdcb/OpenCvSharp native packages. If the command is unavailable or returns E009, update/reinstall `Angri450.Nong.Cli` from the Huawei NuGet source before retrying.

If it returns E006 with `local_ocr_preflight_skipped`, the image is a decoded barcode/QR or looks QR/code-like or graphic-heavy rather than text-like. Do not retry local OCR in a loop. Use `data.preflight.barcode` when present, inspect it as an image asset, or rerun with `--force` only when the user explicitly wants PP-OCRv5 text recognition despite the warning.

## Capability Boundary

`ocr local` is for single-image text recognition. It is not a document-layout engine.

It does not support:

- PDF input.
- Cross-page image stitching.
- Page-aligned document parsing.
- Table structure reconstruction.
- Word formatting recovery.
- pandoc/NongMark annotation alignment.

For those tasks, use `ocr cloud` or `ocr to-word` with `PADDLEOCR_ACCESS_TOKEN`, then combine the cloud page/block output with `word dissect --output` and NongMark evidence.

## Numeric Warnings

Recent Nong builds sanitize invalid local inference numbers before JSON serialization. If Paddle/OpenCV returns NaN or Infinity confidence/geometry:

- JSON stays valid.
- `confidence` becomes `null`.
- `confidenceValid` or `geometryValid` becomes `false`.
- `issues` may include `local_ocr_numeric_fallback`, `local_ocr_invalid_confidence`, or `local_ocr_invalid_geometry`.
- Text mode shows invalid confidence as `n/a`.

Use the recognized text if it is visibly useful, but do not claim reliable confidence, position, layout, or formatting from degraded local OCR output.

## GroundPA Boundary

- Do not install or invoke OCR through Python from GroundPA.
- Do not add alternate local OCR scripts.
- Do not translate dependency or not-implemented errors into success.
- Do not prefer local OCR over cloud OCR unless the local gate has passed in this environment.
