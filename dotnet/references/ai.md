# AI / ML Integration

MCP in C#, LLM integration, technology selection, and classic ML with ML.NET.

## MCP (Model Context Protocol) in C#

### Creating an MCP Server

```bash
# Create project
dotnet new console -n MyMcpServer
cd MyMcpServer
dotnet add package ModelContextProtocol
```

```csharp
using ModelContextProtocol;

var builder = McpServerBuilder.Create();

// Register a tool
builder.WithTool("greet", tool =>
{
    tool.WithDescription("Greets a user by name")
        .WithParameter("name", p => p.WithDescription("The name").Required())
        .WithHandler(async (params, cancellation) =>
        {
            var name = params["name"]!.GetValue<string>();
            return $"Hello, {name}!";
        });
});

var server = builder.Build();
await server.RunAsync();
```

### Debugging MCP

- Check stdio transport: no extra logging needed — use `Console.Error.WriteLine` for debug output
- Test with `mcp-inspector` or the host application
- Verify JSON-RPC compliance with `mcp validate`

### Publishing MCP

```bash
dotnet publish -c Release -o ./publish
# For native AOT (smaller, faster startup)
dotnet publish -c Release -o ./publish /p:PublishAot=true
```

## LLM Integration Patterns

### Microsoft.Extensions.AI

```csharp
// Install
dotnet add package Microsoft.Extensions.AI

// Chat client
IChatClient chat = new OpenAIChatClient(apiKey, modelId);
var response = await chat.GetResponseAsync("Explain async/await");
Console.WriteLine(response.Text);
```

## Technology Selection for AI/ML

| Scenario | Recommended |
|----------|-------------|
| Chat / LLM integration | Microsoft.Extensions.AI + OpenAI/Azure OpenAI |
| Text classification | ML.NET |
| Recommendation | ML.NET |
| Time series forecasting | ML.NET |
| Computer vision | ONNX Runtime / TorchSharp |
| NLP / transformers | TorchSharp / ONNX |
| MCP server | ModelContextProtocol |
| RAG pipeline | Microsoft.Extensions.AI + Semantic Kernel |

## ML.NET Quick Start

```csharp
// Install: dotnet add package Microsoft.ML

var ml = new MLContext();

// Load data
var data = ml.Data.LoadFromTextFile<Input>("data.csv", ',', hasHeader: true);

// Build pipeline
var pipeline = ml.Transforms.Concatenate("Features", nameof(Input.Age), nameof(Input.Salary))
    .Append(ml.Regression.Trainers.Sdca());

// Train
var model = pipeline.Fit(data);

// Predict
var prediction = ml.Model.CreatePredictionEngine<Input, Output>(model).Predict(new Input());
```

## Validation
- [ ] MCP tools tested with inspector or host
- [ ] AI package versions aligned with .NET SDK version
- [ ] ML.NET pipeline matches data schema
