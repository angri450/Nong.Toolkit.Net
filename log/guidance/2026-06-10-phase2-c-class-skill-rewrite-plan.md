# 2026-06-10 Toolkit C 类 Skill 重写详细方案

## 背景

2026-06-10 Toolkit 全量 Skill 系统审计（`log/reports/toolkit-skill-system-audit.html`）识别出 4 个 C 类 skill（现在真不好用）：`multimodal`、`skill-manager`、`progress-report`、`icons`。Skill/CLI/Package 映射审计（`log/reports/toolkit-skill-cli-package-map.html`）进一步确认了命名漂移问题。

## 总原则

1. **Skill 和 CLI 命令组尽量同名**。如果 CLI 叫 `ocr`，skill 就叫 `ocr`。
2. **执行入口和治理规则分开**。主 SKILL.md 只做分流，细节放 references。
3. **每个 skill 至少 1 份 reference**（边界说明或深层路由）。
4. **每个 skill 至少 1 个成功例子**。
5. **C 类优先**：先修这 4 个，A/B 类在阶段三处理。

## Skill 1: multimodal → ocr

### 问题诊断

- **名字太泛**：`multimodal` 像是图像、多模态、OCR 全能入口。实际只教 `nong ocr` 命令组。
- **CLI 命令组名叫 `ocr`**，skill 名叫 `multimodal`，AI 看到 OCR 需求时不容易触发对的 skill。
- **下层其实已经拆好了**：`multimodal/references/ocr-local.md`、`ocr-cloud.md`、`image-analyzer.md` 三份 reference 都在。问题是外层 skill 名没把这三条路串成一根主轴。
- **OCR runtime 仓库链路没写清楚**：用户装不上 OCR 时不知道去 `Nong.OcrRuntime` 仓库排查。

### 改法

**目录操作**：
1. `multimodal/` → 改名为 `ocr/`（或新增 `ocr/` 目录，保留 `multimodal/` 作为软链接/兼容入口）
2. 已有的三个 reference 文件保留，补充 `ocr/references/runtime-chain.md`（OCR runtime 仓库链路说明）

**SKILL.md 重写要点**：
```
# ocr

OCR 文字识别和图像结构分析。

触发：OCR、PaddleOCR、扫描件、图片文字识别、图像结构分析。

路由：
- 本地 OCR → nong ocr local（纯 .NET PP-OCRv5，单图文字识别）
- 云端 OCR → nong ocr cloud（PaddleOCR-VL，文档版面理解）
- 图像分析 → nong ocr analyze-image（纯 .NET 图像结构 QA）
- OCR 转 Word → nong ocr to-word（云 OCR 路径）
- 环境检查 → nong ocr check-env
- 模型安装 → nong ocr install-model

不做什么：
- 不做 PDF 全文档 OCR（PDF 路由走 pdf skill 的 dissect --mode ocr）
- 不承诺版面分析和表格重建（那是 cloud OCR 的能力，local 不提供）
```

**references/ 结构调整**：
```
ocr/
  SKILL.md
  references/
    ocr-local.md（已有，内容保留）
    ocr-cloud.md（已有，内容保留）
    image-analyzer.md（已有，内容保留）
    runtime-chain.md（新增）
  examples/
    local-ocr-success.md（新增）
    cloud-ocr-no-token.md（新增，失败场景）
```

**runtime-chain.md 内容大纲**：
- OCR 仓库链路：`ocr skill → nong ocr CLI → Angri450.Nong.MultiModal 核心包 → Nong.OcrRuntime 仓库 → Angri450.Nong.OcrRuntime.* 五个平台运行时包`
- 安装失败时该看哪个仓库
- 本地 OCR 需要哪些 NuGet 包（Sdcb.PaddleOCR、Sdcb.PaddleOCR.Models.Local、Angri450.Nong.OcrRuntime.*）
- 环境变量：PADDLEOCR_ACCESS_TOKEN（云 OCR）

### 验证

```powershell
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill validate .\ocr --json
```

## Skill 2: skill-manager

### 问题诊断

- **像万能收发室**：名字 "skill-manager" 太广，描述也太宽，AI 会把所有"跟 skill 有点关系"的请求都路由到这里。
- **0 references，0 examples**：只有一个主 SKILL.md，AI 触发之后没有下钻材料。
- **职责混杂**：同时承担创建策略、编辑规范、触发质量审计、安全扫描解读、打包闸门说明、失败反馈回收。
- **它不是 CLI 镜像**：CLI 有 `nong skill validate/scan/inventory/package` 四个确定性命令，但 skill-manager 是策略层 skill，不是 `nong skill` 的镜像。

### 改法

**SKILL.md 重写要点**：
```
# skill-manager

创建、维护和审计 Skill 的策略与规范。

触发：创建 skill、编辑 skill、修 skill、合并 skill、拆分 skill、废弃 skill、
跑 evals、benchmark、审计 skill 质量、优化 skill 描述。

路由：
- 创建 skill → 看 references/authoring.md
- 审计 skill → 看 references/trigger-audit.md
- 反馈回收 → 看 references/feedback-loop.md
- 打包发布 → 用 nong skill validate/scan/inventory/package（确定性 gate）

不做什么：
- 不绕过 nong skill 命令行做打包（打包闸门是 CLI 的责任）
- 不代替 word/pdf/ocr 等执行 skill（那些是 CLI 镜像 skill）
```

**references/ 结构调整**：
```
skill-manager/
  SKILL.md
  references/
    authoring.md（新增：SKILL.md 怎么写、reference 怎么拆、命名怎么定）
    trigger-audit.md（新增：怎么检查 skill 的触发精度、description 够不够准）
    feedback-loop.md（新增：失败怎么回收到 reference 和 example）
  examples/
    create-skill-success.md（新增：从头创建一个简单 skill）
    fix-trigger-too-wide.md（新增：修一个触发过宽的 skill）
    broken-feedback-to-reference.md（新增：把一次真实失败回收为 skill 边界）
```

**authoring.md 内容大纲**：
- SKILL.md 模板（名字、触发词、路由表、不做的事）
- 什么时候用 references/（超过 30 行就拆分）
- 什么时候用 examples/（每个 skill 至少 1 个成功例子）
- 命名规则（CLI 镜像用命令组名，策略 skill 用角色名）
- 和 `nong skill` 的关系（validate 是闸门，skill-manager 是策略）

**feedback-loop.md 内容大纲**：
- 怎么从 log/debug/ 提取失败模式
- 怎么把失败模式写成 reference 里的边界说明
- 怎么把失败模式写成 example 里的失败例子
- 什么时候该考虑改 SKILL.md 的触发词

### 验证

```powershell
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill validate .\skill-manager --json
```

## Skill 3: progress-report

### 问题诊断

- **0 references，0 examples**：只有一个主文件，AI 触发后没路走。
- **治理和执行混写**：同时承担日志结构说明（技术规范）和"旧工具别再乱放"（治理口径）。
- **和 CLI 对应关系不够直白**：`nong progress report` 的输入、输出、参数没写在 skill 里。

### 改法

**SKILL.md 重写要点**：
```
# progress-report

项目进度报告生成。

触发：进度报告、changelog、施工记录、项目日志报告、进度总结。

路由：
- 生成报告 → nong progress report --project-root . --json
- 日志结构 → 看 references/log-structure.md
- 报告模板 → 看 references/report-templates.md

不做什么：
- 不做实时任务进度条（那是任务管理工具的事）
- 不做 Git commit 统计（只看 log/ 目录）
```

**references/ 结构调整**：
```
progress-report/
  SKILL.md
  references/
    log-structure.md（新增：log/ 目录的标准结构）
    report-templates.md（新增：报告输出格式说明）
  examples/
    generate-report-success.md（新增）
```

### 验证

```powershell
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill validate .\progress-report --json
```

## Skill 4: icons

### 问题诊断

- **太薄**：只有主文件，像命令速查表，不像可判断边界的 skill。
- **名字容易误触发**：`icons` 会让 AI 联想到通用图标设计、AI 生成图标，实际只做 Bioicons 科学图标检索。
- **0 references，0 examples**。

### 改法

**决定**：不改目录名（`icons` 作为 skill 名是可接受的），但必须在 SKILL.md 和 reference 里写清楚边界。

**SKILL.md 重写要点**：
```
# icons

科学图标发现和检索（Bioicons）。

触发：bioicons、科学图标、实验器材图标、生物图标、化学图标、图标列表、图标搜索。

路由：
- 浏览图标 → nong icons list
- 搜索图标 → nong icons search <keyword>

不做什么：
- 不做通用图标设计或 AI 生成图标
- 不做非科学类图标检索
- 图标作为资产嵌入图表/示意图，走 diagram skill 路由
```

**references/ 结构调整**：
```
icons/
  SKILL.md
  references/
    scope-and-limits.md（新增：Bioicons 的范围、支持哪些类别、不支持什么）
  examples/
    search-success.md（新增）
    search-no-result.md（新增，失败场景）
```

### 验证

```powershell
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill validate .\icons --json
```

## 改动文件清单

| Skill | 操作 | 文件 |
|-------|------|------|
| multimodal→ocr | 改名 | `multimodal/` → `ocr/`，更新所有内部引用 |
| ocr | 重写 | `ocr/SKILL.md` |
| ocr | 新增 | `ocr/references/runtime-chain.md` |
| ocr | 新增 | `ocr/examples/local-ocr-success.md` |
| ocr | 新增 | `ocr/examples/cloud-ocr-no-token.md` |
| skill-manager | 重写 | `skill-manager/SKILL.md` |
| skill-manager | 新增 | `skill-manager/references/authoring.md` |
| skill-manager | 新增 | `skill-manager/references/trigger-audit.md` |
| skill-manager | 新增 | `skill-manager/references/feedback-loop.md` |
| skill-manager | 新增 | `skill-manager/examples/create-skill-success.md` |
| skill-manager | 新增 | `skill-manager/examples/fix-trigger-too-wide.md` |
| skill-manager | 新增 | `skill-manager/examples/broken-feedback-to-reference.md` |
| progress-report | 重写 | `progress-report/SKILL.md` |
| progress-report | 新增 | `progress-report/references/log-structure.md` |
| progress-report | 新增 | `progress-report/references/report-templates.md` |
| progress-report | 新增 | `progress-report/examples/generate-report-success.md` |
| icons | 重写 | `icons/SKILL.md` |
| icons | 新增 | `icons/references/scope-and-limits.md` |
| icons | 新增 | `icons/examples/search-success.md` |
| icons | 新增 | `icons/examples/search-no-result.md` |

## 同步改动

- `skills.sh.json`：更新 skill 列表（multimodal → ocr）
- `.claude-plugin/plugin.json`：更新 skill 注册
- `.claude-plugin/marketplace.json`：更新 skill 列表
- `README.md` + `README.zh-CN.md`：更新 skill 数量和分类
- `CLAUDE.md`：更新 skill 边界说明

## 验证步骤

```powershell
# 逐个验证改动后的 skill
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill validate .\ocr --json
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill validate .\skill-manager --json
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill validate .\progress-report --json
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill validate .\icons --json

# 全量 inventory
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill inventory . --json

# 安全扫描
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill scan . --json

# 打包
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill package . --json
```

## 风险

- **multimodal→ocr 改名**：如果 `.claude-plugin/` 或外部有路径引用 `multimodal/`，需要同步改。建议先做文件内容搜索确认所有引用。
- **旧 skill 兼容**：如果用户本地已经装了旧 `multimodal` skill，改名不会自动清理。需要在 README 里写迁移说明。
- **其他 11 个 A/B 类 skill 不动**：避免一次改动面太大，出问题时不好定位。

## 时间估算

2-3 小时。ocr 改名+重写 45min + skill-manager 重写+3 份 reference 45min + progress-report 重写+2 份 reference 30min + icons 重写+1 份 reference 20min + manifest 同步 15min + validate/scan/package 验证 15min。

## 和 CLI 的依赖

- 不依赖 CLI 改动（这些是纯 skill 层改动）。
- 但 CLI 的 P1 alias 做完后，inspect skill 的教学口径需要同步更新（已在 CLI guidance 中标注）。

## 状态

plan — **DONE**。2026-06-10 已完工。4 个 C 类 skill 全部重写：multimodal→ocr、skill-manager、progress-report、icons。每个 skill 均有 references + examples。15 skill validate 全部通过，scan 0 findings，package 成功。
