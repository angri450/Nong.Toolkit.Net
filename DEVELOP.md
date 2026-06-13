# 开发说明

## 当前状态

- 仓库：`https://github.com/angri450/GroundPA-Toolkit`
- 本地：`<repo-root>`
- 版本：v2.1.0
- 架构：Nong CLI-first skill layer

## 2.1.0 边界

只把当前 `nong commands --json` 中标记为 `implemented` 的能力做成 skill。

已暴露：

```text
word, inspect, excel, chart, diagram, genre, icons
pptx, multimodal
bash, powershell, dotnet, github, gitee, ghproxy, nuget, ilspycmd, email, skill-manager
```

门控暴露：

```text
ocr local: 入口存在，但可能返回 E005/E009；只有本地模型和推理路径实测 EXIT:0 后才能作为稳定 OCR 路径推荐。
ocr cloud / ocr to-word: 需要 PADDLEOCR_ACCESS_TOKEN。
pptx: 只暴露 read/slides，不承诺生成或编辑。
```

当前 `nong commands --json` 是唯一信源。文档、manifest、README 和 SKILL.md 不得使用历史 changelog 口径替代真实命令面。

## 日常提交流程

```bash
git status
git add <file>
git commit -m "类型: 简述"
git push origin master:main
```

## Commit 信息格式

| 类型 | 用途 |
|------|------|
| `feat:` | 新功能、新 skill |
| `fix:` | 修 bug |
| `docs:` | 文档改动 |
| `refactor:` | 重构，不改功能 |
| `chore:` | 杂务、配置、版本号 |

## 发布新版本

1. 确认 `git status`。
2. 修改 `.claude-plugin/plugin.json` 和 `skills.sh.json` 的版本号。
3. 确认 `README.md` / `README.zh-CN.md` 的安装说明同步。
4. 本地校验插件和每个 skill 目录。
5. 提交、推送、打 tag。

```bash
git tag -a vX.Y.Z -m "GroundPA Toolkit vX.Y.Z"
git push origin vX.Y.Z
```

## 注意事项

1. 不要把未实现或 E005/E009 门控能力写成稳定可用。
2. 不要让 skill 默认生成临时 .NET 项目调用旧 NuGet 包。
3. Nong-facing skill 优先使用 `--json`。
4. 生成物路径以 JSON 的 `artifacts` 字段为准。
5. 不要提交 `bin/`、`obj/`、`.zip`、`.nupkg`。
6. `word add paragraph/table/...` 是 canonical；`word add-*` 只能作为兼容 alias 提及。
7. OCR token 只写 `PADDLEOCR_ACCESS_TOKEN`，不要写命令行 token 选项或旧 token 示例。

## 本地验收

```powershell
$repo = (Get-Location).Path
$inventory = nong skill inventory $repo --json | ConvertFrom-Json
foreach ($skill in $inventory.data.skills) {
  nong skill validate $skill.path --json
}
nong skill scan $repo --json
nong skill package $repo --json
```

`nong skill validate` 接收单个 skill 目录，不要把插件根目录当作单个 skill 去 validate。`skill package` 会生成 zip；除非发布需要，验收后不要把 zip 留在 git 状态里。
