# GroundPA Toolkit — 土地公的工具箱

OpenXML 底层直控、.NET 原生执行的 Claude Code 技能插件集。15 个技能覆盖 Office 文档生成、Shell 脚本、.NET 开发、GitHub 操作和技能生命周期管理——全部通过确定性 NuGet 包和 CLI 工具执行。

## 设计哲学

模型容量留给语义工作——挖掘、综述、写作。确定性工作（校验、扫描、打包、生成、渲染）以 NuGet 包发布。Skill 文件夹分发时只读，所有运行时数据统一放在工作区目录下。

## 技能目录

### Office 与文档生成

| 技能 | 做什么 | NuGet 包 |
|------|--------|----------|
| **word** | 学术论文、毕业论文、课题报告：三线表、公式编号、目录、模板引擎 | `Angri450.Nong.Docx` |
| **pptx** | 答辩 PPT、研究汇报、讲座 slides：10 套主题、流式 SlideBuilder | `Angri450.Nong.Pptx` |
| **excel** | 表格、财务模型、仪表盘：公式、数据验证、条件格式 | `Angri450.Nong.Excel` |
| **chart** | ANOVA、Duncan MRT、带显著性标注的论文级柱形图 | `Angri450.Nong.Chart` |
| **diagram** | 流程图(Sugiyama)、网络图(力导向)、系统发育树(Newick)、生物图标库 | `Angri450.Nong.Diagram` |
| **multimodal** | OCR(PaddleOCR-VL 云端 + 本地 CPU)、文档转 Markdown、文档转 Word | `Angri450.Nong.MultiModal` |

### Shell 脚本

| 技能 | 做什么 |
|------|--------|
| **bash** | 引用、数组、`set -e`、trap、Git 安全协议、沙箱安全模式 |
| **powershell** | PS 7+：Cmdlet、模块、Pester、PSScriptAnalyzer、凭据安全 |

### 开发者工具

| 技能 | 做什么 |
|------|--------|
| **dotnet** | C#、MSBuild、ASP.NET Core、EF Core、MAUI、性能诊断 |
| **github** | git + gh CLI：提交、PR、Issue、Release |
| **ghproxy** | GitHub 链接加速代理，受限网络环境可用 |
| **nuget** | 包管理：安装、更新、打包、发布 |
| **ilspycmd** | .NET 程序集反编译为 C# 源码：查看 DLL 内部实现、提取 API 接口 |

### 通信与元技能

| 技能 | 做什么 | NuGet 包 |
|------|--------|----------|
| **email** | ClawEmail 收发：收件箱、转发、搜索、附件 | — |
| **skill-manager** | 校验、扫描、打包、评测、脚手架——技能全生命周期 CLI | `Angri450.Nong.Skill.Manager` |

## 工作区

所有运行时数据统一放在一棵目录树下：

```
~/Documents/GroundPA Toolkit Workplace/
├── word/DocxWriter/          # Word 工程
├── pptx/PptxWriter/          # PPT 工程
├── excel/ExcelWriter/        # Excel 工程
├── chart/ChartWriter/        # Chart 工程
├── diagram/DiagramWriter/    # Diagram 工程
├── multimodal/OcrTask/       # OCR 工程
├── skill-manager/            # 评测、会话记录、编译产物
└── output/                   # 生成文件
    └── <时间>+<项目>+<序号>/
```

每次会话只修改对应工作区的 `Program.cs`。输出自动落入带时间戳的子目录。

## 快速安装

```bash
git clone https://github.com/angri450/GroundPA-Toolkit.git
cp -r GroundPA-Toolkit/* ~/.claude/skills/
dotnet tool install --global Angri450.Nong.Skill.Manager
```

需要 .NET SDK。不设版本下限。

## 核心架构

Skill 文件夹分发时只读。确定性工作通过 NuGet 包（`Angri450.Nong.*`）执行。skill-manager 全局工具负责校验、安全扫描、打包和评测。渐进式披露原则保持 SKILL.md 精简——详细参考资料放在 `references/` 中。

完整约定见 [`skill-manager/SKILL.md`](skill-manager/SKILL.md)。

## 开源协议

Apache-2.0
