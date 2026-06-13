# Nong CLI Preflight

Claude Code plugin installation only installs Nong.Toolkit.Net skills. It does not install the `nong` executable.

Before the first Nong command in a session, run:

```powershell
nong commands --json
```

Use Nong.Cli.Net 4.0.0 or newer. Confirm:

- `status` is `ok`.
- `summary` reports the expected command surface.
- `meta.version` is `4.0.0` or newer.
- The needed command group is listed in `data`.

If `nong` is missing or points at an old broken global tool, install or update:

```powershell
dotnet tool install --global Angri450.Nong.Cli --add-source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json
dotnet tool update --global Angri450.Nong.Cli --add-source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json
```

If the .NET host reports that no compatible framework was found, set roll-forward for the current shell and retry:

```powershell
$env:DOTNET_ROLL_FORWARD = "LatestMajor"
nong commands --json
```

For local source validation inside the Nong.Cli.Net repository, prefer the built 4.0.0 executable over a stale global tool:

```powershell
.\Cli\bin\Release\net8.0\nong.exe commands --json
```

Always use `--json` when a Nong result feeds another tool, model decision, report, or validation gate. Treat `status: "error"` as failed and read `errors[0].code` plus `errors[0].message` before choosing the next action.
