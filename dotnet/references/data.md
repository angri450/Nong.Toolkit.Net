# EF Core / Data Access

Optimize Entity Framework Core queries: N+1 detection, tracking modes, compiled queries, and bulk operations.

## Enable Query Logging

```csharp
// In DbContext configuration
optionsBuilder
    .UseSqlServer(connectionString)
    .LogTo(Console.WriteLine, LogLevel.Information)
    .EnableSensitiveDataLogging()  // dev only — shows parameter values
    .EnableDetailedErrors();
```

Or via appsettings:
```json
{
  "Logging": {
    "LogLevel": {
      "Microsoft.EntityFrameworkCore.Database.Command": "Information"
    }
  }
}
```

## Fix N+1 Queries (the #1 issue)

**Before (N+1)**:
```csharp
var orders = await db.Orders.ToListAsync();
foreach (var order in orders)
{
    var items = order.Items.Count;  // Each access triggers a query!
}
```

**After — three options:**

```csharp
// Option 1: Include (single JOIN)
var orders = await db.Orders.Include(o => o.Items).ToListAsync();

// Option 2: Split query (avoids cartesian explosion)
var orders = await db.Orders.Include(o => o.Items).AsSplitQuery().ToListAsync();

// Option 3: Projection (best — only needed columns)
var summaries = await db.Orders
    .Select(o => new { o.Id, ItemCount = o.Items.Count })
    .ToListAsync();
```

### Split vs Single query decision

| Scenario | Use |
|----------|-----|
| 1 level of Include | Single query |
| Multiple Includes (cartesian risk) | `AsSplitQuery()` |
| Include with large child collections | `AsSplitQuery()` |
| Need transaction consistency | Single query |

## Tracking Mode

```csharp
// Per-query (read-only)
var products = await db.Products.AsNoTracking().ToListAsync();

// Global default
services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString)
           .UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking));
```

Use `AsNoTrackingWithIdentityResolution()` when duplicate entities appear in results.

## Compiled Queries (hot paths)

```csharp
private static readonly Func<AppDbContext, int, Task<Order?>> GetOrderById =
    EF.CompileAsyncQuery((AppDbContext db, int id) =>
        db.Orders.Include(o => o.Items).FirstOrDefault(o => o.Id == id));

// Use — skips compilation overhead
var order = await GetOrderById(db, orderId);
```

## Common Traps

| Trap | Problem | Fix |
|------|---------|-----|
| `ToList()` before `Where()` | Loads entire table | `.Where().ToList()` |
| `Count()` to check existence | Scans all rows | Use `.Any()` |
| `.Select()` after `.Include()` | Include ignored | Remove Include |
| `string.Contains()` in Where | May not translate | Use `EF.Functions.Like()` |
| Client eval warnings | Query runs in memory | Check LogLevel for `Query` category |

## Bulk Operations (EF Core 7+)

```csharp
// Bulk update
await db.Orders
    .Where(o => o.Status == OrderStatus.Pending)
    .ExecuteUpdateAsync(s => s.SetProperty(o => o.Status, OrderStatus.Processed));

// Bulk delete
await db.Orders
    .Where(o => o.CreatedAt < cutoff)
    .ExecuteDeleteAsync();
```

## Raw SQL

```csharp
// Safe: parameterized
var results = await db.Orders
    .FromSqlInterpolated($"SELECT * FROM Orders WHERE Total > {minTotal}")
    .AsNoTracking()
    .ToListAsync();

// Avoid: FromSqlRaw with string interpolation — SQL injection risk
```

## Validation
- [ ] SQL logging enabled and reviewed
- [ ] No N+1 queries (expected query count matches actual)
- [ ] Read-only queries use `AsNoTracking()`
- [ ] No client-side evaluation warnings
- [ ] Bulk operations use `ExecuteUpdateAsync`/`ExecuteDeleteAsync`
- [ ] DbContext lifetime is scoped (per-request), not cached
