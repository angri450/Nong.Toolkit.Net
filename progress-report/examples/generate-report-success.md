# Generate a Progress Report

## What the user wants

Generate an HTML progress report from the project's `log/` directory.

## What was done

```powershell
# From the repo root
nong progress report --project-root . --json
```

Output:
```json
{
  "status": "ok",
  "command": "progress report",
  "summary": "Generated report from 7 plans, 61 changelogs, 4 debugs, 28 guidances",
  "artifacts": {
    "index": "log/reports/index.html",
    "pages": [
      "log/reports/pages/plans-summary.html",
      "log/reports/pages/changelog-summary.html"
    ]
  },
  "meta": { "durationMs": 234, "version": "4.0.0" }
}
```

The `log/reports/index.html` is now a self-contained, CDN-free HTML page listing all log entries with links to sub-pages.

## Result

- `log/reports/index.html` created
- `log/reports/pages/` directory populated with sub-reports
- All pages are Chinese-first, no external dependencies

## Key takeaways

- Run from the repo root so `--project-root .` resolves correctly.
- The report reads from `index.md` files only. If an index is missing, that category is skipped.
- If the global `nong` is stale, use the local build at `..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe`.
- Generated HTML goes under `log/reports/`. Don't edit it manually — regenerate instead.
