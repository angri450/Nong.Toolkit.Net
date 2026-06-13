# Nong.Toolkit.Net

Nong.Toolkit.Net 是一个 Claude Code 多 skill 插件，面向农学论文和文档工作流。

插件提供一组聚焦的 skills：Word、PDF、文献检索、Excel、统计图、流程图、PPTX 读取、OCR/图像检查、格式模板、Bioicons 和论文诊断。确定性的文档和文献处理统一交给纯 .NET `nong` CLI（来自 [Nong.Cli.Net](https://github.com/angri450/Nong.Cli.Net)）；模型负责判断流程、解释结果和写作。

## 安装

通过 Claude Code plugin marketplace 安装：

```bash
claude plugin marketplace add https://gitcode.com/angri450/Nong.Toolkit.Net.git
claude plugin install nong-toolkit@angri450
```

GitHub 源：

```bash
claude plugin marketplace add angri450/Nong.Toolkit.Net
claude plugin install nong-toolkit@angri450
```

安装后重启 Claude Code，或执行 `/reload-plugins`。

插件只安装 skills。必需的 Nong CLI 需要单独安装或更新：

```powershell
dotnet tool install --global Angri450.Nong.Cli --add-source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json
```

如果已经安装：

```powershell
dotnet tool update --global Angri450.Nong.Cli --add-source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json
```

使用前先确认命令面：

```powershell
nong commands --json
```

Nong.Toolkit.Net 2.4.0 面向 Nong 4.0.0+ 的 93 个命令面。

## Skills

| Skill | 用途 |
|-------|------|
| `word` | DOC/DOCX 检查、转换交接、切片、版式证据、修复、填充、编辑、校验、合并、批注、图片、字体和保护 |
| `pdf` | PDF 检查、本地切片、`content.nongmark`、页面渲染、内嵌图片提取，以及文本/扫描路由 |
| `literature` | 类 CNKI 检索 DSL、OpenAlex/Crossref/Unpaywall 元数据和开放获取查询、本地过滤排序，以及 JSON/Markdown/BibTeX 导出 |
| `inspect` | 农学生论文诊断、参考文献、结构、证据、数据需求、差距分析和写作支持 |
| `excel` | 工作簿读取、sheet 清单、分组数据提取和工作簿创建 |
| `chart` | 统计和图表流程：analyze、ANOVA、Duncan、柱状图、折线图、散点图和饼图 |
| `diagram` | 通过 Nong 生成流程图、网络图和树图 |
| `pptx` | PPTX 读取和幻灯片清单 |
| `ocr` | OCR 环境检查、图像结构 QA、云端 OCR、图片/PDF 转 Word、OCR 模型清单和受控本地 OCR |
| `genre` | 论文体裁列表和体裁写作指导 |
| `icons` | Bioicons 列表和搜索 |
| `slice` | NongPandoc 包检查、严格证据检查、block 读取和资源清单 |
| `skill` | `nong skill validate/scan/inventory/package` 生命周期闸门 |
| `skill-manager` | Skill 设计、维护、触发质量和旧工作流迁移 |
| `progress-report` | 结构化日志摘要和 HTML 进展报告指导 |

开发态和旧材料本地保存在仓库外的 `../Nong.Toolkit_archive/`；如果误拷回仓库，也会被 Git 忽略。开发过程记录保留在 `log/`，需要提交。

## 常用命令

Word：

```powershell
nong word check paper.docx --json
nong word dissect paper.docx --output paper.slice --json
nong word fonts paper.docx --json
nong word styles paper.docx --json
nong word validate paper.docx --json
```

PDF：

```powershell
nong pdf check guide.pdf --json
nong pdf dissect guide.pdf --output guide.slice --mode auto --json
nong pdf render guide.pdf --output guide.pages --dpi 150 --json
nong pdf images guide.pdf --output guide.assets --json
```

文献检索：

```powershell
nong lit validate --query "SU=('腐植酸'+'腐殖酸')*('稀土'+'微肥')" --json
nong lit plan --query "SU=('腐植酸'+'腐殖酸')*('稀土'+'微肥')" --sources openalex,crossref,unpaywall --json
nong lit search --query "DOI='10.1016/j.chemgeo.2007.05.018'" --sources openalex,crossref,unpaywall --limit 20 --profile balanced --out refs.json --json
nong lit export --input refs.json --format bibtex --out refs.bib --json
```

Stage19 文献提供方只包括 OpenAlex、Crossref 和 Unpaywall。Unpaywall 需要 `NONG_LIT_UNPAYWALL_EMAIL` 或 `NONG_LIT_MAILTO`；OpenAlex 可使用 `NONG_LIT_OPENALEX_API_KEY` 或 `NONG_LIT_OPENALEX_KEY`；Crossref 可使用 `NONG_LIT_MAILTO`。全文检索、爬虫、绕过付费墙、Semantic Scholar、PubMed、PMC、arXiv、万方和自动中英同义词扩展都未实现。

Excel、统计图和图示：

```powershell
nong excel sheets data.xlsx --json
nong excel to-groups data.xlsx --group Treatment --value Yield --raw
nong chart analyze groups.json --json
nong chart bar groups.json -o fig.png --json
nong diagram flowchart flow.json -o flow.png --json
```

PPTX 和 OCR：

```powershell
nong pptx read deck.pptx --json
nong pptx slides deck.pptx --json
nong ocr check-env --json
nong ocr analyze-image fig.png -o fig.analysis --json
nong ocr cloud scan.png -o ocr-out --json
nong ocr to-word scan.png -o out.docx --json
```

`ocr cloud` 和 `ocr to-word` 需要 `PADDLEOCR_ACCESS_TOKEN`。Token 页面是 `https://aistudio.baidu.com/account/accessToken`。

## 开发边界

这个仓库按可安装的 Claude Code plugin 组织。可安装插件面是：

```text
.claude-plugin/
word/ pdf/ literature/ inspect/ excel/ chart/ diagram/ pptx/ ocr/ genre/ icons/
slice/ skill/ skill-manager/ progress-report/
README.md README.zh-CN.md skill.zh skills.sh.json LICENSE
```

Git 提交面还保留 `log/`，用于展示开发过程。`nong skill package` 打包可安装插件面，`log/` 保留在仓库中。

生成输出、旧实验、本地 Claude/Codex 规则、打包产物和构建临时文件不要进入这两个面。需要本地保留时，挪到仓库外的 `../Nong.Toolkit_archive/`，不要放在仓库内 `_archive/`。

## 校验

校验插件：

```bash
claude plugin validate .
```

查看 Nong-facing skills：

```powershell
nong skill inventory . --json
```

校验单个 skill：

```powershell
nong skill validate .\word --json
```

## 开源协议

Apache-2.0
