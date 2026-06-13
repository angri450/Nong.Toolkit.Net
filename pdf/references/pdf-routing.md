# PDF Routing Reference

## Text, Hybrid, Scan

Start every PDF workflow with:

```powershell
nong pdf check <file.pdf> --json
```

Use `data.classification`, `data.recommendedMode`, `data.hasTextLayer`, `data.textCharsPerPage`, `data.imageCoverageRatio`, and warnings to choose the route.

## Local Slice

For selectable-text and many hybrid PDFs:

```powershell
nong pdf dissect <file.pdf> --output <slice-dir> --mode auto --json
```

Read `content.nongmark`, `content.jsonl`, `structure.json`, `format.json`, `diagnostics/check.json`, and `diagnostics/reading-order.json`. Then use the `slice` skill for strict package reads.

## Visual And Asset Evidence

Use page rendering when visual layout matters:

```powershell
nong pdf render <file.pdf> --output <pages-dir> --dpi 150 --json
```

Use embedded image extraction when provenance matters:

```powershell
nong pdf images <file.pdf> --output <assets-dir> --json
```

## OCR Boundary

Use `pdf dissect --mode ocr` only after `nong ocr check-env` and `nong ocr install-model pp-ocrv5-mobile` succeed. Local OCR is text recognition, not a full page-layout reconstruction engine.
