# Excel Write Reference

## 模板选择（每次写之前必须做）

**向用户展示已有配色方案，主动问清楚。**

已有格式模板：

| # | 模板 | 表头 | 交替行 | 强调色 | 场景 |
|---|------|------|--------|--------|------|
| 1 | mono | 深灰白字 | 浅灰 | 蓝 #0066CC | 通用报表、数据看板 |
| 2 | finance | 深蓝白字 | 暖橙 | 深蓝 #1F4E79 | 财务报表、预算分析 |

然后问用户：**用哪个？需要微调颜色吗？还是给一个参考 xlsx 提取配色？**

- 用现成模板 → `StylePresets.BuildFromJson("<skill-path>/formats/mono.json")`
- 要微调 → 改对应 JSON 文件里的 `colors` / `formats` 字段
- 要新配色 → 创建 `formats/xxx.json`，INDEX.md 加一行

## Core Pattern

Every Excel creation follows this pattern:

```csharp
using ClosedXML.Excel;
using ExcelCore;

var wb = new XLWorkbook();

// Build sheets using ExcelBuilder or direct ClosedXML
ExcelBuilder.Sheet(wb, "SheetName")
    .Headers(...)
    .Data(...)
    .Formula(...)
    .ColumnWidths(...);

// Save with formula evaluation
FormulaValidator.SaveWithEvaluation(wb, "output.xlsx");
```

## Creating Sheets

### Via ExcelBuilder (recommended for simple data tables)

```csharp
ExcelBuilder.Sheet(wb, "销售报表")
    .At(2, 2)
    .Headers("列1", "列2", "列3")
    .Data(new[] {
        new[] { "值1", "值2", "值3" },
        new[] { "值4", "值5", "值6" },
    })
    .ColumnWidths(10, 12, 8)
    .NumberFormat("B2:B10", "#,##0");
```

### Via direct ClosedXML (for complex layouts)

```csharp
var ws = wb.AddWorksheet("复杂表");
ws.SheetView.ShowGridLines = false;

// Manual cell placement
ws.Cell("B2").Value = "标题";
ws.Cell("B2").Style.Font.SetBold().SetFontSize(16);
ws.Row(2).Height = 30;

ws.Cell("B4").Value = "项目";
ws.Cell("C4").Value = "金额";
```

## Writing Data

### String arrays

```csharp
var data = new string?[][] {
    new[] { "A", "100", "200" },
    new[] { "B", "150", "250" },
};
ExcelBuilder.Sheet(wb, "Data").Data(data);
```

### Typed objects

```csharp
var items = new[] {
    new { Name = "A", Price = 100, Qty = 5 },
    new { Name = "B", Price = 150, Qty = 3 },
};
ExcelBuilder.Sheet(wb, "Data").Data(items);
```

### Individual cells

```csharp
var ws = wb.AddWorksheet("Manual");
ws.Cell("B2").Value = "Hello";
ws.Cell("B3").Value = 42;
ws.Cell("B4").Value = DateTime.Now;
ws.Cell("B5").Value = true;
ws.Cell("B6").Value = Blank.Value;  // Empty
```

## Writing Formulas

```csharp
// Single cell
ws.Cell("D2").FormulaA1 = "B2*C2";

// Range fill (formula auto-adjusts)
ws.Range("D2:D100").FormulaA1 = "B2*C2";

// Aggregation
ws.Cell("D101").FormulaA1 = "SUM(D2:D100)";

// Cross-sheet
ws.Cell("E2").FormulaA1 = "VLOOKUP(A2,Products!$A$2:$C$50,3,FALSE)";

// Protected formula
ws.Cell("F2").FormulaA1 = "IFERROR(VLOOKUP(A2,$G$2:$I$50,3,FALSE),\"\")";
ws.Cell("G2").FormulaA1 = "IFERROR(A2/B2, 0)";
```

## Styling

### Via ExcelBuilder

```csharp
// Number format
.NumberFormat("B2:D100", "#,##0.00")

// Header style
.HeaderStyle("1F4E79", "FFFFFF", bold: true, fontSize: 11)

// Alternating rows
.AlternatingRows(3, "F5F5F5")

// Column widths
.ColumnWidths(10, 12, 8, 8, 12)

// Data bars
.DataBars("C2:C100", "4A90D9")

// Dropdown validation
.Dropdown("B2:B100", "苹果,香蕉,橙子,葡萄")                         // Hardcoded list
.Dropdown("C2:C100", "$A$1:$A$10")                                  // Same-sheet range
.Dropdown("D2:D100", "=Products!$A$2:$A$50")                        // Cross-sheet range
.Dropdown("E2:E100", "Open,In Progress,Closed",                      // With messages
    inputTitle: "状态", inputMessage: "选择一个状态",
    errorTitle: "无效", errorMessage: "请从下拉列表选择",
    errorStyle: "Stop")                                               // Stop | Warning | Information
```

### Via direct ClosedXML

```csharp
// Font
cell.Style.Font.SetBold();
cell.Style.Font.SetFontSize(14);
cell.Style.Font.SetFontColor(XLColor.FromHtml("1F4E79"));
cell.Style.Font.SetFontName("Arial");

// Fill
cell.Style.Fill.SetBackgroundColor(XLColor.FromHtml("F5F5F5"));

// Alignment
cell.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
cell.Style.Alignment.SetVertical(XLAlignmentVerticalValues.Center);
cell.Style.Alignment.SetWrapText();

// Border
cell.Style.Border.SetOutsideBorder(XLBorderStyleValues.Thin);
cell.Style.Border.SetOutsideBorderColor(XLColor.FromHtml("D0D0D0"));

// Number format
cell.Style.NumberFormat.SetFormat("#,##0.00");
```

## Data Validation (Dropdown)

### Via ExcelBuilder

```csharp
// Hardcoded list — comma-separated items
.Dropdown("B2:B100", "通过,未通过,待审核")

// Range reference — same sheet
.Dropdown("C2:C100", "$F$2:$F$10")

// Range reference — different sheet (with = prefix)
.Dropdown("D2:D100", "=Products!$A$2:$A$50")

// Per-column dropdown (uses last Data block range)
.Dropdown(2, "开放,关闭,暂停")  // Column index (B=2, C=3, ...)

// With input prompt
.Dropdown("E2:E100", "高,中,低",
    inputTitle: "优先级", inputMessage: "请选择任务优先级")

// With error alert
.Dropdown("F2:F100", "已完成,进行中,未开始",
    errorTitle: "输入无效", errorMessage: "只能从下拉列表中选择",
    errorStyle: "Stop")  // Stop | Warning | Information
```

Error styles:
- `"Stop"` (default) — blocks invalid input
- `"Warning"` — warns but allows with confirmation
- `"Information"` — shows message but allows any input

Auto-detection rules:
- Contains `$` or `!` → treated as range reference
- Contains `:` and short length (≤20 chars) → treated as range reference
- Everything else → treated as hardcoded comma-separated list

### Via direct ClosedXML

```csharp
var range = ws.Range("B2:B100");
var dv = range.CreateDataValidation();
dv.List("通过,未通过,待审核");
dv.InCellDropdown = true;
dv.IgnoreBlanks = true;
dv.ErrorStyle = XLErrorStyle.Stop;
dv.ErrorTitle = "输入无效";
dv.ErrorMessage = "只能从下拉列表中选择";
dv.InputTitle = "状态";
dv.InputMessage = "请选择一个状态";

// From a range
dv.List(sourceSheet.Range("A2:A50"));
```

## Tables (ListObjects)

```csharp
// Create table from range
ws.Range("A1:D10").CreateTable("MyTable");
```

## Named Ranges

```csharp
wb.DefinedNames.Add("GrowthRate", "Sheet1!$B$6");
wb.DefinedNames.Add("TaxRate", "Constants!$C$3");
```

## Sheet Organization

```csharp
// Add at specific position
wb.AddWorksheet("Summary", 1);  // First sheet

// Rename
ws.Name = "NewName";

// Reorder
ws.Position = 2;

// Hide
ws.Hide();

// Delete
wb.Worksheets.Delete("UnusedSheet");
```

## Page Setup

```csharp
ws.PageSetup.PageOrientation = XLPageOrientation.Landscape;
ws.PageSetup.FitToPages(1, 1);  // Fit to 1 page wide x 1 page tall
```

## Saving

```csharp
// Standard save
wb.SaveAs("output.xlsx");

// Save with formula evaluation (preferred)
FormulaValidator.SaveWithEvaluation(wb, "output.xlsx");

// Equivalent direct:
wb.SaveAs("output.xlsx", new SaveOptions
{
    EvaluateFormulasBeforeSaving = true,
    ValidatePackage = true,
    GenerateCalculationChain = true
});
```
