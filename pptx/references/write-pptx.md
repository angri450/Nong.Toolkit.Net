# PPT Write Reference

## 模板选择（每次写之前必须做）

**向用户展示已有主题，主动问清楚。**

已有格式模板（10 套）：

| # | 模板 | 强调色 | 中文字体 | 场景 |
|---|------|--------|----------|------|
| 1 | professional | 深蓝 #1F4E79 | 微软雅黑 | 商务汇报 |
| 2 | academic | 暗红 #8B0000 | 宋体/黑体 | 论文答辩 |
| 3 | midnight-executive | 午夜蓝 #1E2761 | 微软雅黑 | 高端演示 |
| 4 | coral-energy | 珊瑚红 #F96167 | 微软雅黑 | 创业路演 |
| 5 | teal-trust | 青绿 #028090 | 微软雅黑 | 医疗/环保 |
| 6 | cherry-bold | 樱桃红 #990011 | 黑体 | 战略宣导 |
| 7 | modern | 绿蓝紫 | 微软雅黑 | 科技演示 |
| 8 | minimal | 灰阶 | 微软雅黑 | 极简风格 |
| 9 | warm | 橙黄 | 黑体 | 故事讲述 |
| 10 | cool | 蓝青 | 微软雅黑 | 数据报告 |

然后问用户：**用哪个？需要微调配色或字体吗？**

- 用现成模板 → `ThemePreset.Professional` 或 `ThemePreset.BuildFromJson("<skill-path>/formats/professional.json")`
- 要微调 → 改对应 JSON 文件里的颜色/字体字段
- 要新主题 → 创建 `formats/xxx.json`，INDEX.md 加一行

## Core Pattern

```csharp
using PptxCore;

string output = @"output.pptx";

SlideBuilder.Create()            // 16:9 widescreen by default
    .Theme(ThemePreset.Professional)
    // ... add slides ...
    .Save(output);

// Preview (mandatory after generation)
var result = SlidePreview.Preview(output);
Console.WriteLine(result.Text);
if (result.Warnings.Count > 0) { /* fix and regenerate */ }

// Validate (mandatory before delivery)
SlideValidator.ValidateAndReport(output);
```

## Presentation Settings

```csharp
SlideBuilder.Create()
    .Widescreen()                // 16:9 (960 x 540 pt) — default
    .Standard()                  // 4:3  (960 x 720 pt)
    .Theme(ThemePreset.Academic) // apply preset color + font scheme
```

### Theme 实际生效规则 (v1.0.4+)

`.Theme()` 现在真正生效。以下样式会自动应用：

| 元素 | 应用规则 |
|------|----------|
| Title placeholder | HeadFont/HeadCJK, Accent1 颜色, Bold, 默认 28pt (TitleSlide: 36pt) |
| Subtitle placeholder | BodyFont/BodyCJK, Accent2 颜色, 20pt |
| Content bullets | BodyFont/BodyCJK, Dark1, 18pt, bullet 字符 "•" Accent1 色 |
| Table header row | Accent1 填充 + Light1(白) Bold 文字, HeadFont, 16pt |
| Table data rows | 交替 Light2 背景 (偶数行) |
| Chart caption | BodyFont/BodyCJK, Dark1, 14pt |
| Freeform TextBox | BodyFont/BodyCJK, Dark1, 默认 18pt |
| Freeform Shape | 无 fillHex 时自动用 Accent1 填充 |

所有文字同时设 LatinName 和 EastAsianName (CJK)。主题在 Save() 时注入 SlideMaster。

## Theme Presets

| Preset | Accent | Font | Best for |
|--------|--------|------|----------|
| `Professional` | Navy blues | 微软雅黑 + Calibri | Corporate reports |
| `Academic` | Maroon reds | 宋体/黑体 + Times New Roman | Academic papers |
| `MidnightExecutive` | Deep navy | 微软雅黑 + Calibri | Boardroom decks |
| `CoralEnergy` | Coral + gold | 微软雅黑 + Segoe UI | Startup pitches |
| `TealTrust` | Teal + mint | 微软雅黑 + Calibri | Healthcare / ESG |
| `CherryBold` | Cherry red | 黑体 + Arial Black | Strategy / disruption |
| `Modern` | Green/blue/purple | 微软雅黑 + Segoe UI | Tech pitches |
| `Minimal` | Greyscale | 微软雅黑 + Helvetica | Clean decks |
| `Warm` | Orange/yellow | 黑体 + Georgia | Storytelling |
| `Cool` | Blue/teal | 微软雅黑 + Calibri | Data-heavy |

JSON themes (load via `ThemePreset.BuildFromJson`): `professional`, `academic`, `midnight-executive`, `coral-energy`, `teal-trust`, `cherry-bold`.

## Density Limits (check before generating)

Every slide type has a hard content budget. **Exceeding these limits produces unreadable slides.** If content doesn't fit, split into multiple slides.

| Slide Type | Max Content |
|------------|-------------|
| Title slide | 1 heading + 1 subtitle + optional author/date |
| Content slide | 1 heading + 4-6 bullets **or** 1 heading + 2 paragraphs |
| Table slide | 1 heading + table (max 6 columns, 10 rows) |
| Chart slide | 1 heading + 1 chart + 1 sentence caption |
| Image slide | 1 heading + 1 image (max 60% slide height) |

Text constraints:
- Title font size: 28-44pt
- Body font size: 14-24pt (never below 14pt)
- Max line length per bullet: ~60 characters (Chinese) / ~100 characters (English)
- Min margin from slide edges: 0.5 inch

## Slide Layouts

### Title Slide

```csharp
.AddTitleSlide(opt => opt
    .Title("年度报告 2024")
    .Subtitle("业绩回顾与展望")
    .Author("某某公司")
    .TitleSize(40)          // default: 36
    .TitleColor("1F4E79")  // default: #1F4E79
    .Background("FFFFFF"))  // default: white
```

### Content Slide (title + bullet list)

```csharp
.AddContentSlide(opt => opt
    .Title("核心业绩指标")
    .Bullets("营收增长30%",
             "用户翻倍",
             "成本下降15%"))
```

### Table Slide

```csharp
.AddTableSlide(opt => opt
    .Title("季度明细")
    .Data(new[] {
        new[] { "季度", "Q1", "Q2", "Q3", "Q4" },
        new[] { "营收", "10.2", "12.5", "13.8", "14.1" },
        new[] { "利润", "2.1", "2.8", "3.2", "3.4" }
    }))
```

Headers are auto-styled (dark fill, white text, bold). Even rows get alternating background.

### Chart Slide

```csharp
// Pie chart
.AddChartSlide(opt => opt
    .Title("营收构成")
    .ChartTitle("各产品线占比")
    .PieChart(new Dictionary<string, double> {
        { "产品A", 38 }, { "产品B", 27 }, { "产品C", 20 }, { "其他", 15 }
    }))

// Bar chart
.AddChartSlide(opt => opt
    .Title("季度趋势")
    .ChartTitle("营收（亿元）")
    .BarChart(new Dictionary<string, double> {
        { "Q1", 10.2 }, { "Q2", 12.5 }, { "Q3", 13.8 }, { "Q4", 14.1 }
    }))
```

## Freeform Slides (SlideHelper)

For layouts beyond the presets, use `AddSlide()`:

```csharp
.AddSlide()
    .TextBox("自由标题", x: 40, y: 30, w: 880, h: 50,
        fontSize: 28, fontName: "微软雅黑", bold: true, colorHex: "1F4E79")
    .TextBox("正文内容...", x: 40, y: 100, w: 880, h: 300,
        fontSize: 18, align: "Left")
    .Shape(Geometry.RoundedRectangle, x: 40, y: 420, w: 200, h: 60,
        fillHex: "1F4E79", text: "按钮")
    .Picture(@"C:\image.png", x: 600, y: 100, w: 300, h: 200)
    .Background("F5F5F5")
```

## Speaker Notes

```csharp
// After the slide you want notes for
.Notes("要点提醒", "补充数据见附录")
```

## Saving

```csharp
// Save to file
.Save("output.pptx")
```

## Full Example

```csharp
using PptxCore;

SlideBuilder.Create()
    .Theme(ThemePreset.Professional)
    .AddTitleSlide(opt => opt
        .Title("项目汇报")
        .Subtitle("Q1 阶段总结")
        .Author("张三"))
    .AddContentSlide(opt => opt
        .Title("完成情况")
        .Bullets("模块A：已完成开发并上线",
                 "模块B：测试通过，待部署",
                 "模块C：功能开发中，进度70%"))
    .AddTableSlide(opt => opt
        .Title("KPI 完成情况")
        .Data(new[] {
            new[] { "指标", "目标", "实际", "达成率" },
            new[] { "营收", "100M", "120M", "120%" },
            new[] { "用户", "50万", "62万", "124%" },
            new[] { "NPS", "60", "68", "113%" }
        }))
    .AddChartSlide(opt => opt
        .Title("渠道分布")
        .ChartTitle("各渠道营收占比")
        .PieChart(new Dictionary<string, double> {
            { "线上", 45 }, { "线下", 30 }, { "渠道", 25 }
        }))
    .Notes("Q1超额完成任务，Q2目标需要上调")
    .Save(@"report.pptx");
```
