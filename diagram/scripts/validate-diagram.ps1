#!/usr/bin/env pwsh
# validate-diagram.ps1
# Validates DiagramCore output PNG files
# Usage: .\validate-diagram.ps1 <output.png>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Path
)

$ErrorActionPreference = "Stop"

# Check file exists
if (-not (Test-Path $Path)) {
    Write-Host "FAIL: File not found: $Path" -ForegroundColor Red
    exit 1
}

# Check file size
$fileInfo = Get-Item $Path
if ($fileInfo.Length -lt 1000) {
    Write-Host "FAIL: File too small ($($fileInfo.Length) bytes)" -ForegroundColor Red
    exit 1
}

# Check PNG signature
$bytes = [System.IO.File]::ReadAllBytes($Path)
if ($bytes.Length -lt 8) {
    Write-Host "FAIL: File too short to be a valid PNG" -ForegroundColor Red
    exit 1
}

# PNG signature: 89 50 4E 47 0D 0A 1A 0A
$pngSignature = @(0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)
for ($i = 0; $i -lt 8; $i++) {
    if ($bytes[$i] -ne $pngSignature[$i]) {
        Write-Host "FAIL: Invalid PNG signature" -ForegroundColor Red
        exit 1
    }
}

# Extract dimensions from IHDR chunk
# IHDR starts at byte 8 (after signature)
# Chunk structure: Length (4 bytes) | Type (4 bytes) | Data | CRC (4 bytes)
# IHDR type: 49 48 44 52
# Width and Height are at bytes 16-19 and 20-23 (big-endian)

if ($bytes.Length -lt 24) {
    Write-Host "FAIL: File too short to contain IHDR chunk" -ForegroundColor Red
    exit 1
}

# Check if it's IHDR chunk
$ihdrType = [System.Text.Encoding]::ASCII.GetString($bytes[12..15])
if ($ihdrType -ne "IHDR") {
    Write-Host "FAIL: First chunk is not IHDR" -ForegroundColor Red
    exit 1
}

# Read width (big-endian)
$width = [System.BitConverter]::ToUInt32($bytes[19..16], 0)

# Read height (big-endian)
$height = [System.BitConverter]::ToUInt32($bytes[23..20], 0)

# Validate dimensions
if ($width -eq 0 -or $height -eq 0) {
    Write-Host "FAIL: Invalid dimensions (${width}x${height})" -ForegroundColor Red
    exit 1
}

if ($width -gt 10000 -or $height -gt 10000) {
    Write-Host "FAIL: Dimensions too large (${width}x${height})" -ForegroundColor Red
    exit 1
}

# All checks passed
$sizeKB = [math]::Round($fileInfo.Length / 1024, 2)
Write-Host "PASS: ${width}x${height} PNG, $sizeKB KB" -ForegroundColor Green
exit 0
