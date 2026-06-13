# Local OCR Reference

Local OCR is a gated Nong CLI path:

```powershell
nong ocr local scan.png --json
```

It is implemented as a CLI entrypoint, but it may return E005 or E009 unless the local PP-OCRv5 path is installed, discoverable, and verified with a real image.

## Required Gate

Run environment and model checks first:

```powershell
nong ocr check-env --json
nong ocr models --json
```

If model installation is needed:

```powershell
nong ocr install-model pp-ocrv5-mobile --json
```

Treat E009 from installation as an honest external limitation. Do not continue as though local OCR is available.

## Smoke Test

Only describe local OCR as available after a real image command exits 0:

```powershell
nong ocr local scan.png --json
```

If it returns E005 or E009, report the limitation and use cloud OCR only when `PADDLEOCR_ACCESS_TOKEN` is available.

## GroundPA Boundary

- Do not install or invoke OCR through Python from GroundPA.
- Do not add alternate local OCR scripts.
- Do not translate E005/E009 into success.
- Do not prefer local OCR over cloud OCR unless the local gate has passed in this environment.
