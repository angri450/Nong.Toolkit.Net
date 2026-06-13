# File & Path Handling

```powershell
# Prefer Join-Path over string concatenation
$fullPath = Join-Path $BasePath 'logs' 'app.log'

# Test for existence before operating
if (-not (Test-Path -LiteralPath $fullPath)) {
    throw "File not found: $fullPath"
}

# Get script's own directory
$ScriptDir = $PSScriptRoot   # NOT $MyInvocation.MyCommand.Path

# Resolve to absolute path
$resolved = Resolve-Path -LiteralPath $relativePath
```

## Wildcard-Safe Paths

Always use `-LiteralPath` instead of `-Path` when paths may contain `[`, `]`, `*`, `?`.

## Encoding Note

When reading or writing files that may contain Chinese or other non-ASCII content, always specify `-Encoding UTF8`. See [`file-encoding.md`](file-encoding.md) for complete guidance.

```powershell
$content = Get-Content -LiteralPath $fullPath -Encoding UTF8 -Raw
Set-Content -LiteralPath $fullPath -Value $content -Encoding UTF8
```
