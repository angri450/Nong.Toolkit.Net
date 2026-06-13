# Cloud OCR Reference

GroundPA routes cloud OCR through Nong:

```powershell
nong ocr cloud scan.png -o ocr-out --json
nong ocr to-word scan.png -o out.docx --json
```

Both commands require `PADDLEOCR_ACCESS_TOKEN` in the environment. Do not place real access tokens in repository files, command logs, or examples.

## Cloud Recognition

```powershell
$env:PADDLEOCR_ACCESS_TOKEN = "<access-token>"
nong ocr cloud scan.png -o ocr-out --json
```

Use this for image or PDF recognition when cloud access is available. If the environment variable is missing, report that cloud smoke is skipped or blocked by credentials.

## Word Output

```powershell
$env:PADDLEOCR_ACCESS_TOKEN = "<access-token>"
nong ocr to-word scan.png -o out.docx --json
```

Use this when the requested output is a `.docx` generated from a scanned image or PDF.

## Contract

- Use `--json` for model-readable results.
- Treat `status: "error"` as failed.
- Do not call cloud OCR through custom wrappers from GroundPA.
- Do not claim cloud smoke success unless the credential is present and the command exits 0.
