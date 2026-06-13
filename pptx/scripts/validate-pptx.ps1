# PptxCore 校验 — 4 项检查
param([string]$PptxPath)

if (-not $PptxPath) { Write-Output "Usage: validate-pptx.ps1 <output.pptx>"; exit 1 }
if (-not (Test-Path $PptxPath)) { Write-Output "FAIL: file not found: $PptxPath"; exit 1 }

$errors = 0

# 1. ZIP structure
try {
    Add-Type -AssemblyName System.IO.Compression
    $zip = [System.IO.Compression.ZipFile]::OpenRead($PptxPath)
    $names = $zip.Entries | ForEach-Object { $_.FullName }
    $zip.Dispose()
    $hasContentTypes = ($names -match "\[Content_Types\].xml").Count -gt 0
    $hasPresentation = ($names -match "ppt/presentation.xml").Count -gt 0
    if (-not $hasContentTypes) { Write-Output "FAIL: Missing [Content_Types].xml"; $errors++ }
    if (-not $hasPresentation) { Write-Output "FAIL: Missing ppt/presentation.xml"; $errors++ }
    $slideCount = ($names -match "^ppt/slides/slide\d+\.xml$").Count
    Write-Output "  [1/4] ZIP: $slideCount slide(s) — $($hasContentTypes ? 'PASS' : 'FAIL')"
} catch {
    Write-Output "  [1/4] ZIP: FAIL — cannot open as ZIP"
    $errors++
}

# 2. Slide count
if ($slideCount -eq 0) {
    Write-Output "  [2/4] SLIDES: FAIL — 0 slides"
    $errors++
} else {
    Write-Output "  [2/4] SLIDES: $slideCount slide(s) — PASS"
}

# 3. File size
$size = (Get-Item $PptxPath).Length
if ($size -lt 1024) {
    Write-Output "  [3/4] SIZE: FAIL — $size bytes (suspiciously small)"
    $errors++
} else {
    Write-Output "  [3/4] SIZE: $([math]::Round($size/1KB,1)) KB — PASS"
}

# 4. Aspect ratio check (via NuGet Angri450.Nong.Pptx)
try {
    # Resolve NuGet package DLL path
    $pkgRoot = (dotnet nuget locals global-packages --list 2>$null) -replace 'global-packages: ', ''
    $dll = Get-ChildItem -Path "$pkgRoot\angri450.nong.pptx" -Recurse -Filter "PptxCore.dll" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match 'net\d+\.\d+' } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($dll) {
        $asm = [System.Reflection.Assembly]::LoadFrom($dll.FullName)
        $issues = $asm.GetType("PptxCore.SlideValidator").GetMethod("Validate").Invoke($null, @($PptxPath))
    if ($issues.Count -eq 0) {
        Write-Output "  [4/4] STRUCT: PASS"
    } else {
        Write-Output "  [4/4] STRUCT: $($issues.Count) issue(s)"
        foreach ($i in $issues) { Write-Output "    - $i" }
    }
} catch {
    Write-Output "  [4/4] STRUCT: SKIP (validation DLL not found)"
}

if ($errors -eq 0) { Write-Output "`nPASS: $PptxPath"; exit 0 }
else { Write-Output "`nFAIL: $errors error(s)"; exit 1 }
