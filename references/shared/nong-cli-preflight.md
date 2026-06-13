# Nong CLI Preflight

Claude Code plugin installation only installs Nong.Toolkit.Net skills. It does not install the `nong` executable.

Before the first Nong command in a session, run:

```powershell
nong commands --json
```

Use Nong.Cli.Net 4.1.0 or newer. Confirm:

- `status` is `ok`.
- `summary` reports the expected command surface.
- `meta.version` is `4.1.0` or newer.
- The needed command group is listed in `data`.

If `nong` is missing or points at an old broken global tool, install or update:

```powershell
dotnet tool install --global Angri450.Nong.Cli
dotnet tool update --global Angri450.Nong.Cli
```

**Modular architecture (4.1.0+):** The 6 heavy modules (chart/diagram/pdf/pptx/ocr/imaging) are separate dotnet tools. On first use, `nong` auto-installs the missing tool. The user command surface is unchanged: `nong chart bar ...` still works, CLI handles the rest.

If a remote NuGet source is unavailable, install tools from a local pack directory:

```powershell
dotnet tool install --global Angri450.Nong.Tool.Chart --add-source <local-nupkg-dir>
dotnet tool install --global Angri450.Nong.Tool.Pdf --add-source <local-nupkg-dir>
# repeat for Tool.Diagram, Tool.Pptx, Tool.Ocr, Tool.Imaging
```

If the .NET host reports that no compatible framework was found, set roll-forward:

```powershell
$env:DOTNET_ROLL_FORWARD = "LatestMajor"
nong commands --json
```

For local source validation inside the Nong.Cli.Net repository, prefer the built executable:

```powershell
.\Cli\bin\Release\net8.0\nong.exe commands --json
```

Always use `--json` when a Nong result feeds another tool, model decision, report, or validation gate. Treat `status: "error"` as failed and read `errors[0].code` plus `errors[0].message` before choosing the next action.
