# Read Word — Document Reading and Feature Extraction

## Quick Start

### Format Fingerprint Extraction

```csharp
var result = TemplateEngine.Analyze(@"path\to\document.docx");
```

Returns `TemplateResult` with three parts:
1. `DefinedStyles` — styles defined in the document
2. `Paragraphs` — each paragraph's content + formatting + format hints
3. `Issues` — formatting problems found

### Paper Structure Extraction (v2.0)

```csharp
var structure = PaperStructureExtractor.BuildPaperStructure(paperText);
```

Returns `PaperStructure` with: Title, Authors, Abstract, Keywords, Sections (with canonical labels), Tables.
Supports 14 canonical section types (abstract, keywords, introduction, literature_review, theory, research_question, method, data, variables, results, discussion, conclusion, references, appendix).

### Document Preview & Diagnosis

```csharp
var preview = WordPreview.Preview(@"path\to\document.docx");
```

Returns `PreviewResult` with: Text (first 3000 chars), Warnings, Errors, Info, Statistics (paragraph/table/image counts, fonts, OOXML validation results). Integrates OpenXmlValidator for formal OOXML schema validation.

## 阅读能力

### L1: Plain Text Extraction
`paragraph.InnerText` returns all text. Good for quick browsing.

### L2: Paragraph Structure
Each paragraph outputs: style ID, style name, text content, actual font/size/bold/alignment/indent. Good for understanding document structure.

### L3: Format Feature Extraction
Each paragraph also outputs `FormatHints` — format descriptions parsed from text content:
- Font names: "黑体", "宋体", "Times New Roman"
- Size keywords: "四号"(28) → size=四号, "小五号"(18) → size=小五号
- Style keywords: "加粗"(bold), "居中"(centered), "首行缩进"(first-line indent)

### L4: Style Inference
`TemplateEngine.InferFormatFromText(paragraphText)` maps textual descriptions to concrete format parameters:
- "黑体, 四号, 居中" → Font=黑体, Size=28, Align=Center
- "宋体, 小五号, 加粗" → Font=宋体, Size=18, Bold=True

### L5: Format Contamination Detection
Detects WPS/Office compatibility issues:
- Theme font overrides on explicit fonts (rFonts with `*Theme` attributes)
- Unexpected overrides in style inheritance chain
- Manual formatting inconsistent with style definitions

## Feature Deposition (Key Rule)

**Do not auto-save.** After each read, report what format features were found, then **ask the user**:

> Does this document's formatting have anything worth saving? Saved formats can be reused for similar needs next time.

Only write to `formats/` and update INDEX.md when the user explicitly says "save" or "record". Skip if user says "no".

Same rule applies to image extraction (see below).

只有用户明确说"保存"或"记下来"，才写入 `formats/` 目录并更新 INDEX.md。用户说"不用"就跳过。

保存格式同上。同样规则适用于图片提取（见下）。

## Image Extraction

**Do not extract images by default.** Only extract when:
1. User explicitly says "extract images", "export figures", "read the images too"
2. After reading, AI detects images and asks "Export images?" → user says "yes"

Use `TemplateEngine.ExtractImages(docxPath, outputDir)` for extraction. Images exported to specified directory in original format.

## Accumulated Feature Library

参见 [formats/INDEX.md](../formats/INDEX.md) 查看所有已确认有价值的格式特征。
