---
name: pptx
description: PPTX inspection and creation via nong. Trigger on .pptx, PowerPoint slide text extraction, deck inspection, slide structure listing, PPTX-to-NongPandoc slice packages, or PPTX creation from JSON spec.
---

# PPTX

Use `nong` as the only Nong.Toolkit.Net entrypoint for PPTX work. Supports reading, structure inspection, slicing, and basic slide creation from JSON specs.

## Nong CLI Preflight

Read [../references/shared/nong-cli-preflight.md](../references/shared/nong-cli-preflight.md) before the first Nong command in a session. Confirm Nong.Cli.Net `4.0.0+` and the needed command group.
## Implemented Commands

Use only these PPTX commands:

```powershell
nong pptx read <deck.pptx> --json
nong pptx slides <deck.pptx> --json
nong pptx dissect <deck.pptx> -o <slice-dir> --json
nong pptx create <spec.json> -o <out.pptx> --json
```

## Dispatch

1. For plain slide text extraction, run `nong pptx read <deck.pptx> --json`.
2. For slide inventory, structure, titles, notes, or shape-level inspection, run `nong pptx slides <deck.pptx> --json`.
3. For a unified NongPandoc package, run `nong pptx dissect <deck.pptx> -o <slice-dir> --json`, then use the `slice` skill for block-level reads.
4. To create a new PPTX from a JSON spec, run `nong pptx create <spec.json> -o <out.pptx> --json`. The spec supports title slides ("kind":"title") and content slides ("kind":"content") with bullet items.
5. Treat `status: "error"` as failed and use the returned error code/message to decide whether the file path, input format, or deck content needs correction.

## Create Spec

```json
{"slides":[
  {"kind":"title","title":"Title","subtitle":"Subtitle"},
  {"kind":"content","title":"Slide 2","items":["Point 1","Point 2"]}
]}
```

## Boundaries

Nong.Toolkit.Net does not expose PPTX editing, theme design, chart embedding, animation, speaker-note authoring, or layout repair. Simple slide creation from JSON spec is supported via `pptx create`. For complex PPTX generation, expect basic title+content slides only.
