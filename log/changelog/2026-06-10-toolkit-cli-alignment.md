# 2026-06-10 Nong.Toolkit.Net / Nong.Cli.Net alignment

## What changed

- Added shared Nong.Cli.Net 4.0.0 preflight guidance.
- Added `slice`, `skill`, `skill-manager`, and `progress-report` skills.
- Updated active docs and manifests to the Nong.Toolkit.Net name and `nong-toolkit` plugin id.
- Added thin references for PDF routing, literature providers, and inspect diagnostics.
- Structured `log/` into plans, changelog, debug, guidance, and indexes.
- Updated Word/Inspect/Genre routing for `nong word format-gongwen` and `nong inspect write-official`.
- Replaced the old "official-document CLI gap" wording with implemented command paths.

## Why

The Toolkit skill layer had drifted from the Nong.Cli.Net 4.0.0 command surface and still carried old 3.2.x preflight guidance plus retired project names.

## Files touched

- `.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
- `skills.sh.json`
- `README.md`
- `README.zh-CN.md`
- `skill.zh`
- `CLAUDE.md`
- `references/shared/nong-cli-preflight.md`
- `slice/`, `skill/`, `skill-manager/`, `progress-report/`
- `pdf/references/`, `literature/references/`, `inspect/references/`
- `word/SKILL.md`
- `word/references/api-reference.md`
- `word/references/existing-document-editing.md`
- `word/references/write-word.md`
- `inspect/SKILL.md`
- `inspect/references/paper-diagnostics.md`
- `genre/SKILL.md`
- `log/`

## Tests

- `nong skill validate .\word --json`
- `nong skill validate .\inspect --json`
- `nong skill validate .\genre --json`
- `nong skill validate .\skill --json`
- `nong skill inventory . --json`
- `nong skill scan . --json`
- `nong skill package . --json`
- Package artifact moved to `..\Nong.Toolkit_archive\package-artifacts\nong-toolkit-2026-06-10-cli-alignment.zip`.

## Remaining risks

- The global `nong` tool was repaired after this validation by installing the locally packed Nong.Cli.Net 4.0.0 tool.
- Historical logs may still mention retired names as history; active docs/manifests should stay on Nong.Toolkit.Net / Nong.Cli.Net / Nong.NanoBot.Net.
