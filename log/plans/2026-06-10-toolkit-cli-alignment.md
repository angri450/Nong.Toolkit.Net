# 2026-06-10 Toolkit / CLI alignment plan

## Goal

Align Nong.Toolkit.Net with Nong.Cli.Net 4.0.0 and remove the old GroundPA active surface.

## Work

1. Replace duplicated skill preflight blocks with `references/shared/nong-cli-preflight.md`.
2. Add repository guidance in `CLAUDE.md`.
3. Structure `log/` into `plans`, `changelog`, `debug`, and `guidance` with indexes.
4. Add missing skills for `slice`, `skill`, `skill-manager`, and `progress-report`.
5. Add thin references for PDF, literature, and inspect.
6. Update manifests, README files, and active skill language to Nong.Toolkit.Net / Nong.Cli.Net / Nong.NanoBot.Net naming.
7. Update Nong.Cli.Net skill packaging so plugin-level shared resources are included.
8. Validate with the local Nong.Cli.Net 4.0.0 executable because the global `nong` tool is stale.
9. Sync official-document/gongwen routing after Nong.Cli.Net exposes `word format-gongwen` and `inspect write-official`.

## Risks

- `nong skill package` must include plugin-level `references/`; otherwise shared preflight links work locally but disappear from packages.
- Historical logs may still mention the old name as history. Active docs and manifests must not.

## Status

Done.

## Verification

- `nong skill validate .\word --json`
- `nong skill validate .\inspect --json`
- `nong skill validate .\genre --json`
- `nong skill validate .\skill --json`
- `nong skill inventory . --json`
- `nong skill scan . --json`
- `nong skill package . --json`
- Confirmed generated package zip includes `references/shared/nong-cli-preflight.md`.
