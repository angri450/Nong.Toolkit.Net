# Package Project Template

Reference implementation: a .NET class library published as a NuGet package.

## Minimal csproj

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <RootNamespace>MyLibrary</RootNamespace>
    <AssemblyName>MyCompany.MyLibrary</AssemblyName>
    <PackageId>MyCompany.MyLibrary</PackageId>
    <Version>1.0.0</Version>
    <Authors>your-name</Authors>
    <Description>One-line description. Appears in NuGet search results.</Description>
    <PackageLicenseExpression>Apache-2.0</PackageLicenseExpression>
    <PackageReadmeFile>README.md</PackageReadmeFile>
    <RepositoryUrl>https://github.com/your-org/your-repo</RepositoryUrl>
    <PackageTags>key words here</PackageTags>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="DocumentFormat.OpenXml" Version="*" />
    <PackageReference Include="System.Drawing.Common" Version="*" />
  </ItemGroup>

  <ItemGroup>
    <None Include="README.md" Pack="true" PackagePath="/" />
  </ItemGroup>
</Project>
```

## Required fields

| Field | Purpose |
|-------|---------|
| `PackageId` | Package name on NuGet.org |
| `Version` | Semantic version. Bump on every publish. |
| `Authors` | Package owner |
| `Description` | Shows in NuGet search results |
| `PackageLicenseExpression` | SPDX identifier (Apache-2.0, MIT, etc.) |
| `PackageReadmeFile` | README shown on NuGet.org package page |

## Dependency policy

For consumption (user's project): `Version="*"` — never pin.

For this package's own csproj: also `Version="*"`. NuGet resolves at restore time. When publishing, the nuspec records the resolved version. Receivers get the latest matching `*` at their restore time.

Exception: if a dependency has a breaking change and you need to hold it back, use a range: `[1.0.0, 2.0.0)`.

## Packing README

```xml
<ItemGroup>
  <None Include="README.md" Pack="true" PackagePath="/" />
</ItemGroup>
```

Without this, NuGet.org shows a "missing readme" warning on the package page.

## Version bump checklist

1. Update `<Version>` in csproj
2. Update CHANGELOG if tracked
3. `dotnet pack -c Release`
4. `dotnet nuget push`
5. CDN wait: 10-30 min for global sync
