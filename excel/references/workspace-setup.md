# Workspace Setup — ExcelCore .NET 工程搭建

首次使用 Write Excel 功能前必须完成。后续每次写 Excel 只修改 `Program.cs`。

## 1. 检查依赖

```powershell
dotnet --version
```

若未安装 .NET SDK,告知用户去 https://dotnet.microsoft.com/download 安装。

## 2. 创建工程

询问用户工作目录,建议 `~/Documents/GroundPA Toolkit Workplace/excel/ExcelWriter/`。用户确认后执行:

```powershell
dotnet new console -n ExcelWriter -o <target-dir> --force
dotnet add <target-dir> package Angri450.Nong.Excel
```

## 3. 写入 Program.cs 模板

用 Write 工具写入 `<target-dir>/Program.cs`,内容:

```csharp
using ClosedXML.Excel;
using ExcelCore;

string outDir = Path.Combine(
    Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
    "GroundPA Toolkit Workplace", "output",
    $"<timestamp>+<project>+<seq>");
Directory.CreateDirectory(outDir);
string outPath = Path.Combine(outDir, "data.xlsx");

var wb = new XLWorkbook();
var preset = StylePresets.Mono;

ExcelBuilder.Sheet(wb, "Sheet1")
    .Headers("列1", "列2", "列3")
    .Data(new[] {
        new[] { "数据1", "数据2", "数据3" },
        new[] { "数据4", "数据5", "数据6" }
    })
    .ColumnWidths(10, 10, 10);

FormulaValidator.SaveWithEvaluation(wb, outPath);
Console.WriteLine("OK: " + System.IO.Path.GetFullPath(outPath));
```

## 4. 工程结构

```
<target-dir>/
├── ExcelWriter.csproj        ← 引用 Angri450.Nong.Excel (NuGet)
├── Program.cs                ← 表格内容,每次覆盖
├── bin/Debug/               ← 编译产物(正常,勿删)
└── obj/Debug/               ← 中间文件(正常,勿删)
```

## 5. 后续使用

每次生成 Excel 时:
1. 用 Write 工具写入新的 `Program.cs`
2. `dotnet run --project <project-path>` 生成 xlsx
3. 输出固定到 `~/Documents/GroundPA Toolkit Workplace/output/<timestamp>+<project>+<seq>/data.xlsx`
