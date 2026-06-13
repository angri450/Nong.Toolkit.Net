# ASP.NET Core

Middleware, endpoints, OpenTelemetry, minimal APIs, and real-time communication.

## OpenTelemetry Configuration

### Install packages

Pick exactly these — do NOT install `OpenTelemetry` alone:

```bash
dotnet add package OpenTelemetry.Extensions.Hosting
dotnet add package OpenTelemetry.Instrumentation.AspNetCore
dotnet add package OpenTelemetry.Instrumentation.Http
dotnet add package OpenTelemetry.Exporter.OpenTelemetryProtocol
```

Optional auto-instrumentation:
```bash
dotnet add package OpenTelemetry.Instrumentation.SqlClient           # SQL Server
dotnet add package OpenTelemetry.Instrumentation.EntityFrameworkCore  # EF Core
dotnet add package OpenTelemetry.Instrumentation.GrpcNetClient       # gRPC
dotnet add package OpenTelemetry.Instrumentation.Runtime             # GC/threadpool metrics
```

### Configure in Program.cs

```csharp
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using OpenTelemetry.Metrics;
using OpenTelemetry.Logs;

builder.Services.AddOpenTelemetry()
    .ConfigureResource(resource => resource
        .AddService(serviceName: builder.Environment.ApplicationName))
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation(o => o.RecordException = true)
        .AddSource("MyApp.Orders"))
    .WithMetrics(metrics => metrics
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddMeter("MyApp.Metrics"))
    .WithLogging(logging => logging.IncludeScopes = true)
    .UseOtlpExporter();  // Reads OTEL_EXPORTER_OTLP_ENDPOINT
```

### Creating custom spans

```csharp
private static readonly ActivitySource ActivitySource = new("MyApp.Orders");
// Name must match AddSource("...") in configuration

using var activity = ActivitySource.StartActivity("ProcessOrder");
activity?.SetTag("order.customer_id", request.CustomerId);
activity?.SetTag("order.item_count", request.Items.Count);
```

**#1 debugging issue**: `ActivitySource` name doesn't match `AddSource(...)` → silently ignored.

### Creating custom metrics

```csharp
public class OrderMetrics
{
    private readonly Counter<long> _ordersProcessed;
    private readonly Histogram<double> _orderDuration;

    public OrderMetrics(IMeterFactory meterFactory)
    {
        var meter = meterFactory.Create("MyApp.Metrics");
        _ordersProcessed = meter.CreateCounter<long>("orders.processed");
        _orderDuration = meter.CreateHistogram<double>("orders.duration", "ms");
    }

    public void RecordOrder(long durationMs)
    {
        _ordersProcessed.Add(1);
        _orderDuration.Record(durationMs);
    }
}
```

## Minimal APIs

### File upload
```csharp
app.MapPost("/upload", async (IFormFile file) =>
{
    var path = Path.Combine("uploads", file.FileName);
    using var stream = File.Create(path);
    await file.CopyToAsync(stream);
    return Results.Ok(new { path });
}).DisableAntiforgery();  // For API-only endpoints
```

### Request validation
```csharp
app.MapPost("/orders", async (CreateOrderRequest req, OrderService svc) =>
{
    if (!MiniValidator.TryValidate(req, out var errors))
        return Results.ValidationProblem(errors);

    var order = await svc.CreateAsync(req);
    return Results.Created($"/orders/{order.Id}", order);
});
```

## Middleware Patterns

```csharp
// Custom middleware
app.Use(async (context, next) =>
{
    var sw = Stopwatch.StartNew();
    await next(context);
    sw.Stop();
    Console.WriteLine($"{context.Request.Path} took {sw.ElapsedMilliseconds}ms");
});

// Exception handling
app.UseExceptionHandler("/error");
```

## Common Patterns

| Pattern | Approach |
|---------|----------|
| Health checks | `app.MapHealthChecks("/healthz")` |
| CORS | `builder.Services.AddCors()` + `app.UseCors()` |
| Rate limiting | `builder.Services.AddRateLimiter()` |
| Output caching | `builder.Services.AddOutputCache()` |
| Authentication | `builder.Services.AddAuthentication().AddJwtBearer()` |

## Validation
- [ ] OpenTelemetry packages match what the app actually uses
- [ ] `ActivitySource` names match `AddSource(...)` registrations
- [ ] `Meter` names match `AddMeter(...)` registrations
- [ ] `UseOtlpExporter()` configured (single exporter for all signals)
- [ ] No `OpenTelemetry` alone — use `OpenTelemetry.Extensions.Hosting`
