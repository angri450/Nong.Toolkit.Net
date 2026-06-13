# DocxWriter Skill — API Reference
# For Claude: all available classes and methods in DocxCore v2.0

## DocumentWriter Methods

Constructors:
- `new DocumentWriter(body)` — basic, body is the WordprocessingDocument Body
- `new DocumentWriter(body, doc)` — full, supports footnotes/endnotes/charts/image embedding

### Chinese Title & Abstract

```csharp
w.Title("论文标题")                      // Chinese main title (Title style)
w.SubTitle("副标题")                     // Subtitle (SubTitle style)
w.AbstractTitle("摘  要")               // Abstract heading, default "摘  要" (AbstractTitle style)
w.Abstract("摘要正文...")               // Abstract body (Abstract style)
w.Keywords("关键词1；关键词2；关键词3")   // Keywords, "关键词：" in bold
```

### English Title & Abstract

```csharp
w.EnglishTitle("English Title")                      // English title (EnglishTitle style, TNR 14pt bold centered)
w.EnglishAbstractTitle("Abstract")                   // English abstract heading, default "Abstract"
w.EnglishAbstract("Abstract content...")             // English abstract body
w.EnglishKeywords("keyword1; keyword2; keyword3")    // English keywords, "Key words: " in bold
```

### Headings (auto-numbered)

```csharp
w.Heading("Introduction", 1)    // Level 1 → "1  Introduction"
w.Heading("Methods", 2)         // Level 2 → "1.1  Methods"
w.Heading("Details", 3)         // Level 3 (no numbering)
```

Level-2 counter resets to zero on each level-1 call.

### Body Text

```csharp
w.Body("This is body text[1]. More content.")
```

`[N]` citation markers auto-detected and rendered as superscript (font size 18). Uses Normal style.

### Tables

```csharp
// Three-line table
w.Table("Table caption", tableNum,
    new[] { "Col1", "Col2", "Col3" },
    new[] { new[]{"data1","data2","data3"}, new[]{"data4","data5","data6"} })

// Variable operationalization table
w.VariableTable("Variable operationalization table", 1, variablePlanRows)

// Apply Word built-in table style
w.TableStyle(TableStyles.LightGridAccent1)
```

### Charts & Figures

```csharp
w.Figure("Figure caption", figNum)                               // Figure placeholder (text)
w.BarChart("Yield comparison", categories, values, "Series 1")   // Bar chart (requires doc constructor)
```

### Table of Contents

```csharp
w.TableOfContents("Contents")  // Heading + TOC field + page break
```

### References

```csharp
w.BibHeading("References")           // References heading, default "参考文献"
w.References("entry1", "entry2")     // Each entry uses ReferenceText style
```

### Footnotes & Endnotes (requires doc constructor)

```csharp
w.Footnote("Footnote content")    // Auto-incrementing number, superscript ref in body
w.Endnote("Endnote content")      // Same but placed at document end
```

### Cross-References & Hyperlinks

```csharp
w.Bookmark("_Toc001")                                  // Insert bookmark
w.CrossReference("_Toc001", "see Table 1")            // Internal cross-reference
w.Hyperlink("https://example.com", "Example Link")    // External hyperlink
```

## Class Index

### Document Generation

| Class | Purpose |
|-------|---------|
| `DocumentWriter` | Chainable document writer (core) |
| `SectionBuilder` | Page layout (A4/Letter, cm/twips margins, header/footer binding, FromJson) |
| `TableBuilder` | Table builder (three-line tables + built-in styles) |
| `ParagraphBuilder` | Paragraph builder |
| `HeaderFooterBuilder` | Headers and footers (page numbers) |
| `StyleBuilder` | Style definitions (BuildAll hardcoded / BuildFromJson JSON-driven) |
| `ElementOrder` | ECMA-376 child element ordering + orphan border fix |

### Image & Embedding

| Class | Purpose |
|-------|---------|
| `ImageEmbedder` | Image embedding (first 2 side-by-side 1x2, rest vertical) |
| `ImageHeaderReader` | Lightweight image header parser (PNG/JPEG/GIF/BMP/TIFF dimensions) |

### Template Engine

| Class | Purpose |
|-------|---------|
| `DocxTemplate` | Template engine ({{tag}}, @if/@endif, @foreach/@endforeach, table row binding) |
| `TemplateEngine` | Format fingerprint extraction (Analyze, ExtractImages, InferFormat) |

### Table Styles

| Class | Purpose |
|-------|---------|
| `TableStyles` | 90+ Word built-in table style constants (LightShading, MediumGrid, Colorful, etc.) |

### TOC & Charts

| Class | Purpose |
|-------|---------|
| `TocAndChartBuilder` | Table of contents generation + bar charts |

### Advanced Features

| Class | Purpose |
|-------|---------|
| `AdvancedFeatures` | Comments, track changes, content controls, font embedding, document merge, properties, protection |

### Preview & Validation

| Class | Purpose |
|-------|---------|
| `WordPreview` | Document preview + 7-step diagnostics + OpenXmlValidator integration |

### Paper Analysis

| Class | Purpose |
|-------|---------|
| `PaperTypeClassifier` | 16 paper type keyword classification, Classify(text) returns sorted match scores |
| `PaperStructureExtractor` | Paper structure extraction (section splitting, title/authors/abstract/keywords, table extraction) |
| `ReferenceAnalyzer` | Reference risk analysis (entry extraction, format checks, citation matching, search strategy) |
| `VariablePlanGenerator` | Variable operationalization table and 7 data collection plan generators |
| `PaperDiagnostics` | Evidence chain (10 items), data requirements (9 items), gap grade (A-E), chart suggestions, semantic diagnosis, 3-tier quality classification |

### Data Models

| Class | Purpose |
|-------|---------|
| `PaperTypeInfo` | Paper type match result |
| `PaperStructure`, `PaperSection` | Paper structure |
| `ReferenceEntry`, `ReferenceRisk` | Reference entries and risks |
| `EvidenceChainItem`, `DataRequirementItem` | Evidence chain and data requirement diagnosis |
| `GapGrade`, `QualityIssue`, `QualityDiagnosis` | Gap grade and quality diagnosis |
| `VariablePlanRow` | Variable operationalization table row |
| `ChartTableSuggestion`, `SemanticDiagnosisItem` | Chart suggestions and semantic diagnosis |
| `MiniWordPicture`, `MiniWordHyperLink`, `MiniWordColorText` | Template special value types |

## Style Configuration

### JSON-Driven Formatting (Recommended)

```csharp
StyleBuilder.BuildFromJson(sp.Styles, "formats/life-sciences-contest.json");
StyleBuilder.LoadPageLayout("formats/life-sciences-contest.json").Build();
```

Reads a format JSON to auto-generate styles and page layout. Swap format = swap JSON path.

JSON key to internal style ID mapping:
| JSON Key | Internal ID | Notes |
|----------|-------------|-------|
| Body | Normal | Body text |
| ReferenceHeading | BibHeading | References heading |
| Reference | ReferenceText | Reference entries |

Other keys match internal IDs directly. Auxiliary styles not defined in JSON (BodyTextNoIndent, FootnoteText, etc.) are auto-completed.

### Hardcoded Fallback (Backward Compatible)

```csharp
StyleBuilder.BuildAll(sp.Styles);
StyleBuilder.BuildNumbering(np.Numbering);
```

## Key Conventions

- Three-line table borders: thick 6 (0.75pt), thin 4 (0.5pt)
- Font sizes in half-points: 五号=21, 小五号=18, 四号=28, 六号=15, 三号=32
- Use `BodyTextNoIndent` style to avoid inheriting Normal's first-line indent
- Page: A4 (11906x16838 twips), 2cm=1134 twips, 2.5cm=1418 twips, 3cm=1701 twips
- Drawing namespace conflicts require alias: `using D = DocumentFormat.OpenXml.Drawing.Wordprocessing;`
- Single dependency: `DocumentFormat.OpenXml` — no System.Drawing.Common, no ImageSharp
