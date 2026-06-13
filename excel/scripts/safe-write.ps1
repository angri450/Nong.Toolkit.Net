# Excel 安全写入 — Base64 免疫工具层字符篡改
# 用法：.\safe-write.ps1 <target-path> <base64-content>
# Base64 是纯 ASCII，任何工具层都不会碰。解码后原样写回字节，100% 保真。

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
