# PPT Read Reference

## Open a presentation

```csharp
using PptxCore;
using ShapeCrawler;

// Open existing file
using var pres = new Presentation("input.pptx");

// Text preview (all slides as Markdown)
Console.WriteLine(pres.AsMarkdown());

// Detailed structured preview
var result = SlidePreview.Preview(pres);
Console.WriteLine(result.Text);
foreach (var w in result.Warnings) Console.WriteLine($"WARN: {w}");
```

## Inspect structure

```csharp
// Slide count
int count = pres.Slides.Count;

// Slide dimensions (points)
decimal w = pres.SlideWidth;   // 960 = 16:9
decimal h = pres.SlideHeight;  // 540 = 16:9

// Properties
string? title = pres.Properties.Title;
string? author = pres.Properties.Author;
string? company = pres.Properties.Company;
```

## Read slide content

```csharp
var slide = pres.Slide(1);  // 1-based

// All shapes
foreach (var shape in slide.Shapes)
{
    Console.WriteLine($"{shape.Name}: {shape.ContentType} at ({shape.X},{shape.Y})");
}

// Text boxes
foreach (var shape in slide.Shapes)
{
    if (shape.TextBox != null)
    {
        string text = shape.TextBox.Text;
        var font = shape.TextBox.Paragraphs[0].Portions[0].Font;
        Console.WriteLine($"Font: {font?.LatinName} {font?.Size}pt Bold={font?.IsBold}");
    }
}

// Tables
var tableShape = slide.Shapes.First(s => s.Table != null);
var table = tableShape.Table!;
for (int r = 0; r < table.Rows.Count; r++)
    for (int c = 0; c < table.Columns.Count; c++)
        Console.WriteLine(table[r, c].TextBox.Text);

// Charts
var chartShape = slide.Shapes.First(s => s.PieChart != null);
var chart = chartShape.PieChart!;
foreach (var series in chart.SeriesCollection)
    foreach (var point in series.Points)
        Console.WriteLine($"Value: {point.Value}");

// Notes
string? notes = slide.Notes?.Text;
```

## Export as Markdown

```csharp
string markdown = pres.AsMarkdown();
File.WriteAllText("output.md", markdown);
```

## Shape Map (inspect before editing)

Before editing an existing presentation, always get a shape map. This tells you exactly what's on each slide — names, types, text previews — so you never guess shape names or read raw XML.

```csharp
using PptxCore;

// From file path
var map = SlidePreview.ShapeMap("input.pptx");
Console.WriteLine(map.Json);

// From already-opened presentation
var map = SlidePreview.ShapeMap(pres);
Console.WriteLine(map.Json);
```

Returns JSON:
```json
{
  "slideCount": 3,
  "slideWidth": 960,
  "slideHeight": 540,
  "slides": [
    {
      "index": 1,
      "layout": "Title Slide",
      "shapes": [
        {
          "name": "Title 1",
          "type": "TextBox",
          "placeholder": "title",
          "text": "年度报告 2024",
          "fontSize": 36.0,
          "fontName": "微软雅黑",
          "position": {"x": 80, "y": 60, "w": 800, "h": 80}
        },
        {
          "name": "Subtitle 2",
          "type": "TextBox",
          "placeholder": "subtitle",
          "text": "业绩回顾与展望",
          "fontSize": 24.0,
          "position": {"x": 80, "y": 180, "w": 800, "h": 50}
        }
      ]
    }
  ]
}
```

Use the `name` field to target shapes in edit operations. Use `placeholder` to filter by role (all "title" shapes across slides, etc.).

## Raw XML Access (L3 — fallback only)

When the high-level API cannot express what you need, use the L3 raw OOXML path.

```csharp
using PptxCore;

var accessor = new RawAccessor("input.pptx");

// Read any part
string slide1Xml = accessor.GetPart("/ppt/slides/slide1.xml");
string presentationXml = accessor.GetPart("/ppt/presentation.xml");
string contentTypes = accessor.GetPart("/[Content_Types].xml");

// Modify and save
accessor.SetPart("/ppt/slides/slide1.xml", modifiedXml);
accessor.SaveAs("output.pptx");
```

**Only use when SlideBuilder/ShapeCrawler cannot do the job.** Common fallback cases:
- Removing `printerSettings` parts for Keynote import compatibility
- Fixing broken `p:sldSz` with incorrect `type=screen4x3` on widescreen decks
- Deleting unused slide layouts or masters
- Repairing relationship ID cross-references
- Stripping sensitivity labels before processing
