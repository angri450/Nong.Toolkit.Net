# .NET 11 Features

New APIs and language features in .NET 11, with focus on System.Text.Json enhancements.

## System.Text.Json in .NET 11

### JSON Schema generation

```csharp
using System.Text.Json.Schema;

var schema = JsonSchemaExporter.GetJsonSchemaAsNode(
    JsonSerializerOptions.Default,
    typeof(Order));
Console.WriteLine(schema);
```

### Order-preserving deserialization

```csharp
var options = new JsonSerializerOptions
{
    PropertyOrdering = JsonPropertyOrdering.Original
};
var obj = JsonSerializer.Deserialize<Order>(json, options);
```

### Enhanced polymorphic serialization

```csharp
[JsonDerivedType(typeof(Circle), "circle")]
[JsonDerivedType(typeof(Rectangle), "rectangle")]
public class Shape { }

var json = JsonSerializer.Serialize<Shape>(new Circle());
```

### Streaming deserialization

```csharp
await foreach (var item in JsonSerializer.DeserializeAsyncEnumerable<Order>(stream))
{
    ProcessOrder(item);
}
```

### JSON Path support

```csharp
using System.Text.Json.Nodes;

var node = JsonNode.Parse(json);
var value = node["$.store.book[0].title"];
```

## Language Features (.NET 11 / C# 14)

- **`field` keyword** for semi-auto properties
- **`params` Span<T>** overloads (allocation-free)
- **Extension types** (preview)
- **Implicit span conversions**

```csharp
// field keyword
public string Name
{
    get => field;
    set => field = value?.Trim() ?? throw new ArgumentNullException();
}

// params Span<T> — zero allocation
void Log(params ReadOnlySpan<string> messages) { }
Log("a", "b", "c");  // stack-allocated, no array
```

## Validation
- [ ] .NET 11 SDK installed (`dotnet --version` shows 11.x)
- [ ] Project targets `net11.0`
- [ ] New APIs compile and run correctly
