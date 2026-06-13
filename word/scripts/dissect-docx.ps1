# DocxCore 手术刀 — 一键解剖 Word 文档（纯 .NET，零外部依赖）
# 输出：content.txt（文本预览）+ images/（图片）+ format.json（排版特征）
# 用法：.\dissect-docx.ps1 -DocxPath <input.docx> [-OutDir <output-dir>] -ProjectPath <project-path>
#
# 依赖：Angri450.Nong.Docx，不需要 pandoc

param([string]$DocxPath, [string]$OutDir, [string]$ProjectPath)

# 强制 UTF-8 编码，避免中文乱码
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$OutputEncoding = [Text.Encoding]::UTF8

if (-not $DocxPath) { Write-Output "Usage: dissect-docx.ps1 -DocxPath <input.docx> [-OutDir <output-dir>] -ProjectPath <project-path>"; exit 1 }
if (-not (Test-Path $DocxPath)) { Write-Output "ERROR: file not found: $DocxPath"; exit 1 }
if (-not $ProjectPath -or -not (Test-Path $ProjectPath)) {
    Write-Output "ERROR: ProjectPath is required and must exist. Pass the DocxWriter project directory."
    exit 1
}

# 0. 检测 Program.cs 是否包含 subcommand 路由
$programCs = Join-Path $ProjectPath "Program.cs"
if (-not (Test-Path $programCs)) {
    Write-Output "ERROR: Program.cs not found at $programCs"
    exit 1
}
$programContent = Get-Content $programCs -Raw
$hasSubcommandRoute = ($programContent -match 'args\[0\]' -or
                       $programContent -match 'preview' -or
                       $programContent -match 'dissect')
if (-not $hasSubcommandRoute) {
    Write-Output "ERROR: Program.cs 不包含 subcommand 路由（未检测到 args[0] / preview / dissect 分支）。"
    Write-Output "请使用 workspace-setup.md 的模板 Program.cs 重新生成后再执行 dissect。"
    exit 1
}

$docxName = [System.IO.Path]::GetFileNameWithoutExtension($DocxPath)
if (-not $OutDir) {
    $docsRoot = Join-Path $env:USERPROFILE "Documents\Nong Toolkit Workspace\word"
    New-Item -ItemType Directory -Force $docsRoot | Out-Null
    $OutDir = Join-Path $docsRoot $docxName
}
New-Item -ItemType Directory -Force $OutDir | Out-Null

Write-Output "=== DocxCore dissect: $docxName ==="

# 1. 文本预览（纯 .NET：WordPreview.Preview）
Write-Output "[1/3] text -> content.txt"
$txtPath = Join-Path $OutDir "content.txt"
try {
    $previewOutput = dotnet run --project $ProjectPath -- preview "$DocxPath" 2>&1
    # stdout = 文本内容，stderr = warnings + "OK"
    $previewOutput | Set-Content $txtPath -Encoding UTF8
    $txtSize = (Get-Item $txtPath).Length / 1KB
    Write-Output "       content.txt ($([math]::Round($txtSize,1)) KB)"
} catch {
    Write-Output "       WARNING: preview failed, creating empty content.txt"
    "" | Set-Content $txtPath
}

# 2. 图片提取（纯 .NET：TemplateEngine.ExtractImages）
Write-Output "[2/3] images -> images/"
$imgDir = Join-Path $OutDir "images"
try {
    $imgOutput = dotnet run --project $ProjectPath -- extract-images "$DocxPath" "$imgDir" 2>&1
    Write-Output $imgOutput
} catch {
    Write-Output "       WARNING: image extraction failed"
}
$imgCount = (Get-ChildItem $imgDir -File -ErrorAction SilentlyContinue).Count
Write-Output "       $imgCount image(s)"

# 3. 格式模板（纯 .NET：TemplateEngine.Analyze）
Write-Output "[3/3] format -> format.json"
$fmtJson = Join-Path $OutDir "format.json"
try {
    dotnet run --project $ProjectPath -- dissect "$DocxPath" "$fmtJson" 2>&1 | Out-Null
} catch {
    Write-Output "       WARNING: format analysis failed"
}
if (Test-Path $fmtJson) { Write-Output "       format.json" }
else { Write-Output "       SKIP: format.json not generated" }

Write-Output ""
Write-Output "=== Done: $OutDir ==="
Get-ChildItem $OutDir | ForEach-Object { "  {0}" -f $_.Name }
