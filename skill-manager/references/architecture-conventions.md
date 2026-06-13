# Architecture Conventions

所有 skill 遵循以下架构约定。违背任何一条都会导致 skill 在只读环境下失效。

## 1. 源码只读，运行时分流

Skill 文件夹是只读的。接收方的 agent 挂载后不能往里写文件。所有需要反复修改的内容——编译产物、评测数据、运行结果——一律重定向到用户文档目录。

通过 `Directory.Build.props` 中的 `ArtifactsPath` 实现：

```xml
<ArtifactsPath>$([System.IO.Path]::Combine(
  $([System.Environment]::GetFolderPath(SpecialFolder.MyDocuments)),
  "GroundPA Toolkit Workplace\\skill-manager"
))</ArtifactsPath>
```

`obj/`、`bin/` 全部生成到 `<workplace>/skill-manager/` 下，源码目录零污染。评测用例、运行产出、会话记录同理。

## 2. 包版本使用通配符

`.csproj` 中的 `PackageReference` 一律使用 `Version="*"`，不锁定版本号。接收方 `dotnet restore` 时自行解析当前 NuGet 上的最新稳定版。Skill 文件夹只声明"需要什么"，不声明"什么版本"。

```xml
<PackageReference Include="YamlDotNet" Version="*" />
```

## 3. 不设 SDK 版本下限

不包含 `global.json` 文件。用户装了什么版本的 .NET SDK 就用什么，由运行时自动选择。最低目标框架通过 `.csproj` 的 `TargetFramework` 表达即可（当前为 `net8.0`）。

## 4. 会话自动记录

CLAUDE.md 中全局开启。AI 在会话中遇到并修复错误后，自动追加一行 JSON 到 `<workplace>/skill-manager/session-records/当天日期.jsonl`。用户无需操作，不修改任何 skill 文件。维护者定期收集改进。

详见 `references/session-recording.md`。

## 5. Manifest versioning — the `plugin.json` trap

Claude Code reads `"version"` from `.claude-plugin/plugin.json`, NOT from `skills.sh.json`, NOT from git tags. If `plugin.json` version is wrong, Claude shows the wrong version forever.

**Files that matter for version display:**

| File | Purpose | Who reads it |
|------|---------|-------------|
| `.claude-plugin/plugin.json` → `"version"` | Version + skill array | **Claude (primary)** |
| `skills.sh.json` → `"version"` + groups | Marketplace manifest | Marketplace system |
| `git tag` | Code history marker | Humans + CI |

**Release checklist — all four must be updated together:**

1. `.claude-plugin/plugin.json` → bump `"version"`, add new skills to `"skills"` array
2. `skills.sh.json` → bump `"version"`, add new skills to groups
3. `git tag -a vX.Y.Z` → code history
4. GitHub/Gitee Release → human-readable changelog

**The trap we fell into:** bumped skills.sh.json and git tag, forgot plugin.json. Claude showed 1.0.0 through three rounds of "fixes" until we found the real version file. This is now documented in both github and gitee skills.

**New skill registration:**
- `.claude-plugin/plugin.json` → add to `"skills"` array + `"keywords"` + update description count
- `skills.sh.json` → add to appropriate group
