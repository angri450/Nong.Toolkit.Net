# COM 自动化失败 → 回到 nong word

## 用户想要什么

修一个旧的 `.doc` 格式合同，修复格式问题。

## 出了什么问题（失败的路径）

AI 没有走 `nong word`，而是用 PowerShell COM 自动化：

```powershell
$word = New-Object -ComObject Word.Application
$doc = $word.Documents.Open("contract.doc")
# ... 9 个不同的 COM 失败 ...
```

具体失败：`Marshal.GetActiveObject` 不可用、合并单元格 HRESULT 错误、文件锁、null 引用、`ConvertToText` COM 对象污染日志、`SaveAs` 产出 `.doc` 而不是 `.docx` 等。

## 怎么改回的

```powershell
# 1. 检查 .doc 文件状态
nong word check contract.doc --json

# 2. 通过边界转换进入 .docx 管线
nong word convert contract.doc -o contract.docx --json

# 3. 现在所有 nong word 命令都能用了
nong word diagnose contract.docx --json
nong word clean-styles contract.docx -o contract.clean.docx --json
nong word format-audit contract.clean.docx --json
```

## 结果

所有修复通过 `nong word` 管线完成，0 COM 错误，产物是干净的 `.docx`。

## 关键点

- `.doc` 文件不要直接操作。先用 `word check` 判断状态，再用 `word convert` 转到 `.docx`。
- **禁止桌面 Word COM 自动化做普通 Word 操作。** COM 只在 `word convert` 内部作为边界转换手段时自动启用，不需要 AI 自己调。
- 进入 `.docx` 管线后，所有 word skill 的命令都可以正常使用。
