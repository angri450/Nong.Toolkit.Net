# PptxCore 免疫写入 — Base64 通道
# 用途：绕过工具层字符转义导致的文件损坏
param([string]$TargetPath, [string]$Base64Content)

if (-not $TargetPath -or -not $Base64Content) {
    Write-Output "Usage: safe-write.ps1 <target-path> <base64-content>"
    exit 1
}

$parent = Split-Path $TargetPath -Parent
if ($parent -and -not (Test-Path $parent)) {
    New-Item -ItemType Directory -Force $parent | Out-Null
}

try {
    $bytes = [Convert]::FromBase64String($Base64Content)
    [System.IO.File]::WriteAllBytes($TargetPath, $bytes)
    Write-Output "OK: $TargetPath ($($bytes.Length) bytes)"
} catch {
    Write-Output "ERROR: $_"
    exit 1
}
