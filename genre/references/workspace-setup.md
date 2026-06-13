# Workspace Setup — GenreWriter .NET Project Scaffold

Required before first use of Paper Analysis or Write Paper. Subsequent sessions only modify `Program.cs`.

## 0. Check Existing Project

If `~/Documents/GroundPA Toolkit Workplace/genre/GenreWriter/` already exists, open `GenreWriter.csproj`:

- Search for `Angri450.Nong.Genre`
- If `<Reference Include="...">` or `<HintPath>` — local DLL reference, delete the entire `<Reference>` block, replace with:
  ```xml
  <PackageReference Include="Angri450.Nong.Docx" Version="*" />
  <PackageReference Include="Angri450.Nong.Genre" Version="*" />
  ```
- If already `<PackageReference>` — skip, run `dotnet restore`
- If project does not exist — continue to step 1

## 1. Check Dependencies

```powershell
dotnet --version
```

If .NET SDK 8.0+ not installed, tell user to install from https://dotnet.microsoft.com/download.

## 2. Verify NuGet Source

```powershell
dotnet nuget list source
```

If empty, add NuGet.org:

```powershell
dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org
```

## 3. Create Project

Ask user for working directory, suggest `~/Documents/GroundPA Toolkit Workplace/genre/GenreWriter/`. On confirmation:

```powershell
dotnet new console -n GenreWriter -o <target-dir> --force
dotnet add <target-dir> package Angri450.Nong.Docx
dotnet add <target-dir> package Angri450.Nong.Genre
```

Two dependencies. `Angri450.Nong.Genre` depends on `Angri450.Nong.Docx`, which transitively pulls `DocumentFormat.OpenXml`.

## 4. Write Program.cs Template

Use Write tool to create `<target-dir>/Program.cs`:

```csharp
using DocxCore;
using Nong.Genre;
using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Wordprocessing;
using System.Text.Json;

// === Subcommand Router ===

// analyze: full diagnosis pipeline
if (args.Length > 0 && args[0] == "analyze")
{
    if (args.Length < 2) { Console.Error.WriteLine("Usage: dotnet run -- analyze <paper.docx>"); return; }
    // Extract text via DocumentWriter preview path first
    var text = System.IO.File.ReadAllText(args[1]);
    var types = PaperTypeClassifier.Classify(text);
    Console.WriteLine($"=== Paper Type ===");
    foreach (var t in types) Console.WriteLine($"  {t.论文类型} (match: {t.当前匹配度}%)");
    var structure = PaperStructureExtractor.BuildPaperStructure(text);
    Console.WriteLine($"=== Structure ===");
    Console.WriteLine($"  Title: {structure.Title}");
    Console.WriteLine($"  Authors: {structure.Authors}");
    Console.WriteLine($"  Sections: {structure.Sections.Count}");
    var diag = PaperDiagnostics.DiagnosePaperQuality(text);
    Console.WriteLine($"=== Quality Diagnosis ===");
    Console.WriteLine($"  Evidence chain: {diag.证据链完整性}");
    Console.WriteLine($"  Data requirements: {diag.数据需求满足度}");
    Console.WriteLine($"  Gap grade: {diag.缺口等级}");
    var refs = ReferenceAnalyzer.ExtractReferences(text);
    Console.WriteLine($"=== References ({refs.Count}) ===");
    foreach (var r in refs) Console.WriteLine($"  [{r.Index}] {r.RawText}");
    return;
}

// classify: paper type classification
if (args.Length > 0 && args[0] == "classify")
{
    if (args.Length < 2) { Console.Error.WriteLine("Usage: dotnet run -- classify <text>"); return; }
    var text = System.IO.File.ReadAllText(args[1]);
    var types = PaperTypeClassifier.Classify(text);
    Console.WriteLine(JsonSerializer.Serialize(types, new JsonSerializerOptions { WriteIndented = true }));
    return;
}

// structure: extract paper structure
if (args.Length > 0 && args[0] == "structure")
{
    if (args.Length < 2) { Console.Error.WriteLine("Usage: dotnet run -- structure <text>"); return; }
    var text = System.IO.File.ReadAllText(args[1]);
    var structure = PaperStructureExtractor.BuildPaperStructure(text);
    Console.WriteLine(JsonSerializer.Serialize(structure, new JsonSerializerOptions { WriteIndented = true }));
    return;
}

// diagnose: paper quality diagnosis
if (args.Length > 0 && args[0] == "diagnose")
{
    if (args.Length < 2) { Console.Error.WriteLine("Usage: dotnet run -- diagnose <paper.docx>"); return; }
    var text = System.IO.File.ReadAllText(args[1]);
    var diag = PaperDiagnostics.DiagnosePaperQuality(text);
    Console.WriteLine(JsonSerializer.Serialize(diag, new JsonSerializerOptions { WriteIndented = true }));
    return;
}

// references: extract and check references
if (args.Length > 0 && args[0] == "references")
{
    if (args.Length < 2) { Console.Error.WriteLine("Usage: dotnet run -- references <text>"); return; }
    var text = System.IO.File.ReadAllText(args[1]);
    var refs = ReferenceAnalyzer.ExtractReferences(text);
    var risks = ReferenceAnalyzer.CheckReferenceRisks(refs);
    Console.WriteLine(JsonSerializer.Serialize(new { references = refs, risks }, new JsonSerializerOptions { WriteIndented = true }));
    return;
}

// variable-plan: generate variable plan
if (args.Length > 0 && args[0] == "variable-plan")
{
    if (args.Length < 2) { Console.Error.WriteLine("Usage: dotnet run -- variable-plan <text>"); return; }
    var text = System.IO.File.ReadAllText(args[1]);
    var plan = VariablePlanGenerator.GenerateVariablePlan(text);
    Console.WriteLine(JsonSerializer.Serialize(plan, new JsonSerializerOptions { WriteIndented = true }));
    return;
}

// === Default: Generate Paper ===

string outDir = Path.Combine(
    Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
    "GroundPA Toolkit Workplace", "output",
    $"genre-{DateTime.Now:yyyyMMdd-HHmmss}");
Directory.CreateDirectory(outDir);
string outPath = Path.Combine(outDir, "paper.docx");

using var doc = WordprocessingDocument.Create(outPath, WordprocessingDocumentType.Document);
var main = doc.AddMainDocumentPart();
main.Document = new Document(new Body());
var body = main.Document.Body!;

// Load GB/T 7714 styles
var sp = main.AddNewPart<StyleDefinitionsPart>();
sp.Styles = new Styles();
Gbt7714Style.BuildAll(sp.Styles);

var np = main.AddNewPart<NumberingDefinitionsPart>();
np.Numbering = new Numbering();
Gbt7714Style.BuildNumbering(np.Numbering);

// Write paper
var w = new PaperWriter(body, doc);
w.Title("论文标题")
 .EnglishTitle("English Title")
 .AbstractTitle("摘  要")
 .Abstract("摘要内容...")
 .Keywords("关键词1; 关键词2")
 .Heading("引言", 1)
 .Body("正文内容[1]。")
 .BibHeading("参考文献")
 .References("Author. Title[J]. Journal, Year, Vol(Issue): Pages.");

main.Document.Save();
Console.WriteLine("OK: " + Path.GetFullPath(outPath));
```

## 5. Project Structure

```
<target-dir>/
├── GenreWriter.csproj        ← References Angri450.Nong.Docx + Angri450.Nong.Genre
├── Program.cs                ← Paper analysis/writing content, overwritten each session
├── bin/Debug/                ← Build output
└── obj/Debug/                ← Intermediate files
```

## 6. Subsequent Usage

Each session:
1. Write new `Program.cs` via Write tool
2. `dotnet run --project <project-path> -- <subcommand> <args>` for analysis
3. `dotnet run --project <project-path>` (no subcommand) for paper generation
4. Output always at `~/Documents/GroundPA Toolkit Workplace/output/<timestamp>/paper.docx`
