# 审查通过：Nong 3.2.4 skill 配套同步

## 范围

本次审查覆盖 GroundPA Toolkit 中与 Nong 3.2.4、PDF 本地切片、纯 .NET PP-OCRv5 runtime 部署相关的 active skill、README、插件 manifest、marketplace manifest 和开发说明。

## 修复内容

1. 将 active Nong-facing skills 的运行时前置条件从 `Nong 3.2.3+` 同步为 `Nong 3.2.4+`。
2. 补齐 `pdf` skill 对 Nong 3.2.4 PDF 命令面的说明：`pdf check`、`pdf dissect`、`pdf render`、`pdf images`。
3. 明确 PDF 主产物是 `content.nongmark`，`preview/content.md` 只是有损预览。
4. 明确本地 OCR 只做单图文字识别，不承诺扫描 PDF 的版面、表格、Word 格式或跨页重建。
5. 明确 `Angri450.Nong.OcrRuntime.*` 包版本跟随 CLI 版本；NuGet 新发版后国内镜像可能短暂滞后。
6. 将 GroundPA Toolkit 插件版本从 `2.2.0` 更新到 `2.2.1`，并同步 marketplace 展示文案。
7. 在 README / README.zh-CN / DEVELOP 中补齐 `pdf` skill 入口和常用命令。

## 审查结论

未发现仍需修复的 HIGH 或 MEDIUM 问题。

## 验证

使用 Angri450.Nong 仓库中的 Nong 3.2.4 release DLL 验证，因为本机全局 `nong` 当时仍为 3.2.3。

```powershell
dotnet <Angri450.Nong-repo>\Cli\bin\Release\net8.0\nong.dll --version
dotnet <Angri450.Nong-repo>\Cli\bin\Release\net8.0\nong.dll commands --json
dotnet <Angri450.Nong-repo>\Cli\bin\Release\net8.0\nong.dll skill validate .\pdf --json
dotnet <Angri450.Nong-repo>\Cli\bin\Release\net8.0\nong.dll skill validate .\multimodal --json
dotnet <Angri450.Nong-repo>\Cli\bin\Release\net8.0\nong.dll skill scan . --json
claude plugin validate .
```

结果：

1. Nong 3.2.4 返回 `77 commands available`，包含 4 个 PDF 命令。
2. `pdf` skill validate：0 error / 0 warning。
3. `multimodal` skill validate：0 error / 0 warning。
4. 21 个 skill 逐个 validate 全部通过。
5. `nong skill scan .`：0 findings / 0 High+。
6. `claude plugin validate .`：Validation passed。
