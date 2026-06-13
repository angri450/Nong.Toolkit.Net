# NuGet Package Management

Package management, dependency modernization, and Central Package Management (CPM).

## Common Commands

```bash
dotnet add package <PACKAGE> [-v <VERSION>]      # Add package
dotnet remove package <PACKAGE>                    # Remove package
dotnet list package                                # List project packages
dotnet list package --outdated                     # Check for updates
dotnet list package --include-transitive           # Show transitive deps
dotnet list package --vulnerable                   # Check security vulnerabilities
dotnet restore                                     # Restore all packages
```

## Central Package Management (CPM)

Enable in `Directory.Packages.props`:

```xml
<Project>
  <PropertyGroup>
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
  </PropertyGroup>
  <ItemGroup>
    <PackageVersion Include="Newtonsoft.Json" Version="13.0.3" />
    <PackageVersion Include="Serilog" Version="4.0.0" />
  </ItemGroup>
</Project>
```

In `.csproj` files, omit versions:

```xml
<ItemGroup>
  <PackageReference Include="Newtonsoft.Json" />  <!-- version from Directory.Packages.props -->
  <PackageReference Include="Serilog" />
</ItemGroup>
```

### Converting to CPM

1. Create `Directory.Packages.props` at solution root
2. Set `<ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>`
3. Move all version attributes from `<PackageReference>` to `<PackageVersion>` in `.props`
4. Remove version attributes from `.csproj` files
5. Run `dotnet restore` to verify

## Package Source Management

```bash
dotnet nuget list source                              # List sources
dotnet nuget add source <URL> -n <NAME>               # Add source
dotnet nuget disable source <NAME>                    # Disable
dotnet nuget enable source <NAME>                     # Enable
```

## Trusted Publishing (NuGet.org)

```bash
dotnet pack -c Release
dotnet nuget push bin/Release/*.nupkg --api-key <KEY> --source https://api.nuget.org/v3/index.json
```

For CI/CD, use `dotnet nuget push` with OIDC token or API key from GitHub secrets.

## Dependency Auditing

```bash
# List all transitive dependencies with versions
dotnet list package --include-transitive

# Find packages not referenced directly
dotnet list package --include-transitive | grep -v ">" | grep " "

# Check for specific package across solution
grep -r "Newtonsoft.Json" **/*.csproj
```

## Common Issues

| Issue | Fix |
|-------|-----|
| NU1101: package not found | Check package source (`dotnet nuget list source`) |
| NU1107: version conflict | Use `dotnet list package --include-transitive` to find conflict |
| Package downgrade warning | Update to latest compatible versions |
| Lock file conflict | Delete `packages.lock.json` and restore |
| Vulnerability found | Update package, check `dotnet list package --vulnerable` |

## Validation
- [ ] `dotnet restore` succeeds
- [ ] No outdated/vulnerable packages
- [ ] CPM conversion verified with `dotnet restore`
- [ ] Package sources configured correctly
