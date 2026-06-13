---
name: multimodal
description: >
  Multi-modal document processing — OCR recognition, speech-to-text, text-to-speech.
  MUST use this skill when the user wants to OCR an image/PDF, extract text from scanned
  documents, convert document images to Word/Markdown, recognize text from screenshots,
  or process documents with PaddleOCR. Also trigger when the user mentions OCR, 识别,
  扫描, 提取文字, 图片转文字, PDF转Word, PaddleOCR, 多模态, multimodal, or 文档解析
  — even if they do not explicitly say "multimodal". First capability: PaddleOCR-VL-1.6
  cloud API + local PaddleOCR CPU.
---

# MultiModal — Document Intelligence

Two independent capabilities, loaded on demand:

- **Cloud OCR** → load [ocr-cloud.md](references/ocr-cloud.md)
- **Local OCR** → load [ocr-local.md](references/ocr-local.md)

## Dependencies

- .NET SDK 11.0 (`dotnet` command available)
- NuGet: `Angri450.Nong.MultiModal`

If .NET SDK 11.0 is missing, stop immediately and tell the user to install it. Do not attempt to fix.

## Dispatch Logic

1. User mentions "API", "cloud", "PaddleOCR-VL", "online" → **load ocr-cloud.md**
2. User mentions "local", "offline", "CPU", "without network" → **load ocr-local.md**
3. User mentions "Word", "docx", "layout", "formatting" → **load ocr-cloud.md** (Word output comes from cloud API pipeline)
4. Both → cloud first, local as fallback

## Core Operations

### Cloud OCR (PaddleOCR-VL-1.6 API)

```csharp
using MultiModalCore;

// Token read from PADDLEOCR_TOKEN environment variable
var client = new PaddleOcrVlClient();
var outDir = Path.Combine(
    Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
    "GroundPA Toolkit Workplace", "output",
    $"<timestamp>+<project>+<seq>");
Directory.CreateDirectory(outDir);

// One-shot OCR → Markdown
var mdFiles = await client.ProcessAsync("scan.pdf", outDir);

// One-shot OCR → Word (layout-preserving)
var docxPath = await client.ProcessToWordAsync("scan.pdf",
    Path.Combine(outDir, "result.docx"));
```

### Local OCR (PaddleOCR CPU)

```csharp
var local = new LocalOcrClient(pythonExe: "python", lang: "ch");
var (ok, msg) = await local.CheckEnvironmentAsync();
if (ok) {
    var blocks = await local.RecognizeAsync("crop.png");
}
```

## Workspace

First use: scaffold a console project under the standard workspace:

```powershell
dotnet new console -n OcrTask -o <target-dir> --force
dotnet add <target-dir> package Angri450.Nong.MultiModal
```

Suggest `~/Documents/GroundPA Toolkit Workplace/multimodal/OcrTask/` as the working directory. After setup, each session only modifies `Program.cs`.

Write a `Program.cs` with the OCR task. See [ocr-cloud.md](references/ocr-cloud.md) for the full template.

Output goes to `~/Documents/GroundPA Toolkit Workplace/output/<timestamp>+<project>+<seq>/`.

## Token Configuration

Set the `PADDLEOCR_TOKEN` environment variable, or pass it to the constructor:

```powershell
$env:PADDLEOCR_TOKEN = "your-token"
```
