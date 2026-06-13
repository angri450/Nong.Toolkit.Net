# File Encoding in PowerShell

PowerShell 脚本中的非 ASCII 字符（中文、emoji 等）在编码不正确时会变成乱码。
核心原则：**所有 `.ps1` / `.psm1` / `.psd1` 文件必须保存为 UTF-8 编码。**

## 为什么中文会乱码

| 场景 | 原因 | 解决方案 |
|------|------|----------|
| Write 工具创建 `.ps1` 文件 | 文件可能以系统默认 ANSI 编码（GBK）保存 | 创建文件前先确认编码；或用 Edit 工具修改已有 UTF-8 文件 |
| PowerShell 内部写文件 (`Set-Content` / `Out-File`) | PS 5.1 默认 UTF-16LE，PS 7 默认 UTF-8 (no BOM) | 始终显式指定 `-Encoding UTF8` |
| 重定向 `>` / `>>` | 使用系统默认 ANSI 编码 | 避免重定向；用 `Out-File -Encoding UTF8` 替代 |
| 从外部读取中文文件 | 默认编码可能不匹配 | `Get-Content -Encoding UTF8` |

## 脚本文件自身的编码

**推荐做法**：
- PS 7+：UTF-8 **without BOM**（`$PSDefaultParameterValues` 默认已是 UTF-8）
- 需要兼容 PS 5.1 / Windows PowerShell：UTF-8 **with BOM**（BOM 帮助旧版 PS 识别 UTF-8）

## 文件 I/O 编码

```powershell
# 写文件 —— 永远显式指定 -Encoding
Set-Content -Path $path -Value $content -Encoding UTF8
Out-File -FilePath $path -InputObject $content -Encoding UTF8
Add-Content -Path $path -Value $line -Encoding UTF8

# 读文件
Get-Content -Path $path -Encoding UTF8

# CSV 也受编码影响
Export-Csv -Path $path -Encoding UTF8
Import-Csv -Path $path -Encoding UTF8
```

## 设置全局默认编码（PS 7+）

```powershell
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
```

> **注意**：`$PSDefaultParameterValues` 中的 `Encoding` 参数只影响 cmdlet，不影响重定向 `>` 和 `Out-File` 的默认行为（PS 5.1）。最安全的做法是每次显式指定 `-Encoding UTF8`。

## 诊断 & 转换编码

```powershell
# 检查文件实际编码（读前 3 字节看是否有 BOM）
$bytes = [System.IO.File]::ReadAllBytes($path)
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    Write-Host "UTF-8 with BOM"
} elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
    Write-Host "UTF-16 LE (Unicode)"
} else {
    Write-Host "UTF-8 without BOM or ANSI"
}

# 将已有文件转换为 UTF-8（without BOM）
$content = Get-Content -Path $path -Raw
[System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($false))

# 转换为 UTF-8 with BOM
[System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($true))
```

## 中文环境 Checklist

- [ ] `.ps1` 文件本身以 UTF-8（推荐带 BOM）保存
- [ ] 所有 `Set-Content` / `Out-File` / `Add-Content` 调用显式指定 `-Encoding UTF8`
- [ ] `Export-Csv` / `Import-Csv` 指定 `-Encoding UTF8`
- [ ] `[Console]::OutputEncoding` 在需要终端中文输出时设为 UTF-8
- [ ] 用 `Get-Content` 读外部文件时指定 `-Encoding UTF8`
- [ ] CI/CD 中确保代理的代码页设置为 UTF-8（`chcp 65001`）
