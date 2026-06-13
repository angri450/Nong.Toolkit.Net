# Core C# Coding

Everyday C# and .NET skills: file-based apps, P/Invoke, and common patterns.

## File-Based C# Apps (`dotnet run file.cs`)

.NET 10+ can run `.cs` files directly without a project. Best for quick experiments, prototypes, and small utilities.

### Quick start

```bash
dotnet run hello.cs
```

```csharp
Console.WriteLine("Hello from a file-based app!");
var numbers = new[] { 1, 2, 3, 4, 5 };
Console.WriteLine($"Sum: {numbers.Sum()}");
```

### Directives (place at top, before `using`)

| Directive | Purpose | Example |
|-----------|---------|---------|
| `#:package` | NuGet reference | `#:package Humanizer@2.14.1` |
| `#:property` | MSBuild property | `#:property AllowUnsafeBlocks=true` |
| `#:project` | Project reference | `#:project ../Lib/Lib.csproj` |
| `#:ref` | File-based app reference | `#:ref ../Shared/Formatter.cs` |
| `#:include` | Multi-file include | `#:include Helpers.cs` |
| `#:exclude` | Exclude from include | `#:exclude Models/Generated/*.cs` |
| `#:sdk` | SDK override | `#:sdk Microsoft.NET.Sdk.Web` |

### Multi-file apps

```csharp
// hello.cs (entry point)
#:include Helpers.cs
#:include Models/*.cs

var person = new Person("Ada");
Console.WriteLine(Formatter.Title(person.Name));
```

```csharp
// Helpers.cs
static class Formatter
{
    public static string Title(string value) => value.ToUpperInvariant();
}
```

```csharp
// Models/Person.cs
record Person(string Name);
```

### Requirements
- Requires .NET 10 SDK or later
- `#:include`/`#:exclude`/`#:ref` require SDK 10.0.300+
- For older SDKs, fall back to `dotnet new console` + manual edits

## P/Invoke (Native Interop)

Calling native libraries from C#.

### Basic pattern

```csharp
using System.Runtime.InteropServices;

// Windows
[DllImport("user32.dll", CharSet = CharSet.Unicode)]
static extern int MessageBox(IntPtr hWnd, string text, string caption, uint type);

// Cross-platform via LibraryImport (recommended for .NET 7+)
[LibraryImport("libc.so.6", StringMarshalling = StringMarshalling.Utf8)]
internal static partial int getpid();
```

### Best practices
- Prefer `[LibraryImport]` over `[DllImport]` for .NET 7+ (source-generated, AOT-safe)
- Use `SafeHandle` for native handles, not `IntPtr`
- Set `CharSet` and `StringMarshalling` explicitly
- For cross-platform: use `RuntimeInformation.IsOSPlatform()` to select the right library

## Common C# Patterns

### Nullable reference types

```csharp
// Enable in .csproj: <Nullable>enable</Nullable>
string? maybeNull = null;
string definitely = maybeNull ?? "fallback";
```

### Pattern matching

```csharp
if (obj is string { Length: > 0 } s)
    Console.WriteLine(s);

var result = shape switch
{
    Circle { Radius: > 0 } c => $"Circle r={c.Radius}",
    Rectangle { Width: var w, Height: var h } => $"Rect {w}x{h}",
    _ => "Unknown"
};
```

### Span<T> for zero-allocation slices

```csharp
Span<char> buffer = stackalloc char[128];
ReadOnlySpan<char> slice = "hello world".AsSpan(0, 5);
```

## Validation

- [ ] `dotnet --version` shows 10+ for file-based apps
- [ ] Directives placed before `using`, after optional shebang
- [ ] P/Invoke uses `LibraryImport` where possible
- [ ] Native handles use `SafeHandle`
