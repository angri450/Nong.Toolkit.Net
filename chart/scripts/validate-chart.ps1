# 验证图表 PNG 文件
param([string]$Path)

if (-not $Path) { Write-Output "Usage: validate-chart.ps1 <chart.png>"; exit 1 }
if (-not (Test-Path $Path)) { Write-Output "FAIL: File not found: $Path"; exit 1 }

$size = (Get-Item $Path).Length
if ($size -eq 0) { Write-Output "FAIL: File is empty: $Path"; exit 1 }

# 检查 PNG 魔数
$bytes = [System.IO.File]::ReadAllBytes($Path)
if ($bytes.Length -lt 8) { Write-Output "FAIL: File too small (< 8 bytes): $Path"; exit 1 }

$magic = [System.BitConverter]::ToString($bytes, 0, 8) -replace '-', ''
if (-not ($magic -match '^89504E470D0A1A0A')) {
    Write-Output "FAIL: Not a valid PNG (bad magic): $Path"
    exit 1
}

# 读出宽高
$w = [System.BitConverter]::ToInt32(@($bytes[19], $bytes[18], $bytes[17], $bytes[16]), 0)
$h = [System.BitConverter]::ToInt32(@($bytes[23], $bytes[22], $bytes[21], $bytes[20]), 0)

Write-Output "PASS: $Path"
Write-Output "  Size: ${size}B, Dimensions: ${w}x${h}"
