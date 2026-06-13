# Publishing Workflow

## 1. Update version

In `.csproj`, increment `<Version>`:

```xml
<Version>1.0.4</Version>
```

Semantic versioning: `major.minor.patch`. Increment patch for bug fixes, minor for features, major for breaking changes.

## 2. Build and test

```bash
dotnet test <test-project> -c Release
```

Never publish without passing tests.

## 3. Pack

```bash
dotnet pack <project> -c Release
```

Output goes to `<project>/bin/Release/<id>.<version>.nupkg`.

## 4. Check package contents

```bash
# The nupkg is a zip — list its contents
unzip -l <path-to-nupkg>
```

Verify: DLL, deps.json, runtimeconfig.json, any embedded resources.

## 5. Push to NuGet.org

```bash
dotnet nuget push <nupkg> --api-key <key> --source https://api.nuget.org/v3/index.json
```

API key: https://www.nuget.org/account/apikeys

CDN sync takes 10-30 minutes. Check with:

```bash
# After push, wait then verify
dotnet tool install --global <package-id> 2>&1
```

## 6. Push symbol package (optional)

```bash
dotnet nuget push <snupkg> --api-key <key> --source https://api.nuget.org/v3/index.json
```

Requires `<IncludeSymbols>true</IncludeSymbols>` and `<SymbolPackageFormat>snupkg</SymbolPackageFormat>` in csproj.
