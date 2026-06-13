# Safe Write — BOM-less UTF-8, Base64 输入
# CRITICAL: Use PowerShell tool, never Bash
param([string]$Path, [string]$Base64)

if (-not $Path -or -not $Base64) {
    Write-Output "Usage: safe-write.ps1 <target-path> <base64-content>"
    exit 1
}

$bytes = [Convert]::FromBase64String($Base64)
$parent = Split-Path $Path -Parent
if ($parent -and -not (Test-Path $parent)) {
    New-Item -ItemType Directory -Force $parent | Out-Null
}
[System.IO.File]::WriteAllBytes($Path, $bytes)
Write-Output "OK: $Path ($($bytes.Length) bytes)"
