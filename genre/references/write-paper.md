# Write Paper — Academic Paper Generation via Nong.Genre

Paper generation uses `PaperWriter` (from `Angri450.Nong.Genre`), NOT `DocumentWriter` (from `Angri450.Nong.Docx`).

## Quick Start

1. Ensure workspace is set up → [workspace-setup.md](workspace-setup.md)
2. Write `Program.cs` via Write tool, using the template from workspace-setup
3. `dotnet run --project <project-path>` to generate docx
4. Preview with word skill: `dotnet run --project <DocxWriter-path> -- preview output.docx`

## PaperWriter API

```csharp
var w = new PaperWriter(body, doc);

// Title block
w.Title("论文标题")              // Chinese title, 黑体 18pt centered
 .EnglishTitle("English Title")   // English title, Times New Roman 14pt
 .AbstractTitle("摘  要")        // Abstract heading
 .Abstract("摘要内容...")         // Abstract body
 .Keywords("kw1; kw2; kw3")      // Semicolon-separated keywords
 .EnglishAbstractTitle("Abstract")
 .EnglishAbstract("Abstract content...")
 .EnglishKeywords("kw1; kw2")

// Sections (auto-numbered, GB/T 7714 heading styles)
 .Heading("引言", 1)              // Level 1 → "1  引言"
 .Heading("材料与方法", 1)        // Level 1 → "2  材料与方法"
 .Heading("试验设计", 2)          // Level 2 → "2.1  试验设计"

// Body (citation [N] auto-superscript)
 .Body("正文内容[1]。")            // [1] rendered as superscript
 .Body("更多内容[2,3]。")         // [2,3] rendered as superscripts

// Variable table (experimental design)
 .VariableTable("变量操作化", tableNum, rows)

// References
 .BibHeading("参考文献")          // GB/T 7714 references heading
 .References("Author. Title[J]. Journal, Year, Vol(Issue): Pages.")
```

## GB/T 7714 Style Setup

Must be done in Program.cs before using PaperWriter:

```csharp
// Load GB/T 7714 style definitions
var sp = main.AddNewPart<StyleDefinitionsPart>();
sp.Styles = new Styles();
Gbt7714Style.BuildAll(sp.Styles);

// Load GB/T 7714 numbering definitions (for reference list)
var np = main.AddNewPart<NumberingDefinitionsPart>();
np.Numbering = new Numbering();
Gbt7714Style.BuildNumbering(np.Numbering);
```

## Key Conventions

### DO
- Use `PaperWriter` for paper generation
- Use `Gbt7714Style.BuildAll()` for GB/T 7714 styles
- Use `new PaperWriter(body, doc)` with full constructor
- Preview with dotnet run before delivery

### DON'T
- Do NOT use `DocumentWriter` for paper — it lacks paper-specific formatting
- Do NOT use `StyleBuilder.BuildAll()` — use `Gbt7714Style.BuildAll()` instead
- Do NOT reference `Angri450.Nong.Docx` paper methods — they are removed from DocumentWriter
- Do NOT write `[1]` prefix in reference text — Word auto-numbers

## Input Format Conventions

### Document Content
Accept plain text, markdown, or structured text. Work with whatever the user gives. Clarify ambiguities.

### References
Accept any reference format (GB/T 7714, APA, MLA, plain text). PaperWriter handles formatting.

### Sections vs. Paragraphs
- First-level headers are major sections (引言, 材料与方法, 结果与分析, 讨论, 结论)
- User-labeled sections: match user's exact wording
- Deduced sections: infer standard sections from content

### Images / Placeholders
If user mentions figures, insert rectangle placeholders with caption text. Map user's image files by name.

### Tables
Accept markdown tables, CSV, JSON arrays, or plain text descriptions.

## Common Pitfalls

### Heading Auto-Numbering
`PaperWriter.Heading()` auto-numbers. Pass plain title text (e.g. "引言" not "1  引言").

### Citation Format
In-body citations use `[N]` format. PaperWriter auto-superscripts. Don't manually format with `<sup>` or font size changes.

### Namespace Requirements
```csharp
using DocxCore;         // DocumentWriter (engine operations)
using Nong.Genre;       // PaperWriter, Gbt7714Style, analyzers
using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Wordprocessing;
```
