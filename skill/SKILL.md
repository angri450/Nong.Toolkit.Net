---
name: skill
description: Nong.Cli.Net skill lifecycle commands. Trigger on validating SKILL.md, scanning a skill/plugin for security findings, inventorying plugin skills, packaging a Claude Code plugin, checking manifests, or replacing legacy skill-manager package gates with the CLI skill lifecycle group.
---

# Skill

Use `nong skill` as the deterministic lifecycle gate for Nong.Toolkit.Net skills and plugins.

## Nong CLI Preflight

Read [../references/shared/nong-cli-preflight.md](../references/shared/nong-cli-preflight.md) before the first Nong command in a session. Confirm Nong.Cli.Net `4.0.0+` and the `skill` command group.

## Commands

```powershell
nong skill validate <skill-dir> --json
nong skill inventory <plugin-root> --json
nong skill scan <plugin-root> --json
nong skill package <plugin-root> --json
```

## Dispatch

1. Run `skill inventory` at the plugin root to verify discovered skills and manifests.
2. Run `skill validate` on each changed skill directory.
3. Run `skill scan` at the plugin root before packaging or release.
4. Run `skill package` only after validation and scan are clean.
5. Move generated `.zip` files outside the repository unless this is an explicit release artifact.

## Gates

- Validation errors block packaging.
- High or Critical scan findings block packaging.
- Medium and Low findings must be read and either fixed or documented.
- `skill package` should report `packageType: "plugin"` for Nong.Toolkit.Net and a skill count that matches `.claude-plugin/plugin.json`.

## Boundaries

Use the legacy `skill-manager` tool only for old eval/scaffold workflows that are not implemented by Nong.Cli.Net. For repository packaging, release checks, and security gates, use `nong skill ...`.
