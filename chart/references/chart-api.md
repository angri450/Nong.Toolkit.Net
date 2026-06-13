# ChartCore API Reference

所有 API 位于 `ChartCore` 命名空间。完整类型定义见 NuGet 包的 IntelliSense。

## StatsEngine — 统计引擎

### OneWayAnova

```csharp
var anova = StatsEngine.OneWayAnova(groups);
// 返回: AnovaResult { F, P, SSB, SSW, SST, MSB, MSW, dfB, dfW, N, GroupStats }
```

### DuncanMRT

```csharp
var duncan = StatsEngine.DuncanMRT(groups, anova.MSW, anova.dfW, alpha: 0.05);
// 返回: DuncanResult { Groups = List<DuncanGroup> }
// DuncanGroup { Label, Mean, SD, Significance }
```

从 DuncanResult 构造字典供 ChartBuilder 用:

```csharp
var sigLabels = duncan.Groups.ToDictionary(g => g.Label, g => g.Significance);
```

### FullAnalysis

```csharp
var result = StatsEngine.FullAnalysis(groups, alpha: 0.05);
// 返回: FullAnalysisResult { Anova, Duncan }
result.Print();  // 格式化输出到 stdout
```

### GroupStats

```csharp
var stats = GroupStats.Compute(list);
// GroupStats { N, Mean, SD, SEM, Min, Max }
```

## ChartBuilder — 图表生成器

### 带显著性标注的柱形图（论文推荐）

```csharp
ChartBuilder.BarChartWithSignificance(
    groups,           // Dictionary<string, List<double>>
    sigLabels,        // Dictionary<string, string> 显著性字母
    "不同处理对株高的影响",  // 标题
    "株高 / cm",      // Y轴标签
    "chart.png",      // 输出路径
    width: 800,       // 可选，默认 800
    height: 600);     // 可选，默认 600
```

### 简单柱形图

```csharp
ChartBuilder.BarChart(
    groups, "标题", "Y轴", "chart.png",
    colors: null,       // 默认色盲友好配色
    width: 800, height: 600,
    showErrorBar: true, showGrid: true);
```

### 完整配置（BarChartConfig）

```csharp
ChartBuilder.BarChart(new BarChartConfig
{
    Groups = groups,
    Title = "...",
    YLabel = "...",
    OutPath = "chart.png",
    Width = 800, Height = 600,
    Colors = BarChartConfig.DefaultColors,
    ShowErrorBar = true,
    ShowSignificance = true,
    SignificanceLabels = sigLabels,
    ShowMeanValue = false,
    TitleFontSize = 20,
    AxisFontSize = 14,
    BarWidth = 0.6f,
    ShowGrid = true,
});
```

## ChartCombine — 多图拼接

```csharp
ChartCombine.MergeHorizontal(
    new[] { "fig1.png", "fig2.png", "fig3.png" },
    new[] { "A", "B", "C" },      // 标号，null 不标
    "fig_combined.png",
    panelHeight: 0,                 // 0=自动，>0=强制统一高度
    gap: 10,                        // 图间距 px
    labelFontSize: 18);
```

## DataLoader — 数据加载

### 从 JSON 读（推荐）

```json
{"T1": [1.2, 1.5, 1.8, 1.1, 1.4], "T2": [2.1, 2.3, 2.5, 2.2, 2.8]}
```

```csharp
var groups = DataLoader.FromJson("data.json");
```

### 从 xlsx 读单列

列 A=处理组名，列 B=观测值:

```csharp
var groups = DataLoader.FromXlsx("data.xlsx", "Sheet1",
    groupCol: 1, valueCol: 2);
```

### 从 xlsx 读多列取均值

列 A=处理组名，列 B/C/D=重复观测值（取均值作为每个重复单元）:

```csharp
var groups = DataLoader.FromXlsxMultiColumn("data.xlsx", "Sheet1",
    groupCol: 1, valueCols: new[] { 2, 3, 4 });
```

### 从 CSV 读

```csharp
var groups = DataLoader.FromCsv("data.csv");
// CSV 格式: label,value
```

## 默认配色

色盲友好的默认配色（Blue/Orange/Green/Yellow/Purple/Red）:

```
#5B9BD5  蓝
#ED7D31  橙
#70AD47  绿
#FFC000  黄
#A574B6  紫
#DB4453  红
```

自定义配色:

```csharp
var myColors = new ScottPlot.Color[] {
    new(0, 100, 200),
    new(200, 80, 40),
};
ChartBuilder.BarChart(config with { Colors = myColors });
```

## 典型 workflow

```csharp
// 1. 加载数据
var groups = DataLoader.FromJson("data.json");
// 或者从 xlsx:
// var groups = DataLoader.FromXlsxMultiColumn("data.xlsx", "新梢长度",
//     groupCol: 1, valueCols: new[] { 2, 3, 4, 5 });

// 2. 统计分析
var analysis = StatsEngine.FullAnalysis(groups);

// 3. 打印结果
analysis.Print();

// 4. 构造显著性字典
var sigLabels = analysis.Duncan.Groups.ToDictionary(g => g.Label, g => g.Significance);

// 5. 生成图表
ChartBuilder.BarChartWithSignificance(
    groups, sigLabels,
    "不同处理对桃树新梢长度的影响",
    "新梢长度 / cm",
    Path.Combine(outDir, "fig1_shoot.png"));
```

## 错误处理

- 数据为空：`OneWayAnova` 抛出 `InvalidOperationException`
- 分组数 < 2：ANOVA 需要至少 2 个处理
- 文件不存在：`DataLoader` 抛出 `FileNotFoundException`
- xlsx 工作表不存在：ClosedXML 抛出异常
