# Cloud OCR — PaddleOCR-VL-1.6 API

Document recognition via Baidu PaddlePaddle cloud API. Supports images and PDFs. Output: Markdown or Word.

## Quick Start

```powershell
dotnet new console -n OcrTask -o <target-dir> --force
dotnet add <target-dir> package Angri450.Nong.MultiModal
```

```csharp
using MultiModalCore;

$env:PADDLEOCR_TOKEN = "your-token";
var client = new PaddleOcrVlClient();

// Recognize an image or PDF → Markdown
var mdFiles = await client.ProcessAsync("scan.png", outBase);
// → output/<timestamp>+<project>+<seq>/doc_0.md, ...

// Direct Word output (layout-preserving)
var docxPath = await client.ProcessToWordAsync("scan.pdf",
    Path.Combine(outBase, "result.docx"));
```

## Full Template

```csharp
using MultiModalCore;

var client = new PaddleOcrVlClient(); // reads PADDLEOCR_TOKEN from env
var outBase = Path.Combine(
    Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
    "GroundPA Toolkit Workplace", "output",
    $"<timestamp>+<project>+<seq>");
Directory.CreateDirectory(outBase);

try
{
    var mdFiles = await client.ProcessAsync(args[0], outBase);
    Console.WriteLine($"Done: {mdFiles.Count} files");
    foreach (var f in mdFiles)
        Console.WriteLine($"  {f}");
}
catch (PaddleOcrException ex)
{
    Console.WriteLine($"OCR failed: {ex.Message}");
    return 1;
}
```

## Optional Parameters

```csharp
var options = new OcrOptions
{
    UseDocOrientationClassify = true,   // document orientation detection
    UseDocUnwarping = true,             // document unwarping
    UseChartRecognition = true,         // chart parsing
};
await client.ProcessAsync("scan.pdf", outBase, options);
```

## Capabilities

| Feature | Notes |
|---|---|
| Text recognition | 111 languages, Chinese-English mixed |
| Table recognition | Outputs HTML table structure |
| Formula recognition | LaTeX output |
| Seal recognition | New in v1.6 |
| Chart parsing | Requires UseChartRecognition |
| Orientation detection | Requires UseDocOrientationClassify |
| Document unwarping | Requires UseDocUnwarping |

## Step-by-Step API

```csharp
var client = new PaddleOcrVlClient();

// 1. Submit job
var jobId = await client.SubmitFileAsync("scan.pdf");
// var jobId = await client.SubmitUrlAsync("https://.../scan.png");
// var jobId = await client.SubmitBytesAsync(bytes, "scan.png");

// 2. Wait for completion
var resultUrl = await client.WaitForJobAsync(jobId, TimeSpan.FromSeconds(5));

// 3. Download and save
var mdFiles = await client.DownloadResultsAsync(resultUrl, outBase);

// 4. Or get structured data
var ocrResult = await client.DownloadResultsStructuredAsync(resultUrl, outBase);
```

## Word Output Pipeline

`ProcessToWordAsync` internal flow:
1. Call cloud API to get layout analysis results (`prunedResult.parsing_res_list`)
2. Each block has `block_label` (doc_title/paragraph_title/text/image/table) and `block_bbox` (pixel coordinates)
3. `LayoutToWordConverter` + `Angri450.Nong.Docx` maps blocks to Word paragraphs:
   - doc_title → DocumentWriter.Title()
   - paragraph_title → DocumentWriter.Heading(2)
   - text → DocumentWriter.Body()
   - image → ImageEmbedder.EmbedSingleImage()
   - table → DocumentWriter.Table()
4. Auto-detects multi-column layout, renders with borderless tables
5. Calls ElementOrder.RectifyTree() to fix element ordering

## Limits

- API free quota: 20,000 pages/day
- Large PDFs should be submitted in batches
- Word output depends on `Angri450.Nong.Docx` package
