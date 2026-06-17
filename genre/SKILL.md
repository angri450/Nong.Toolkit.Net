---
name: genre
description: Template discovery via nong. Trigger on available writing templates, genre templates, format presets, template list, or showing a template.
---

# Genre

Use `nong genre` only for template discovery. Paper diagnosis and paper generation live in the `inspect` skill.

## Nong CLI Preflight

Read [../../.claude/references/nong-cli-preflight.md](../../.claude/references/nong-cli-preflight.md) before the first Nong CLI command in a session. Confirm the `nong` CLI is installed and the needed command group.
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
