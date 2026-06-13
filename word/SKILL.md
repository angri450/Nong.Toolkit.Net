---
name: word
description: >
  Read and write Word documents with full formatting intelligence. MUST use this skill
  when the user wants to read a docx (extract content + layout), analyze a template,
  create formatted academic papers, generate reports, compare document formats, learn
  formatting patterns from existing Word files, fill template placeholders, diagnose
  paper quality, classify research design, extract paper structure, or check references.
  Also trigger when the user mentions Word, docx, .docx, paper, thesis, report, format,
  template, document generation, variable operationalization, references, paper diagnosis,
  or research methods — even if they do not explicitly say "word". This skill separates
  reading (extracting format DNA), writing (generating documents from specs), and
  analyzing (paper quality diagnosis, structure extraction).
---

# DocxCore — Word Document Intelligence

Three independent capabilities, loaded on demand:

- **Read Word** → load [read-word.md](references/read-word.md)
- **Write Word** → load [write-word.md](references/write-word.md)
- **Paper Analysis** → load [paper-analysis.md](references/paper-analysis.md)

## Dependencies

- .NET SDK 11.0 (`dotnet` command available)
- NuGet package: `Angri450.Nong.Docx` (sole dependency, transitively pulls `DocumentFormat.OpenXml`)

If .NET SDK 11.0 is missing, stop immediately and tell the user to install it. Do not attempt to fix.

## Dispatch Logic

1. User mentions "analyze", "read", "extract", "template", "format", "dissect" → **load read-word.md**
2. User mentions "generate", "create", "write", "output docx", "fill template" → **load write-word.md**
3. User mentions "paper diagnosis", "paper type", "variable plan", "reference check", "evidence chain", "data requirement", "quality diagnosis" → **load paper-analysis.md**
4. Both read + write → read first, then write
5. Write + paper analysis → both loaded

## Core Operations

### Dissect (read a docx)

```powershell
.\scripts\dissect-docx.ps1 -DocxPath <input.docx> [-OutDir <output-dir>] [-ProjectPath <project-path>]
```

Outputs: `content.txt` (text preview), `images/` (extracted images), `format.json` (TemplateEngine fingerprint, requires project-path). Default output to `~/Documents/GroundPA Toolkit Workplace/word/`. Only save format fingerprints after user confirmation.

### Preview

```powershell
dotnet run --project <project-path> -- preview <input.docx>
```

Returns `PreviewResult { Text, Warnings, Errors, Info, Statistics }`. Integrates OpenXmlValidator for OOXML schema validation. Always run after generation and before delivery.

### Validate

```powershell
.\scripts\validate.ps1 <output.docx>
```

7 checks: basic structure → XML well-formedness → content stats → style references → three-line tables → font usage → content quality diagnosis (paper type classification, evidence chain, reference quality).

### Safe Write

For files with non-ASCII content, use Base64 encoding to avoid tool-layer corruption:

```powershell
.\scripts\safe-write.ps1 <target-path> <base64-content>
```

**CRITICAL: safe-write.ps1 must use the PowerShell tool, never Bash.** Prefer the Write tool for direct file writes when possible; use safe-write only when Write is unavailable.

## Workspace

First use: create the .NET project with two commands:

```powershell
dotnet new console -n DocxWriter -o <target-dir> --force
dotnet add <target-dir> package Angri450.Nong.Docx
```

Then write a `Program.cs` template. See [workspace-setup.md](references/workspace-setup.md) for the full template and details.

After setup, each session only modifies `Program.cs`. Output always goes to `~/Documents/GroundPA Toolkit Workplace/output/`.

## Format Library

See [formats/INDEX.md](formats/INDEX.md).
