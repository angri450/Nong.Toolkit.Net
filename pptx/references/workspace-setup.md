# PPTX Workspace Setup

No PPTX writer workspace is required for Nong.Toolkit.Net. Use the installed Nong CLI directly.

## Check The CLI

```powershell
nong commands --json
```

If the CLI is unavailable:

```powershell
dotnet tool install --global Angri450.Nong.Cli --add-source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json
```

## Read-Only Workflow

```powershell
nong pptx read deck.pptx --json
nong pptx slides deck.pptx --json
```

Store any exported JSON or summaries in the user's chosen project output directory. Do not create a PPTX writer project for Nong.Toolkit.Net tasks.
