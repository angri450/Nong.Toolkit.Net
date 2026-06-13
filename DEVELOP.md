# 开发说明

## 当前状态

- 仓库：`https://github.com/angri450/GroundPA-Toolkit`
- 本地：`<repo-root>`
- 版本：v2.2.1
- 架构：Nong CLI-first skill layer

## 2.2.1 边界

只把当前 `nong commands --json` 中标记为 `implemented` 的能力做成 skill。

已暴露：

```text
word, pdf, inspect, excel, chart, diagram, genre, icons
pptx, multimodal
bash, powershell, dotnet, github, gitee, ghproxy, nuget, ilspycmd, email, skill-manager
```

门控暴露：

```text
pdf: 暴露 check/dissect/render/images；主输出是 `content.nongmark`，plain Markdown 只当预览；本地 OCR 模式只做文字识别，不承诺云端级版面、表格或跨页重建。
ocr local: 入口存在，经 Nong 的纯 .NET PP-OCRv5 runtime 执行；只有 `check-env` 报 localDotNetPpOcrV5.status=ok 且真实图片 smoke test EXIT:0 后才能作为稳定 OCR 路径推荐。
ocr install-model: 安装/检查当前平台第一方 `Angri450.Nong.OcrRuntime.*` PP-OCRv5 native runtime 缓存；默认走华为 NuGet v3；`--dry-run` 给部署计划，不安装 Python；上游 fallback 必须显式 `--allow-upstream-fallback`。
ocr cloud / ocr to-word: 需要来自 https://aistudio.baidu.com/account/accessToken 的 PADDLEOCR_ACCESS_TOKEN。
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

1. 不要把未实现、未安装、或未通过环境预检的能力写成稳定可用。
2. 不要让 skill 默认生成临时 .NET 项目调用旧 NuGet 包。
3. Nong-facing skill 优先使用 `--json`。
4. 生成物路径以 JSON 的 `artifacts` 字段为准。
5. 不要提交 `bin/`、`obj/`、`.zip`、`.nupkg`。
6. `word add paragraph/table/...` 是 canonical；`word add-*` 只能作为兼容 alias 提及。
7. OCR token 只写 `PADDLEOCR_ACCESS_TOKEN`，可给出 AI Studio AccessToken 页面，不要写命令行 token 选项或旧 token 示例。

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
