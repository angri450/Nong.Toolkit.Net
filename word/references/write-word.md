# Write Word — Document Generation

## 1. Template Selection (Required Before Every Write)

Present existing templates to the user. Ask explicitly.

Available format templates:

| # | Template | Body | Heading | Line Spacing | Margins | Use Case |
|---|----------|------|---------|-------------|---------|----------|
| 1 | life-sciences-contest | 宋体 10.5pt | 黑体 14pt | Single | 2cm | Contest (4-page limit, no personal info) |
| 2 | journal-paper | 宋体 10.5pt | 黑体 18pt | 312 | 3cm | Journal (GB/T 7714) |
| 3 | course-paper | 宋体 10.5pt | 黑体 14pt | 312 | 2.5cm | Course paper |
| 4 | degree-thesis | 宋体 12pt | 黑体 16pt | 360 | 3cm | Degree thesis |

Ask the user: **Which one? Need adjustments? Or provide a reference docx for auto-extraction?**

- Use existing → go to step 2, load with BuildFromJson
- Need adjustments → edit the corresponding JSON file fields
- Need new template → dissect reference docx, save result as `formats/xxx.json`, add entry to INDEX.md

## 2. Quick Start

1. Confirm format template (see above)
2. Write `Program.cs` via Write tool, call `StyleBuilder.BuildFromJson(sp.Styles, "formats/xxx.json")` to load styles
3. `dotnet run --project <project-path>` to generate docx
4. `dotnet run --project <project-path> -- preview output.docx` to preview + diagnose
5. Run `validate.ps1` for validation (includes content quality diagnosis), only deliver on PASS

## 3. DocumentWriter API Quick Reference

Full signatures in [api-reference.md](api-reference.md). Common call chain:

```csharp
// Basic constructor (no footnotes/endnotes/charts)
var w = new DocumentWriter(body);

// Full constructor (supports footnotes/endnotes/charts/image embedding)
var w = new DocumentWriter(body, doc);

// Title & abstract
w.Title("论文标题")
 .EnglishTitle("English Title")
 .AbstractTitle("摘  要")
 .Abstract("Abstract content...")
 .Keywords("keyword1; keyword2; keyword3")
 .EnglishAbstractTitle("Abstract")
 .EnglishAbstract("Abstract content...")
 .EnglishKeywords("keyword1; keyword2")

// Table of contents
 .TableOfContents("Contents")

// Sections (auto-numbered)
 .Heading("Introduction", 1)     // Level 1 → "1  Introduction"
 .Heading("Related Work", 2)     // Level 2 → "1.1  Related Work"
 .Heading("Details", 3)          // Level 3 (no numbering)

// Body ([N] auto-superscript)
 .Body("Body text[1].")

// Footnotes/endnotes (requires doc constructor)
 .Body("Text with citation").Footnote("Footnote explanation")
 .Body("Another paragraph").Endnote("Endnote content")

// Three-line table
 .Table("Table caption", tableNum,
    new[] { "Col1", "Col2", "Col3" },
    new[] { new[]{"data1","data2","data3"}, new[]{"data4","data5","data6"} })

// Variable operationalization table
 .VariableTable("Variable operationalization", 1, variablePlanRows)

// Table style
 .TableStyle(TableStyles.LightGridAccent1)

// Figures & charts
 .Figure("Figure caption", figNum)
 .BarChart("Yield comparison", categories, values, "Series 1")

// Cross-references
 .Bookmark("_Toc001")
 .CrossReference("_Toc001", "see Table 1")
 .Hyperlink("https://example.com", "Link text")

// References
 .BibHeading("References")
 .References("Author. Title[J]. Journal, Year, Vol(Issue): Pages.")
```

## 4. Template Fill Mode

DocxCore supports MiniWord-style placeholder replacement:

```csharp
// Prepare data
var data = new {
    Name = "Zhang San",
    Score = 95,
    Items = new[] { new { Product = "A", Price = 10 }, new { Product = "B", Price = 20 } }
};

// Fill template
DocxTemplate.Fill("template.docx", "output.docx", data);
```

Template syntax:
- `{{Name}}` — simple text replacement
- `{{Parent.Child}}` — nested property access (dot-notation)
- `@if(Condition == Value)` / `@endif` — conditional blocks
- `@foreach(List)` / `@endforeach` — loop blocks
- Table cells with `{{Collection.Field}}` — table row data binding

## 5. Page Layout

Use `SectionBuilder` instead of manual `SectionProperties`:

```csharp
var sectPr = new SectionBuilder()
    .A4()
    .Margins("3cm", "2.5cm", "2.5cm", "2cm")  // top bottom left right
    .Build();
```

Or load directly from format JSON:

```csharp
var sectPr = StyleBuilder.LoadPageLayout("formats/journal-paper.json").Build();
```

## 6. Image Embedding

```csharp
ImageEmbedder.EmbedImages(body, doc.MainDocumentPart, new[] { "fig1.png", "fig2.png", "fig3.png" });
// First two images side-by-side in borderless 1x2 table, rest stacked vertically
// Auto-reads dimensions (PNG/JPEG/GIF/BMP/TIFF), width-constrained to prevent overflow
```

## 7. Key Conventions

### Three-Line Tables
- Top/bottom borders: 0.75pt thick (Size=6), header underline: 0.5pt thin (Size=4)
- Cell text not indented (BodyTextNoIndent style)
- Table caption: 黑体 10.5pt, centered above table
- 90+ built-in styles available via `TableStyles.*` as alternative to three-line style

### References
Word native numbered list, format `[1] [2] [3]`. **Do not write `[1]` prefix in text** — Word auto-generates.

### Page
A4 (11906x16838 twips). Use `SectionBuilder` — no manual twips calculation needed.

## 8. Common Pitfalls

### Footnotes/Endnotes Require doc Constructor
`Footnote()` or `Endnote()` only work with `new DocumentWriter(body, doc)` constructor.

### Heading Auto-Numbering Is Built-In
`DocumentWriter.Heading()` auto-numbers. Pass plain title text (e.g. `"Introduction"` not `"1  Introduction"`).

### Namespace Conflicts
Drawing namespace imports cause conflicts with Wordprocessing. Use aliases:
```csharp
using D = DocumentFormat.OpenXml.Drawing.Wordprocessing;
```

### Dependency Chain
DocxCore v2.0 has one dependency: `DocumentFormat.OpenXml` (transitively: `DocumentFormat.OpenXml.Framework` + `System.IO.Packaging`). No System.Drawing.Common, no ImageSharp required.
