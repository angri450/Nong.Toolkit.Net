# Mainline plugin cleanup

Date: 2026-06-07

Scope:

1. Kept GroundPA Toolkit as a pure .NET / Nong CLI Claude Code multi-skill plugin.
2. Removed Python-dependent ToolUniverse from the plugin release surface.
3. Moved development-only, old, generic, and non-mainline material to local `_archive/`.
4. Kept `log/` as committed development-process history.
5. Rewrote README, README.zh-CN, SKILL.zh, plugin metadata, and skill index around the installable plugin model.

Release skills after cleanup:

```text
word, pdf, inspect, excel, chart, diagram, pptx, multimodal, genre, icons
```

Archived locally and ignored:

```text
CLAUDE.md, DEVELOP.md, install.ps1,
bash, powershell, dotnet, github, gitee, gitcode, ghproxy, nuget, ilspycmd, email,
skill-manager, tooluniverse
```
