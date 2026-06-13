# Workspace Setup — PptxCore .NET 工程搭建

首次使用 Write PPT 功能前必须完成。后续每次写 PPT 只修改 `Program.cs`。

## 1. 检查依赖

```powershell
dotnet --version
```

若未安装 .NET SDK,告知用户去 https://dotnet.microsoft.com/download 安装。

## 2. 创建工程

询问用户工作目录,建议 `~/Documents/GroundPA Toolkit Workplace/pptx/PptxWriter/`。用户确认后执行:

```powershell
dotnet new console -n PptxWriter -o <target-dir> --force
dotnet add <target-dir> package Angri450.Nong.Pptx
```

## 3. 写入 Program.cs 模板

用 Write 工具写入 `<target-dir>/Program.cs`,内容:

```csharp
using PptxCore;

string outDir = Path.Combine(
    Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
    "GroundPA Toolkit Workplace", "output",
    $"<timestamp>+<project>+<seq>");
Directory.CreateDirectory(outDir);
string outPath = Path.Combine(outDir, "slides.pptx");

SlideBuilder.Create()
    .Theme(ThemePreset.Academic)
    .AddTitleSlide(opt => opt.Title("演示标题").Subtitle("副标题").Author("作者"))
    .AddContentSlide(opt => opt.Title("要点").Bullets("第一点", "第二点", "第三点"))
    .Save(outPath);

// Preview (mandatory after generation)
var result = SlidePreview.Preview(outPath);
Console.WriteLine(result.Text);
if (result.Warnings.Count > 0)
{
    foreach (var w in result.Warnings) Console.Error.WriteLine($"WARN: {w}");
}

Console.WriteLine("OK: " + System.IO.Path.GetFullPath(outPath));
```

## 4. 工程结构

```
<target-dir>/
├── PptxWriter.csproj        ← 引用 Angri450.Nong.Pptx (NuGet)
├── Program.cs               ← 幻灯片内容,每次覆盖
├── bin/Debug/               ← 编译产物(正常,勿删)
└── obj/Debug/               ← 中间文件(正常,勿删)
```

## 5. 后续使用

每次生成 PPT 时:
1. 用 Write 工具写入新的 `Program.cs`
2. `dotnet run --project <project-path>` 生成 pptx
3. 输出固定到 `~/Documents/GroundPA Toolkit Workplace/output/<timestamp>+<project>+<seq>/slides.pptx`
