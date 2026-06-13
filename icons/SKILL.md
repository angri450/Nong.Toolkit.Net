---
name: icons
description: Bioicons discovery via nong. Trigger on bioicons, scientific icons, lab icons, biology icons, chemistry icons, icon list, or icon search.
---

# Icons

Use `nong icons` for implemented Bioicons discovery.

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

```powershell
nong icons list [--json]
nong icons search <query> [--json]
```

## Dispatch

1. To list available scientific icons, run `nong icons list --json`.
2. To find icons by keyword, run `nong icons search <query> --json`.
3. Do not promise icon rendering or SVG export unless the current `nong` output provides the required artifact.
