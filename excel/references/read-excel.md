# Excel Read Reference

## Reading Excel Files with ClosedXML

### Open a workbook

```csharp
using var wb = new XLWorkbook("input.xlsx");
// Or from stream:
using var wb = new XLWorkbook(File.OpenRead("input.xlsx"));
```

### List and access worksheets

```csharp
// List all sheet names
foreach (var ws in wb.Worksheets)
    Console.WriteLine(ws.Name);

// Access by name or position
var ws = wb.Worksheet("Data");
var ws = wb.Worksheet(1);

// Check sheet existence
if (wb.TryGetWorksheet("Data", out var sheet))
    Console.WriteLine("Found");
```

### Read data

```csharp
var ws = wb.Worksheet("Data");

// Get used range dimensions
var lastRow = ws.LastRowUsed()?.RowNumber() ?? 0;
var lastCol = ws.LastColumnUsed()?.ColumnNumber() ?? 0;

// Read cell by address
var val = ws.Cell("B2").Value;
var text = ws.Cell("B2").GetString();
var num = ws.Cell("B2").GetDouble();

// Read cell by row/col
var val = ws.Cell(2, 2).Value;

// Iterate all used cells
foreach (var cell in ws.CellsUsed())
    Console.WriteLine($"{cell.Address}: {cell.Value}");

// Iterate a range
foreach (var cell in ws.Range("A2:D100").Cells())
    Console.WriteLine($"{cell.Address}: {cell.Value}");

// Read row by row
for (int r = 1; r <= lastRow; r++)
{
    var row = ws.Row(r);
    // access row.Cell(1), row.Cell(2), etc.
}
```

### Read formulas

```csharp
// Has formula?
if (cell.HasFormula)
{
    var formulaA1 = cell.FormulaA1;     // e.g., "SUM(B2:B10)"
    var cachedVal = cell.CachedValue;    // The last cached result
}

// Find all formula cells
var formulaCells = ws.CellsUsed(c => c.HasFormula);
```

### Detect errors

```csharp
// Check for error values
if (cell.CachedValue.IsError)
{
    var err = cell.GetError();  // XLError enum: DivisionByZero, NameNotRecognized, etc.
}

// Scan all cells for errors
var errors = new List<string>();
foreach (var cell in ws.CellsUsed())
{
    if (cell.CachedValue.IsError)
        errors.Add($"{ws.Name}!{cell.Address}: {cell.GetError()}");
}
```

### Extract structure

```csharp
// Tables (ListObjects)
foreach (var table in ws.Tables)
{
    Console.WriteLine($"Table: {table.Name}, Range: {table.RangeBase.RangeAddress}");
    foreach (var field in table.Fields)
        Console.WriteLine($"  Column: {field.Name}");
}

// Named ranges (workbook-level)
foreach (var name in wb.DefinedNames)
    Console.WriteLine($"Name: {name.Name}, RefersTo: {name.RefersTo}");

// Hyperlinks
foreach (var cell in ws.CellsUsed(c => c.HasHyperlink))
    Console.WriteLine($"{cell.Address}: {cell.GetHyperlink().ExternalAddress}");
```

### Type-safe reading

```csharp
// TryGetValue avoids exceptions
if (cell.TryGetValue<int>(out var intVal))
    Console.WriteLine($"Integer: {intVal}");
if (cell.TryGetValue<double>(out var dblVal))
    Console.WriteLine($"Double: {dblVal}");
if (cell.TryGetValue<DateTime>(out var dateVal))
    Console.WriteLine($"Date: {dateVal}");
if (cell.TryGetValue<string>(out var strVal))
    Console.WriteLine($"String: {strVal}");

// Or use XLCellValue type checks
var v = cell.Value;
if (v.IsNumber) { var d = v.GetNumber(); }
if (v.IsText) { var s = v.GetText(); }
if (v.IsDateTime) { var dt = v.GetDateTime(); }
if (v.IsTimeSpan) { var ts = v.GetTimeSpan(); }
```

### Data extraction patterns

```csharp
// Extract table as List<T>
var rows = new List<Dictionary<string, object>>();
var ws = wb.Worksheet("Data");
var headers = new List<string>();
for (int c = 1; c <= ws.LastColumnUsed()?.ColumnNumber(); c++)
    headers.Add(ws.Cell(1, c).GetString());

for (int r = 2; r <= (ws.LastRowUsed()?.RowNumber() ?? 1); r++)
{
    var row = new Dictionary<string, object>();
    for (int c = 0; c < headers.Count; c++)
        row[headers[c]] = ws.Cell(r, c + 1).Value;
    rows.Add(row);
}
```
