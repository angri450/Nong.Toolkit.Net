---
name: ocr
description: OCR and image-structure QA via nong. Trigger on OCR, PaddleOCR, scanned image, image-to-Word, chart visual QA, or image structure analysis.
---

# OCR

Use `nong ocr` as the only entrypoint for OCR and image-structure analysis. Do not route through Python OCR libraries or custom OCR wrappers.

## Nong CLI Preflight

Read [../references/shared/nong-cli-preflight.md](../references/shared/nong-cli-preflight.md) before the first Nong command in a session. Confirm Nong.Cli.Net `4.1.0+` and the `ocr` command group.

**Modular (4.1.0+):** `nong ocr` routes to the standalone `Angri450.Nong.Tool.Ocr` dotnet tool. First use auto-installs. Command surface unchanged.

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
| Batch directory OCR | `nong ocr batch <dir> --pattern "*.png" --json` | [ocr-local.md](references/ocr-local.md) |
| Video frame OCR + subtitles | `nong ocr video <file> -o <dir> --json` | — |
| Screen region OCR (Win) | `nong ocr screen --region x,y,w,h --json` | — |
| Camera capture OCR | `nong ocr camera --device 0 --json` | — |
| Cloud OCR with layout | `nong ocr cloud <input> -o <dir> --json` | [ocr-cloud.md](references/ocr-cloud.md) |
| Image to Word | `nong ocr to-word <input> -o <out.docx> --json` | [ocr-cloud.md](references/ocr-cloud.md) |
| Image structure QA | `nong ocr analyze-image <img> -o <dir> --json` | [image-analyzer.md](references/image-analyzer.md) |
| Model inventory | `nong ocr models --json` | — |
| Install local model (v5) | `nong ocr install-model pp-ocrv5-mobile --source <mirror> --json` | [runtime-chain.md](references/runtime-chain.md) |
| Install local model (v6 default) | `nong ocr install-model pp-ocrv6-medium --json` | [runtime-chain.md](references/runtime-chain.md) |
| Install local model (v6 small) | `nong ocr install-model pp-ocrv6-small --json` | — |
| Install local model (v6 tiny) | `nong ocr install-model pp-ocrv6-tiny --json` | — |

## Implemented Commands

```powershell
nong ocr check-env --json
nong ocr analyze-image <image.png> -o <analysis-dir> --json
nong ocr cloud <image-or.pdf> -o <ocr-out-dir> --json
nong ocr to-word <image-or.pdf> -o <out.docx> --json
nong ocr local <image.png> --json
nong ocr local <image.png> --force --json
nong ocr batch <dir> --pattern "*.png" --json
nong ocr batch <dir> --pattern "*.jpg" --recursive --json
nong ocr video <video.mp4> -o <dir> --fps 1 --json
nong ocr video <video.mp4> -o <dir> --dedup-threshold 8 --json
nong ocr screen --region 100,100,800,600 --json
nong ocr screen --json
nong ocr camera --device 0 --interval 2000 --count 5 --json
nong ocr models --json
# v5
nong ocr install-model pp-ocrv5-mobile --source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json --json
nong ocr install-model pp-ocrv5-mobile --dry-run --json
# v6 (default: medium)
nong ocr install-model pp-ocrv6-medium --json
nong ocr install-model pp-ocrv6-small --json
nong ocr install-model pp-ocrv6-tiny --json
# pp-ocrv6 is an alias for pp-ocrv6-medium
nong ocr install-model pp-ocrv6 --json
```

## Dispatch

1. For environment status, run `nong ocr check-env --json`.
2. For chart or diagram visual QA, run `nong ocr analyze-image <image.png> -o <analysis-dir> --json`.
3. For single-image text recognition, run `nong ocr local <image.png> --json`. Auto-selects v6 if installed, falls back to v5.
4. For scanning a directory of images, run `nong ocr batch <dir> --pattern "*.png" --json`.
5. For extracting text from video frames, run `nong ocr video <video.mp4> -o <dir> --json`. Outputs frames JSON + SRT subtitle file.
6. For OCR on a screen region (Windows), run `nong ocr screen --region 100,100,800,600 --json`.
7. For periodic camera capture OCR, run `nong ocr camera --device 0 --interval 2000 --json`.
8. For PDF, multi-page scans, table/layout reconstruction, or Word/NongMark annotation alignment, require `PADDLEOCR_ACCESS_TOKEN`, then run `nong ocr cloud <input> -o <ocr-out-dir> --json`.
9. For Word output from a scan or PDF, require `PADDLEOCR_ACCESS_TOKEN`, then run `nong ocr to-word <input> -o <out.docx> --json`.
10. For model inventory, run `nong ocr models --json`. Default model is `pp-ocrv6-medium`.
11. For v6 local deployment (recommended), run `nong ocr install-model pp-ocrv6-medium --json`.
12. For v5 local deployment (legacy), run `nong ocr install-model pp-ocrv5-mobile --source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json --json`.

## Boundaries

- `ocr local`, `ocr batch`: single-image text recognition. No PDF, no layout analysis, no table structure, no Word formatting.
- `ocr video`: requires `opencv_videoio_ffmpeg*.dll` in the native runtime. Samples frames (default 1 fps) with dHash deduplication. Outputs both JSON and SRT.
- `ocr screen`: Windows only. Uses `Graphics.CopyFromScreen` + `GetSystemMetrics` User32 P/Invoke.
- `ocr camera`: requires a connected camera and `opencv_videoio_ffmpeg*.dll`. Captures at configurable interval.
- `ocr cloud` and `ocr to-word`: require `PADDLEOCR_ACCESS_TOKEN`. Support PDF, multi-page, table/layout reconstruction.
- `ocr analyze-image`: structural image QA. Does NOT recognize text.
- If local OCR returns E005, do not suggest Python or pip. See [runtime-chain.md](references/runtime-chain.md).