# DocxCore 校验 — 生成文档质量检查（含格式检查 + 内容诊断）
# 用法：.\validate.ps1 <output.docx>
# 检查 XML 结构完整性、常见合规问题，以及论文内容质量诊断。

param([string]$DocxPath)

if (-not $DocxPath) { Write-Output "Usage: validate.ps1 <output.docx>"; exit 1 }
if (-not (Test-Path $DocxPath)) { Write-Output "ERROR: file not found: $DocxPath"; exit 1 }

Write-Output "=== DocxCore Validate: $DocxPath ==="

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($DocxPath)
$entries = $zip.Entries | ForEach-Object { $_.FullName }
$issues = @()
$warnings = @()
$info = @()
$contentIssues = @()
$contentWarnings = @()
$contentInfo = @()

# 1. 基础结构检查
Write-Output "[1/7] basic structure"

$required = @("[Content_Types].xml", "word/document.xml", "word/_rels/document.xml.rels")
foreach ($r in $required) {
    if ($r -notin $entries) { $issues += "MISSING: $r" }
}

if (($entries | Where-Object { $_ -match "word/styles\.xml" }).Count -eq 0)  { $warnings += "no styles.xml — using defaults" }
if (($entries | Where-Object { $_ -match "word/numbering" }).Count -eq 0)   { $info += "no numbering.xml — no lists defined" }
if (($entries | Where-Object { $_ -match "word/header" }).Count -eq 0)      { $info += "no headers" }
if (($entries | Where-Object { $_ -match "word/footer" }).Count -eq 0)      { $info += "no footers" }

# 2. XML 格式检查
Write-Output "[2/7] xml well-formedness"

$xmlFiles = $entries | Where-Object { $_ -match '\.xml$' }
foreach ($xf in $xmlFiles) {
    try {
        $stream = $zip.GetEntry($xf).Open()
        $reader = [System.Xml.XmlReader]::Create($stream)
        while ($reader.Read()) { }
        $reader.Close(); $stream.Close()
    } catch {
        $issues += "XML parse error in $xf`: $_"
    }
}
if ($issues -notmatch "XML parse") { Write-Output "       all XML well-formed" }

# 3. 内容统计
Write-Output "[3/7] content stats"

$docXml = $zip.GetEntry("word/document.xml").Open()
$docText = (New-Object System.IO.StreamReader($docXml)).ReadToEnd(); $docXml.Close()

$pCount = ([regex]::Matches($docText, '<w:p[ >]')).Count
$tblCount = ([regex]::Matches($docText, '<w:tbl[ >]')).Count
$imgCount = ([regex]::Matches($docText, '<w:drawing')).Count
Write-Output "       paragraphs: $pCount  tables: $tblCount  images: $imgCount"

# 4. 样式引用检查
Write-Output "[4/7] style references"

if ($docText -match 'word/styles.xml') {
    $styleXml = $zip.GetEntry("word/styles.xml").Open()
    $styleText = (New-Object System.IO.StreamReader($styleXml)).ReadToEnd(); $styleXml.Close()
    $defined = [regex]::Matches($styleText, 'w:styleId="([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
    $used = [regex]::Matches($docText, 'w:pStyle w:val="([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
    $undefined = $used | Where-Object { $_ -notin $defined } | Select-Object -Unique
    foreach ($u in $undefined) { $issues += "style referenced but not defined: $u" }
    if (-not $undefined) { Write-Output "       all referenced styles are defined" }
}

# 5. 三线表检查
Write-Output "[5/7] three-line tables"

if ($docText -match '<w:tbl[ >]') {
    $borders = [regex]::Matches($docText, '<w:tblBorders>(.+?)</w:tblBorders>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    foreach ($b in $borders) {
        $inner = $b.Groups[1].Value
        if ($inner -match '<w:insideH[^/]*w:val="[^n]') { $warnings += "table has inside horizontal borders — should be none for three-line style" }
        if ($inner -match '<w:insideV[^/]*w:val="[^n]') { $warnings += "table has inside vertical borders — should be none for three-line style" }
    }
    if ($borders.Count -gt 0) { Write-Output "       $($borders.Count) table(s) checked" }
}

# 6. 字体检查
Write-Output "[6/7] font usage"

if ($docText -match '<w:rFonts[^/]*w:eastAsia="([^"]+)"') {
    $font = $Matches[1]
    Write-Output "       CJK font: $font"
}
if ($docText -match '<w:sz w:val="([^"]+)"') {
    $sizes = [regex]::Matches($docText, 'w:sz w:val="([^"]+)"') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
    Write-Output "       font sizes (half-pt): $($sizes -join ', ')"
}

# 7. 论文内容质量诊断
Write-Output "[7/7] content quality diagnosis"

# 提取纯文本
$plainText = [regex]::Replace($docText, '<[^>]+>', ' ')
$plainText = [regex]::Replace($plainText, '\s+', ' ').Trim()

# 7a. 论文类型分类
Write-Output "       paper type classification"

$paperTypes = @{
    "问卷调查型论文" = @("问卷","量表","Likert","信度","效度","调查")
    "实验研究型论文" = @("实验","实验组","控制组","随机","前测","后测")
    "准实验/政策评估型(DID)" = @("DID","双重差分","政策冲击","处理组","对照组","平行趋势","事件研究")
    "访谈研究型论文" = @("访谈","半结构","受访者","扎根理论")
    "田野调查型论文" = @("田野","参与观察","观察记录","田野日志")
    "内容分析型论文" = @("内容分析","编码表","编码员","一致性","语料")
    "案例研究型论文" = @("案例","个案","过程追踪")
    "混合方法研究" = @("混合方法")
    "二手数据库实证研究" = @("数据库","面板数据","年鉴","公开数据","二手数据")
    "文献综述型论文" = @("文献综述","研究进展","系统综述","综述")
    "理论阐释型论文" = @("理论阐释","理论建构","概念框架","理论模型")
}

$topType = ""
$topScore = 0
foreach ($pt in $paperTypes.GetEnumerator()) {
    $hits = ($pt.Value | Where-Object { $plainText.Contains($_) }).Count
    $score = [math]::Min(100, [math]::Round($hits / [math]::Max($pt.Value.Count, 1) * 100))
    if ($score -gt $topScore) { $topScore = $score; $topType = $pt.Key }
}
if ($topScore -eq 0) {
    $contentWarnings += "paper type: unable to classify — no keywords matched. Top guess: 问卷调查型论文 (default)"
} else {
    $contentInfo += "paper type: $topType (match: $topScore%)"
}

# 7b. 证据链检查
if (-not ($plainText -match '(研究问题|研究目的|本文旨在|探讨|检验)')) {
    $contentWarnings += "research question: not clearly stated in text"
}
if (-not ($plainText -match '(研究对象|样本|受访者|案例|企业|学生)')) {
    $contentWarnings += "research subject: not clearly identified"
}
if (-not ($plainText -match '(数据来源|样本|受访者|问卷|数据库|访谈|观察|编码)')) {
    $contentWarnings += "data source: no data source described"
}
if ($plainText -match '(填补空白|重大理论价值|首次提出|创新性提出)') {
    $contentWarnings += "overclaiming: inflated contribution language detected — replace with specific mechanism/evidence claims"
}
if ($plainText -match '(导致|决定|显著促进|抑制了|因果)') {
    if ($plainText -notmatch '(随机实验|实验组|DID|双重差分|PSM|工具变量|断点回归|固定效应)') {
        $contentIssues += "causal language without causal design: found strong causal claims but no experimental/quasi-experimental design indicators"
    }
}
if ($plainText -match '机制' -and $plainText -notmatch '(中介|访谈|过程追踪|田野|机制检验)') {
    $contentWarnings += "mechanism claims without mechanism evidence: claims about mechanisms but no mediation model, interviews, or process tracing"
}

# 7c. 参考文献质量
$refCount = ([regex]::Matches($plainText, '\[\d+(?:[,-]\d+)*\]')).Count
$hasRefHeading = $plainText -match '(参考文献|参考资料|引用文献)'
if ($refCount -eq 0) {
    $contentWarnings += "references: no inline citations [N] found in text"
}
if (-not $hasRefHeading) {
    $contentWarnings += "references: no reference list heading found"
}
if ($refCount -gt 0 -and $hasRefHeading) {
    $contentInfo += "references: $refCount inline citation(s) found, reference list present"
}

# 7d. 数据与方法匹配
if ($plainText -match '(变量|测量|指标|题项)') {
    $contentInfo += "variables: variable/measurement terms found — consider adding a variable operationalization table"
} else {
    $contentWarnings += "variables: no variable or measurement terms detected — methods section may be incomplete"
}
if ($plainText -match '(回归|Logistic|t检验|ANOVA|中介|调节|DID|PSM|固定效应)') {
    $contentInfo += "methods: statistical method terms found"
} else {
    $contentInfo += "methods: no statistical method keywords detected (may be qualitative or methods not yet written)"
}

# 7e. 图表覆盖
if ($tblCount -eq 0 -and $plainText.Length -gt 500) {
    $contentWarnings += "tables: no tables found — consider adding at minimum a variable table and a descriptive statistics table"
}
if ($imgCount -eq 0 -and $plainText.Length -gt 500) {
    $contentInfo += "images: no embedded images found"
}

$zip.Dispose()

# 报告
Write-Output ""
$errCount = $issues.Count + $contentIssues.Count
$warnCount = $warnings.Count + $contentWarnings.Count
$infoCount = $info.Count + $contentInfo.Count

if ($issues.Count -gt 0) {
    Write-Output "=== FORMAT ISSUES ($($issues.Count)) ==="
    $issues | ForEach-Object { Write-Output "  [FAIL] $_" }
}
if ($contentIssues.Count -gt 0) {
    Write-Output "=== CONTENT ISSUES ($($contentIssues.Count)) ==="
    $contentIssues | ForEach-Object { Write-Output "  [FAIL] $_" }
}
if ($warnings.Count -gt 0) {
    Write-Output "=== FORMAT WARNINGS ($($warnings.Count)) ==="
    $warnings | ForEach-Object { Write-Output "  [WARN] $_" }
}
if ($contentWarnings.Count -gt 0) {
    Write-Output "=== CONTENT WARNINGS ($($contentWarnings.Count)) ==="
    $contentWarnings | ForEach-Object { Write-Output "  [WARN] $_" }
}
if ($infoCount -gt 0) {
    Write-Output "=== INFO ($infoCount) ==="
    $info | ForEach-Object { Write-Output "  [INFO] $_" }
    $contentInfo | ForEach-Object { Write-Output "  [INFO] $_" }
}

Write-Output ""
if ($errCount -eq 0 -and $warnCount -eq 0) {
    Write-Output "=== PASS — all format and content checks passed ==="
} elseif ($errCount -eq 0) {
    Write-Output "=== PASS with $warnCount warning(s) ==="
} else {
    Write-Output "=== FAIL — $errCount issue(s) found ==="
}
