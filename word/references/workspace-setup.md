# Workspace Setup — DocxCore .NET Project Scaffold

Required before first use of Write Word. Subsequent sessions only modify `Program.cs`.

## 1. Check Dependencies

```powershell
dotnet --version
```

If .NET SDK not installed, tell user to install from https://dotnet.microsoft.com/download.

## 2. Verify NuGet Source

```powershell
dotnet nuget list source
```

If empty, add NuGet.org:

```powershell
dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org
```

## 3. Create Project

Ask user for working directory, suggest `~/Documents/GroundPA Toolkit Workplace/word/DocxWriter/`. On confirmation:

```powershell
dotnet new console -n DocxWriter -o <target-dir> --force
dotnet add <target-dir> package Angri450.Nong.Docx
```

Single dependency: `Angri450.Nong.Docx` (transitively pulls `DocumentFormat.OpenXml`). No additional packages needed.

## 4. Write Program.cs Template

Use Write tool to create `<target-dir>/Program.cs`:

```csharp
using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Wordprocessing;
using DocxCore;
using System.Text.Json;

// === Subcommand Router ===

// dissect: extract format fingerprint
if (args.Length > 0 && args[0] == "dissect")
{
    if (args.Length < 3) { Console.Error.WriteLine("Usage: dotnet run -- dissect <input.docx> <output.json>"); return; }
    var result = TemplateEngine.Analyze(args[1]);
    var json = JsonSerializer.Serialize(result, new JsonSerializerOptions { WriteIndented = true });
    File.WriteAllText(args[2], json);
    Console.WriteLine($"OK: {args[2]} ({result.Paragraphs.Count} paragraphs, {result.Issues.Count} issues)");
    return;
}

// preview: preview + diagnose
if (args.Length > 0 && args[0] == "preview")
{
    if (args.Length < 2) { Console.Error.WriteLine("Usage: dotnet run -- preview <input.docx>"); return; }
    var pr = WordPreview.Preview(args[1]);
    Console.WriteLine(pr.Text);
    if (pr.Errors.Count > 0) { Console.Error.WriteLine($"=== Errors ({pr.Errors.Count}) ==="); foreach (var e in pr.Errors) Console.Error.WriteLine($"  [ERR] {e}"); }
    if (pr.Warnings.Count > 0) { Console.Error.WriteLine($"=== Warnings ({pr.Warnings.Count}) ==="); foreach (var w in pr.Warnings) Console.Error.WriteLine($"  [WARN] {w}"); }
    if (pr.Info.Count > 0) { Console.Error.WriteLine($"=== Info ({pr.Info.Count}) ==="); foreach (var i in pr.Info) Console.Error.WriteLine($"  [INFO] {i}"); }
    Console.Error.WriteLine($"Stats: {pr.Statistics.Paragraphs}p {pr.Statistics.Tables}t {pr.Statistics.Images}i | OOXML errors={pr.Statistics.OoxmlErrors} warnings={pr.Statistics.OoxmlWarnings}");
    return;
}

// extract-images: extract embedded images
if (args.Length > 0 && args[0] == "extract-images")
{
    if (args.Length < 3) { Console.Error.WriteLine("Usage: dotnet run -- extract-images <input.docx> <output-dir>"); return; }
    var files = TemplateEngine.ExtractImages(args[1], args[2]);
    foreach (var f in files) Console.WriteLine(f);
    Console.Error.WriteLine($"OK: {files.Count} images");
    return;
}

// paper-diagnose: paper quality diagnosis
if (args.Length > 0 && args[0] == "paper-diagnose")
{
    if (args.Length < 2) { Console.Error.WriteLine("Usage: dotnet run -- paper-diagnose <paper.docx>"); return; }
    var text = File.ReadAllText(args[1]); // Simplified: use plain text. Full version should extract via TemplateEngine first.
    var types = PaperTypeClassifier.Classify(text);
    Console.WriteLine($"Top type: {types[0].论文类型} (match: {types[0].当前匹配度}%)");
    Console.WriteLine($"Recommended data: {types[0].推荐数据}");
    Console.WriteLine($"Recommended methods: {types[0].推荐方法}");
    return;
}

// === Default: Generate Document ===

string outDir = Path.Combine(
    Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
    "GroundPA Toolkit Workplace", "output",
    $"<timestamp>+<project>+<seq>");
Directory.CreateDirectory(outDir);
string outPath = Path.Combine(outDir, "paper.docx");

using var doc = WordprocessingDocument.Create(outPath, WordprocessingDocumentType.Document);
var main = doc.AddMainDocumentPart();
main.Document = new Document(new Body());
var body = main.Document.Body!;

// Load styles from format JSON
var sp = main.AddNewPart<StyleDefinitionsPart>();
sp.Styles = new Styles();
StyleBuilder.BuildFromJson(sp.Styles, "<format-json-path>");

// Numbering definitions (for reference lists)
var np = main.AddNewPart<NumberingDefinitionsPart>();
np.Numbering = new Numbering();
StyleBuilder.BuildNumbering(np.Numbering);

// Page layout from format JSON page node
var sectPr = StyleBuilder.LoadPageLayout("<format-json-path>").Build();

// Use full constructor for footnote/endnote/chart support
var w = new DocumentWriter(body, doc);

w.Title("Paper Title")
 .EnglishTitle("English Paper Title")
 .AbstractTitle("Abstract")
 .Abstract("Abstract content...")
 .Keywords("keyword1; keyword2; keyword3")
 .Heading("Introduction", 1)
 .Body("Body text[1].")
 .BibHeading("References")
 .References("Author. Title[J]. Journal, Year, Vol(Issue): Pages.");

body.Append(sectPr);
ElementOrder.RectifyTree(body);
ElementOrder.FixOrphanBorders(body);
main.Document.Save();
Console.WriteLine("OK: " + Path.GetFullPath(outPath));
```

Replace `<format-json-path>` with the absolute path to the format JSON, e.g. `<skill-root>/formats/life-sciences-contest.json`.

## 5. Project Structure

```
<target-dir>/
├── DocxWriter.csproj        ← References Angri450.Nong.Docx (single dependency)
├── Program.cs               ← Paper content, overwritten each session
├── bin/Debug/               ← Build output (normal, do not delete)
└── obj/Debug/               ← Intermediate files (normal, do not delete)
```

## 6. Subsequent Usage

Each Word generation session:
1. Write new `Program.cs` via Write tool
2. `dotnet run --project <project-path>` to generate docx
3. `dotnet run --project <project-path> -- preview output.docx` to preview and diagnose
4. `.\scripts\validate.ps1 output.docx` to validate
5. Output always at `~/Documents/GroundPA Toolkit Workplace/output/<timestamp>+<project>+<seq>/paper.docx`
