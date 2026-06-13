# .NET Template Engine

Template discovery, project instantiation, authoring, and validation for `dotnet new`.

## Template Discovery

```bash
dotnet new list                    # List installed templates
dotnet new list <NAME>             # Filter by name
dotnet new list --tag <TAG>        # Filter by tag (web, console, library, etc.)
dotnet new search <QUERY>          # Search NuGet.org for templates
```

### Template details

```bash
dotnet new <SHORTNAME> --help      # Show template parameters and options
```

## Project Instantiation

```bash
dotnet new console -n MyApp -o ./MyApp
dotnet new webapi -n MyApi --use-controllers
dotnet new classlib -n MyLib
dotnet new blazorwasm -n MyBlazorApp
dotnet new maui -n MyMauiApp
```

### Common parameters

| Parameter | Description |
|-----------|-------------|
| `-n, --name` | Project name |
| `-o, --output` | Output directory |
| `-f, --framework` | Target framework (e.g., `net10.0`) |
| `--force` | Overwrite existing files |
| `--no-restore` | Skip package restore |
| `--dry-run` | Show what would be created |

### Template packages from NuGet

```bash
dotnet new install <PACKAGE>        # Install template package
dotnet new uninstall <PACKAGE>      # Uninstall
dotnet new install <PATH>           # Install from local folder
```

## Template Validation

```bash
# Validate a template.json
dotnet new <TEMPLATE> --dry-run

# Check that all parameters work
dotnet new <TEMPLATE> -n TestProj -o /tmp/test --force && rm -rf /tmp/test
```

## Validation
- [ ] Template is discoverable (`dotnet new list`)
- [ ] Template creates expected files with correct content
- [ ] Parameters work as documented
- [ ] Template works with `--dry-run`
