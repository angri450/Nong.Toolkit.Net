---
name: pptx
description: PPTX reading via nong. Trigger on .pptx, PowerPoint slide text extraction, deck inspection, or slide structure listing.
---

# PPTX

Use `nong` as the only GroundPA entrypoint for PPTX work. This skill exposes read-only presentation inspection.

## Prerequisites

Run once before work:

```powershell
nong commands --json
```

If `nong` is missing, tell the user to install:

```powershell
dotnet tool install --global Angri450.Nong.Cli
```

## Implemented Commands

Use only these PPTX commands:

```powershell
nong pptx read <deck.pptx> --json
nong pptx slides <deck.pptx> --json
```

## Dispatch

1. For plain slide text extraction, run `nong pptx read <deck.pptx> --json`.
2. For slide inventory, structure, titles, notes, or shape-level inspection, run `nong pptx slides <deck.pptx> --json`.
3. Treat `status: "error"` as failed and use the returned error code/message to decide whether the file path, input format, or deck content needs correction.

## Boundaries

GroundPA does not expose PPTX generation, editing, theme design, chart embedding, animation, speaker-note authoring, or layout repair through this skill. Do not scaffold .NET projects or call PPTX libraries from GroundPA as a replacement for missing CLI commands.
