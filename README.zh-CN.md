# GroundPA Toolkit — 土地公的工具箱

GroundPA Toolkit 2.1.0 是面向农学生论文和文档工作流的 Claude Code skill 集。核心变化是：skill 层不再让模型临时写 .NET 小项目，而是统一调用 `nong` CLI。

模型负责判断任务、准备 JSON/spec、解释诊断结果。确定性工作交给 .NET CLI。

## 基础工具

```powershell
dotnet tool install --global Angri450.Nong.Cli
nong commands --json
```

Nong 同时提供 skill 生命周期主工具：

```powershell
nong skill inventory . --json
nong skill scan . --json
nong skill package . --json
```

## 2.1.0 暴露的 Nong Skills

只暴露当前 `nong` CLI 已实现的命令。

| Skill | 已实现命令 |
|-------|------------|
| `word` | read, preview, fill, rebuild, extract, dissect, stats, fonts, styles, validate, merge, outline, images, comments, revisions, infer-format, fix-order, protect, embed-font, add paragraph/table/footnote/endnote/image/toc/xref/link/bookmark/comment/math |
| `inspect` | diagnose, refs, write-paper, classify, structure, varplan, evidence, data-req, gap, semantics |
| `excel` | sheets, read, to-groups, create |
| `chart` | analyze, anova, duncan, bar, line, scatter, pie |
| `diagram` | flowchart, network, tree |
| `pptx` | read, slides |
| `multimodal` | ocr check-env, analyze-image, cloud, to-word, models, install-model, gated local |
| `genre` | `genre list`, `genre show` |
| `icons` | `icons list`, `icons search` |

## 其他 Skills

| Skill | 用途 |
|-------|------|
| `bash` | Bash 引用、数组、错误处理、沙箱安全模式 |
| `powershell` | PowerShell cmdlet、模块、错误处理、凭据安全 |
| `dotnet` | C#、MSBuild、ASP.NET Core、EF Core、MAUI、诊断、NuGet |
| `github` | `git` 和 `gh` CLI 工作流 |
| `gitee` | Gitee 与 Gitee MCP 工作流 |
| `ghproxy` | GitHub 链接加速 |
| `nuget` | 包安装、打包、发布 |
| `ilspycmd` | .NET 程序集反编译 |
| `email` | ClawEmail mail-cli 工作流 |
| `skill-manager` | meta-skill 维护、评测资料和 legacy skill-manager 工作流 |

## 常用流程

### Word

```powershell
nong word read paper.docx --json
nong word preview paper.docx --json
nong word dissect paper.docx --output paper.slice --json
nong word fill template.docx data.json -o out.docx --json
nong word rebuild dirty.docx -o clean.docx --json
nong word add paragraph paper.docx --spec paragraph.json -o out.docx --json
```

### 论文诊断

```powershell
nong inspect diagnose paper.txt --json
nong inspect refs paper.txt --json
nong inspect write-paper spec.json -o paper.docx --json
nong inspect classify paper.txt --json
nong inspect evidence paper.txt --json
```

### Excel 到统计图

```powershell
nong excel to-groups data.xlsx --group Treatment --value Yield --raw > groups.json
nong excel create workbook.json -o workbook.xlsx --json
nong chart analyze groups.json --json
nong chart bar groups.json -o fig.png --json
nong chart line line.json -o line.png --json
nong chart scatter scatter.json -o scatter.png --json
nong chart pie pie.json -o pie.png --json
```

### 图示

```powershell
nong diagram flowchart flow.json -o flow.png --json
nong diagram network network.json -o network.png --json
nong diagram tree tree.nwk -o tree.png --json
```

### PPTX

```powershell
nong pptx read deck.pptx --json
nong pptx slides deck.pptx --json
```

### OCR 与图像验收

```powershell
nong ocr check-env --json
nong ocr analyze-image fig.png -o fig.analysis --json
nong ocr cloud scan.png -o ocr-out --json
nong ocr to-word scan.png -o out.docx --json
```

`ocr cloud` 和 `ocr to-word` 需要 `PADDLEOCR_ACCESS_TOKEN`。`ocr analyze-image` 做图像结构和版面检查，不识别文本。`ocr local` 是受环境门控的本地路径，模型路径未安装或推理未就绪时可能返回 E005/E009。

## 安装

### Skills 安装（推荐，无需 Git 登录，无需 SSH Key）

这是**经典的 Claude Code Skills 安装方式**：git clone 整个仓库，复制到 `~/.claude/skills/`。不走 Claude Code plugin marketplace 机制，不需要后台 clone，不会触发 Gitee 交互式登录。

**GitCode（推荐，匿名 clone，国内快）**

```bash
git clone https://gitcode.com/angri450/GroundPA-Toolkit.git /tmp/groundpa && mkdir -p ~/.claude/skills && cp -r /tmp/groundpa/. ~/.claude/skills/ && rm -rf /tmp/groundpa && dotnet tool install --global Angri450.Nong.Cli
```

**Gitee**

```bash
git clone https://gitee.com/angri450/GroundPA-Toolkit.git /tmp/groundpa && mkdir -p ~/.claude/skills && cp -r /tmp/groundpa/. ~/.claude/skills/ && rm -rf /tmp/groundpa && dotnet tool install --global Angri450.Nong.Cli
```

**GitHub（海外）**

```bash
git clone https://github.com/angri450/GroundPA-Toolkit.git /tmp/groundpa && mkdir -p ~/.claude/skills && cp -r /tmp/groundpa/. ~/.claude/skills/ && rm -rf /tmp/groundpa && dotnet tool install --global Angri450.Nong.Cli
```

安装后执行 `/reload-plugins` 或重启 Claude Code。

### Plugin Marketplace 安装（实验性）

这个方式通过 Claude Code plugin marketplace 机制安装。要求 Claude Code 在后台成功 clone 仓库，Gitee HTTPS 可能触发认证弹窗导致失败。

```bash
claude plugin marketplace add https://gitcode.com/angri450/GroundPA-Toolkit.git
claude plugin install groundpa-toolkit@angri450
/reload-plugins
```

GitHub 备用：

```bash
claude plugin marketplace add angri450/GroundPA-Toolkit
claude plugin install groundpa-toolkit@angri450
/reload-plugins
```

### 必装 .NET 工具

```powershell
dotnet tool install --global Angri450.Nong.Cli
```

如果已经安装：

```powershell
dotnet tool update --global Angri450.Nong.Cli
```

## 更新

Skills 安装方式：重新 clone 覆盖即可。

```bash
git clone https://gitcode.com/angri450/GroundPA-Toolkit.git /tmp/groundpa && cp -r /tmp/groundpa/. ~/.claude/skills/ && rm -rf /tmp/groundpa
```

Plugin Marketplace 方式：

```bash
claude plugin marketplace update angri450
claude plugin update groundpa-toolkit@angri450
/reload-plugins
```

## 工作区

运行时输出建议统一放在：

```text
$HOME/Documents/GroundPA Toolkit Workplace/output/
```

agent 调用 `nong` 时优先使用绝对路径。生成文件以后读取 JSON 里的 `artifacts` 字段。

## 契约

所有 Nong-facing skills 都遵守同一规则：

1. 先用 `nong commands --json` 看可用命令。
2. 只调用 `implemented` 命令。
3. 面向模型判断时优先加 `--json`。
4. `status: "error"` 一律视为失败。
5. 下一步行动前读取 `errors[0].code`、`errors[0].message` 和 `artifacts`。

## 开源协议

Apache-2.0
