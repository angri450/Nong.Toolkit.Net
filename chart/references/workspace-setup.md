# Workspace Setup — ChartCore .NET 工程搭建

首次使用 Chart 功能前必须完成。后续每次只需要修改 `Program.cs`。

## 1. 检查依赖

```powershell
dotnet --version
```

若未安装 .NET SDK 11.0，告知用户去 https://dotnet.microsoft.com/en-us/download/dotnet/11.0 安装。

## 2. 确认 NuGet 源

```powershell
dotnet nuget list source
```

若列表为空，添加 NuGet.org:

```powershell
dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org
```

## 3. 创建工程

询问用户工作目录，建议 `~/Documents/GroundPA Toolkit Workplace/chart/ChartWriter/`。用户确认后执行:

```powershell
dotnet new console -n ChartWriter -o <target-dir> --force
dotnet add <target-dir> package Angri450.Nong.Chart
```

## 4. 写入 Program.cs 模板

用 Write 工具写入 `<target-dir>/Program.cs`，内容:

```csharp
using ChartCore;
using System.Text.Json;

// === ChartCore Workspace ===
// 用法:
//   dotnet run                         生成图表（默认模式）
//   dotnet run -- analyze <data.json>  ANOVA + Duncan 分析

string outDir = Path.Combine(
    Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
    "GroundPA Toolkit Workplace", "output",
    $"<timestamp>+<project>+<seq>");
Directory.CreateDirectory(outDir);

if (args.Length > 0 && args[0] == "analyze")
{
    if (args.Length < 2) { Console.Error.WriteLine("Usage: dotnet run -- analyze <data.json>"); Environment.Exit(1); }
    var groups = DataLoader.FromJson(args[1]);
    var result = StatsEngine.FullAnalysis(groups);
    result.Print();
    return;
}

if (args.Length > 0 && args[0] == "combine")
{
    if (args.Length < 4) { Console.Error.WriteLine("Usage: dotnet run -- combine <fig1.png> <fig2.png> <fig3.png> <out.png>"); Environment.Exit(1); }
    var paths = args[1..^1];
    var labels = Enumerable.Range(0, paths.Length).Select(i => ((char)('A' + i)).ToString()).ToArray();
    ChartCombine.MergeHorizontal(paths, labels, args[^1]);
    Console.WriteLine("OK: " + Path.GetFullPath(args[^1]));
    return;
}

// === 默认模式：生成图表 ===
// 写法 1: 从 JSON 读数据
var dataFile = "data.json";
if (!File.Exists(dataFile))
{
    Console.Error.WriteLine($"Data file not found: {dataFile}");
    Console.Error.WriteLine("Place a JSON file at: {0}", Path.GetFullPath(dataFile));
    Environment.Exit(1);
}

var data = DataLoader.FromJson(dataFile);

// 写法 2: 从 xlsx 读数据（取消注释使用）
// var data = DataLoader.FromXlsxMultiColumn("data.xlsx", "Sheet1",
//     groupCol: 1, valueCols: new[] { 2, 3, 4 });

// ANOVA + Duncan 分析
var analysis = StatsEngine.FullAnalysis(data);
analysis.Print();

// 生成带显著性标注的柱形图
var sigLabels = analysis.Duncan.Groups.ToDictionary(g => g.Label, g => g.Significance);
ChartBuilder.BarChartWithSignificance(
    data, sigLabels,
    "图表标题",
    "Y 轴标签",
    Path.Combine(outDir, "chart.png"),
    width: 800, height: 600);

Console.WriteLine("OK: " + Path.GetFullPath(Path.Combine(outDir, "chart.png")));
```

`<format-json-path>` 替换为实际格式 JSON 的绝对路径。

## 5. 工程结构

```
<target-dir>/
├── ChartWriter.csproj       ← 引用 Angri450.Nong.Chart
├── Program.cs               ← 分析+作图逻辑，每次覆盖
├── data.json                ← 分组数据（如需从 xlsx 读则不需要）
├── bin/Debug/               ← 编译产物（正常，勿删）
└── obj/Debug/               ← 中间文件（正常，勿删）
```

## 6. 后续使用

每次需要统计图表时:
1. 确认数据源（xlsx 或 JSON）
2. 用 Write 工具写入新的 `Program.cs`
3. `dotnet run --project <project-path>` 生成图表
4. 输出到 `~/Documents/GroundPA Toolkit Workplace/output/<timestamp>+<project>+<seq>/`
