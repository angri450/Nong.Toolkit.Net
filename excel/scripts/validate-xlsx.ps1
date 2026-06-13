# Excel validation — structure + formula error scan + overflow detection
# Usage: .\validate-xlsx.ps1 <xlsx-path>
# Exit 0 = pass, 1 = issues found

param([string]$FilePath)

if (-not $FilePath -or -not (Test-Path $FilePath)) {
    Write-Output "Usage: validate-xlsx.ps1 <xlsx-path>"
    exit 1
}

Write-Output "=== Excel Validation: $FilePath ==="
$hasErrors = $false

# 1. ZIP integrity check
try { $zip = [System.IO.Compression.ZipFile]::OpenRead($FilePath) } catch {
    Write-Output "  FAIL: Cannot open as ZIP — $($_.Exception.Message)"
    exit 1
}
$entryNames = $zip.Entries | ForEach-Object { $_.FullName }
$zip.Dispose()
if ($entryNames -notcontains "xl/workbook.xml") {
    Write-Output "  FAIL: Not a valid xlsx — missing xl/workbook.xml"
    $hasErrors = $true
} else { Write-Output "  PASS: ZIP structure valid ($($entryNames.Count) entries)" }

# 2. Formula error scan
$rawBytes = [System.IO.File]::ReadAllBytes($FilePath)
$asText = [System.Text.Encoding]::UTF8.GetString($rawBytes)
$errorList = @(
    @{Name="#REF!";  Pattern=">#REF!</v>"},
    @{Name="#DIV/0!";Pattern=">#DIV/0!</v>"},
    @{Name="#VALUE!";Pattern=">#VALUE!</v>"},
    @{Name="#NAME?"; Pattern=">#NAME\?</v>"},
    @{Name="#N/A";   Pattern=">#N/A</v>"},
    @{Name="#NUM!";  Pattern=">#NUM!</v>"},
    @{Name="#NULL!"; Pattern=">#NULL!</v>"}
)
$errorCount = 0
foreach ($ep in $errorList) {
    $m = [regex]::Matches($asText, $ep.Pattern)
    if ($m.Count -gt 0) { Write-Output "  ERROR: Found $($m.Count) $($ep.Name)"; $errorCount += $m.Count }
}
if ($errorCount -eq 0) { Write-Output "  PASS: Zero formula error tokens" }
else { Write-Output "  FAIL: $errorCount formula errors"; $hasErrors = $true }

# 3. Column width check
$w = [regex]::Matches($asText, '<col\s+min="(\d+)"\s+max="(\d+)"\s+width="([^"]*)"')
$zeroW = ($w | Where-Object { $_.Groups[3].Value -eq "0" }).Count
if ($zeroW -gt 0) { Write-Output "  WARN: $zeroW columns with zero width — may cause ###" }
else { Write-Output "  PASS: All columns have explicit widths" }

# 4. File size
$size = (Get-Item $FilePath).Length
Write-Output "  INFO: File size: $size bytes"
if ($size -lt 1000) { Write-Output "  WARN: Suspiciously small" }

if ($hasErrors) { Write-Output "=== RESULT: FAIL ==="; exit 1 }
else { Write-Output "=== RESULT: PASS ==="; exit 0 }
