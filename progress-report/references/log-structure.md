# Log Directory Structure

The standard layout that `nong progress report` reads from.

## Directory Layout

```text
log/
  plans/
    index.md          # List of all plans with date, file, summary, status
    2026-XX-XX-*.md   # Individual plan files
  changelog/
    index.md          # List of all changelogs with date, file, summary
    2026-XX-XX-*.md   # Individual changelog files
  debug/
    index.md          # List of all debug findings with date, file, summary
    2026-XX-XX-*.md   # Individual debug files
  guidance/
    index.md          # List of all guidance with date, file, summary, status
    2026-XX-XX-*.md   # Individual guidance files
  reports/
    index.html        # Auto-generated HTML report index
    *.html            # Auto-generated HTML reports
```

## Index Format

Every `index.md` should follow this pattern:
```markdown
# <category> index

> Description of the category.

## YYYY-MM-DD

- YYYY-MM-DD | file.md | One-line summary in Chinese or English | status (plan/done/reference)
```

## Plan Format

Every plan file should include:
1. Goal (what to achieve)
2. Work (step-by-step tasks)
3. Status (plan / in progress / done)
4. Verification (how to confirm it's done)

## Changelog Format

Every changelog file should include:
1. What changed
2. Why
3. Files touched
4. Tests run
5. Verification results
