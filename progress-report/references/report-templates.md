# Report Output Format

What `nong progress report --project-root . --json` produces.

## JSON Output

```json
{
  "status": "ok",
  "command": "progress report",
  "summary": "Generated report from N plans, M changelogs, ...",
  "data": {
    "plans": { "total": <N>, "done": <N>, "plan": <N> },
    "changelogs": { "total": <N> },
    "debugs": { "total": <N> },
    "guidances": { "total": <N> }
  },
  "artifacts": {
    "index": "log/reports/index.html",
    "pages": ["log/reports/pages/<file>.html", "..."]
  },
  "meta": {
    "durationMs": <N>,
    "version": "4.0.0"
  }
}
```

## HTML Output

The generator produces:
- `log/reports/index.html` — a self-contained HTML index page linking all sub-reports
- `log/reports/pages/*.html` — individual report pages for plans, changelogs, and summaries

All HTML is:
- Self-contained (no external CSS, JS, or CDN)
- Chinese-first (Chinese labels and content, English filenames preserved)
- Dark/light theme compatible
- Mobile-responsive

## Usage

```powershell
# Generate from the repo root
nong progress report --project-root . --json

# Generate using a local CLI build
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe progress report --project-root . --json
```

## What Gets Included

The generator reads:
- `log/plans/index.md` → plan summaries
- `log/changelog/index.md` → changelog summaries
- `log/debug/index.md` → debug finding summaries
- `log/guidance/index.md` → guidance summaries

It does NOT read individual plan/changelog/debug/guidance `.md` files. Only index summaries are included in the report. If an index is missing, that category is skipped.
