---
name: progress-report
description: Generate and maintain project progress reports from structured log directories. Trigger on progress report, changelog, construction log, project log report, progress summary, or generating status reports from log/.
---

# Progress Report

Generate readable HTML status reports from structured `log/` directories via `nong progress report`.

## Nong CLI Preflight

Read [../references/shared/nong-cli-preflight.md](../references/shared/nong-cli-preflight.md) before running Nong commands. Confirm Nong.Cli.Net `4.0.0+`.

## Route Table

| User wants | Command / Reference |
|------------|---------------------|
| Generate a report | `nong progress report --project-root <dir> --json` |
| Understand log layout | [references/log-structure.md](references/log-structure.md) |
| See report output format | [references/report-templates.md](references/report-templates.md) |

Use the local CLI build when the global tool is stale:

```powershell
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe progress report --project-root . --json
```

## Boundaries

- Not a real-time task tracker. It reads `log/` directories, not live task state.
- Not a Git commit counter. The source of truth is `log/plans/`, `log/changelog/`, `log/debug/`, `log/guidance/`.
- Generated HTML reports go under `log/reports/`. Keep them CDN-free and self-contained.
- Do not store report generators as private tools. The generator lives in Nong.Cli.Net as `nong progress report`.
