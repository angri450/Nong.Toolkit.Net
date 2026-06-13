# Session Recording Protocol

Enabled globally via CLAUDE.md. After every session that uses skills, automatically append one JSON line per error/fix to:

`~/Documents/GroundPA Toolkit Workplace/skill-manager/session-records/YYYY-MM-DD.jsonl`

Use today's date as the filename (e.g., `2026-05-30.jsonl`). Create the directory if it doesn't exist.

## Record format

One JSON object per line, no newlines inside:

```json
{"t":"ISO8601","skill":"<name>","type":"<code>","msg":"<what>","fix":"<how>","r":true}
```

## Error types

| Code | Meaning |
|------|---------|
| `api` | Wrong API method name, parameter, or signature |
| `file` | File not found, path wrong |
| `format` | Format JSON or template mismatch |
| `font` | Font missing or glyph not available |
| `compat` | Version conflict between packages |
| `other` | Anything else |

## Rules

- Record only errors you **encountered and resolved**
- Skip dead ends (tried X, failed, gave up)
- Skip purely user errors (wrong password typed)
- Set `"r":false` only if the error remains unresolved
- Append only — never overwrite existing lines

## Example

```jsonl
{"t":"2026-05-30T14:22:00Z","skill":"chart","type":"api","msg":"DataLoader.FromXlsxMultiColumn parameter order wrong","fix":"swapped groupCol and valueCols","r":true}
{"t":"2026-05-30T14:25:00Z","skill":"word","type":"file","msg":"format JSON not found at given path","fix":"used life-sciences-contest.json instead","r":true}
{"t":"2026-05-30T14:30:00Z","skill":"pptx","type":"font","msg":"ThemePreset.Academic missing Chinese glyphs","fix":"fell back to ThemePreset.Default","r":true}
```
