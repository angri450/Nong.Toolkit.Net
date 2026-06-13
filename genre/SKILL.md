---
name: genre
description: Template discovery via nong. Trigger on available writing templates, genre templates, format presets, template list, or showing a template.
---

# Genre

Use `nong genre` only for template discovery. Paper diagnosis and paper generation live in the `inspect` skill.

## Nong CLI Preflight

Read [../references/shared/nong-cli-preflight.md](../references/shared/nong-cli-preflight.md) before the first Nong command in a session. Confirm Nong.Cli.Net `4.1.0+` and the needed command group.
## Implemented Commands

```powershell
nong genre list [--json]
nong genre show <name> [--json]
```

## Dispatch

1. To see available templates, run `nong genre list --json`.
2. To inspect one template, run `nong genre show <name> --json`.
3. Do not claim official document writing, letter writing, or full paper writing from this skill.
4. For writing a paper from a JSON spec, use `nong inspect write-paper`.
5. For writing an official-document draft from a JSON spec, use `nong inspect write-official`.
