---
name: pptx
description: >
  Read and write PowerPoint presentations (.pptx) with full formatting intelligence.
  MUST use this skill when the user wants to create presentations, slide decks, reports,
  or pitch decks; read, parse, or extract data from .pptx files; edit or update slides;
  work with charts, tables, or templates in PowerPoint. Trigger when the user mentions
  PowerPoint, PPT, pptx, slides, presentation, slide deck, 演示文稿, 幻灯片, 汇报,
  or 课件 — even if they do not explicitly say "pptx". Do NOT trigger when the primary
  deliverable is a Word document, Excel spreadsheet, or HTML page.
---

# PptxCore — PPT Document Intelligence

Two independent capabilities, loaded on demand:

- **Read PPT** → load [read-pptx.md](references/read-pptx.md)
- **Write PPT** → load [write-pptx.md](references/write-pptx.md)

## Dependencies

- .NET SDK (`dotnet --version` must work)

If missing, stop immediately and tell the user to install. Do not attempt to fix.

## Dispatch Logic

1. User mentions "analyze", "read", "extract", "content", "structure" → **load read-pptx.md**
2. User mentions "generate", "create", "write", "build", "presentation", "slides" → **load write-pptx.md**
3. User mentions "edit", "modify", "update", "fix", "change", "repair" → **load read-pptx.md first (shape-map), then edit**
4. L2 (SlideBuilder) can't express the change → fall back to **Raw XML (L3)**

## Core Operations

### Preview

Always run a text preview after generating pptx — this is the AI's "eyes":

```csharp
var result = SlidePreview.Preview(path);
Console.WriteLine(result.Text);
```

Outputs per-slide shapes, text, fonts, positions, tables, chart types. Warnings must be fixed, never ignored.

### Validate

```powershell
.\scripts\validate-pptx.ps1 <output.pptx>
```

4 checks: ZIP structure → slide count → aspect ratio → file size. Only deliver after PASS.

### Shape Map (inspect before editing)

For editing existing files, always get a shape map first — this is how the AI knows what to target:

```csharp
var map = SlidePreview.ShapeMap(pres);   // or SlidePreview.ShapeMap(path)
Console.WriteLine(map.Json);
// Returns per-slide JSON: slide index, shape names, types, placeholder types, text preview, position
```

This avoids guessing shape names or reading raw XML. See [read-pptx.md](references/read-pptx.md) for details.

### Raw XML (L3 fallback)

When SlideBuilder cannot express what you need, use the raw OOXML path. **Only use this as a last resort — prefer SlideBuilder first.**

```csharp
using PptxCore;

var accessor = new RawAccessor("file.pptx");
// Read any part as raw XML string
string xml = accessor.GetPart("/ppt/slides/slide1.xml");
// Modify a part and save
accessor.SetPart("/ppt/slides/slide1.xml", modifiedXml);
accessor.SaveAs("output.pptx");
```

Common fallback scenarios: removing printerSettings for Keynote compatibility, fixing broken relationships, deleting unused layouts.

### Safe Write

For files with non-ASCII content, use Base64 encoding to avoid tool-layer corruption:

```powershell
.\scripts\safe-write.ps1 <target-path> <base64-content>
```

**CRITICAL: safe-write.ps1 must use the PowerShell tool, never Bash.** Prefer the Write tool for direct file writes when possible; use safe-write only when Write is unavailable.

## Workspace

First use: create the .NET project with two commands:

```powershell
dotnet new console -n PptxWriter -o <target-dir> --force
dotnet add <target-dir> package Angri450.Nong.Pptx
```

Then write a `Program.cs` template. See [workspace-setup.md](references/workspace-setup.md) for the full template and details.

After setup, each session only modifies `Program.cs`. Output always goes to `~/Documents/GroundPA Toolkit Workplace/output/`.

## Design Rules (Avoid — read before generating)

These are the most common AI-slide mistakes. **Violating any of these produces sloppy decks.**

1. **NEVER use accent lines under titles** — this is the visual fingerprint of AI-generated slides. Use whitespace or background contrast instead.
2. **Every slide needs a visual element** — image, chart, icon, or shape. Text-only slides are forgettable.
3. **Don't repeat the same layout** — vary between columns, cards, callouts, and grids across slides.
4. **Don't center body text** — left-align paragraphs and lists; center only titles and hero text.
5. **Don't default to blue** — pick colors that reflect the specific topic. Match the palette to the content.
6. **Don't mix spacing randomly** — choose one gap (0.3" or 0.5") and use it consistently.
7. **Don't create text-only slides** — add at least one image, chart, or decorative shape per slide.
8. **One idea per slide** — if a slide has two unrelated points, split it.
9. **Data slides are not paragraphs** — use tables, charts, or large stat callouts instead of prose.
10. **Check contrast** — light text on light backgrounds and dark text on dark backgrounds are both unreadable.
11. **Titles ≥ 28pt, body ≥ 14pt** — smaller than this and it won't be readable on a projector.
12. **Image max 60% of slide height** — full-slide images leave no room for text.

## Format Library

See [formats/INDEX.md](formats/INDEX.md). 10 color themes: Professional / Academic / Modern / Minimal / Warm / Cool / Midnight Executive / Coral Energy / Teal Trust / Cherry Bold.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| **1.0.4** | 2026-05-30 | Theme NOW WORKS: colors+fonts applied to all shapes, table header auto-style (dark fill+white bold), true bullet formatting (para.Bullet with char), alternating row backgrounds (Light2), AddSlide clears placeholders, preview shows hex colors+CJK fonts, SlideHelper uses theme body/heavy styles, ThemePreset.ApplyToMasterSlide injects theme into slide master |
| 1.0.3 | 2026-05-30 | Placeholder fix: SetPlaceholder writes directly into existing placeholder shapes instead of creating new TextBox overlays. HideUnusedPlaceholders clears unused placeholder text. No more "Click to edit Master title style". |
| 1.0.2 | 2026-05-29 | ShapeMap (structured JSON shape inventory), RawAccessor (L3 OOXML ZIP read/write), 4 new JSON themes (Coral/Midnight/Teal/Cherry), 12 Avoid rules, Density Limits. NuGet package: 10 slide layouts, fluent chain API. |
| 1.0.1 | 2026-05-28 | Initial release. ShapeCrawler wrapper with 6 built-in themes. Fluent SlideBuilder API. |
