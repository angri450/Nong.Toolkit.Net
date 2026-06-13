# Local OCR — PaddleOCR CPU

Local PaddleOCR text recognition via Python subprocess. For offline use or sensitive documents.

## Prerequisites

```powershell
pip install paddlepaddle paddleocr
```

Verify the environment:

```csharp
var local = new LocalOcrClient(pythonExe: "python", lang: "ch");
var (ok, msg) = await local.CheckEnvironmentAsync();
Console.WriteLine(msg); // "PaddleOCR environment ready" or error details
```

## Single Image Recognition

```csharp
var local = new LocalOcrClient();

// From file
var blocks = await local.RecognizeAsync("crop.png");
foreach (var b in blocks)
    Console.WriteLine($"[{b.Confidence:P0}] {b.Text}");

// From memory
byte[] imageBytes = ...;
var blocks = await local.RecognizeAsync(imageBytes);
```

## Output Structure

```csharp
public record LocalOcrBlock
{
    public float[] Bbox { get; init; }     // [x0, y0, x1, y1] pixel coordinates
    public string Text { get; init; }      // recognized text
    public float Confidence { get; init; } // confidence 0-1
}
```

## Batch Recognition

```csharp
var results = await local.RecognizeBatchAsync(new[] { "page1.png", "page2.png" });
```

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `pythonExe` | `"python"` | Python executable path |
| `scriptPath` | auto-detect | Path to ocr_local.py |
| `lang` | `"ch"` | OCR language (ch/en/fr/german/korean/japan) |
| `useGpu` | `false` | Enable GPU acceleration |
| `timeout` | 3 min | Per-image OCR timeout |

## How It Works

1. `LocalOcrClient` spawns a Python child process
2. Python script calls `paddleocr.PaddleOCR(lang='ch').ocr(image_path)`
3. Results serialized to JSON via stdout
4. C# side parses JSON → `List<LocalOcrBlock>`

## Relationship with Cloud API

- Cloud API handles layout analysis + special elements (tables/formulas/seals)
- Local OCR handles text block character recognition
- This Hybrid pattern saves API quota; currently requires manual orchestration
- Future `MultiModalClient.HybridProcessAsync()` will automate this flow

## Roadmap

- ONNX Runtime pure .NET inference, removing Python dependency
- Direct integration into `Angri450.Nong.MultiModal` Hybrid mode
