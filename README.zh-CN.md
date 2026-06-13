# Nong.Toolkit.Net

Nong.Toolkit.Net 是一个 Claude Code 多 plugin marketplace，面向农学论文和文档工作流。17 个 plugin——1 个全量包 + 16 个独立 skill，按需安装。

确定性的文档和文献处理统一交给纯 .NET `nong` CLI（来自 [Nong.Cli.Net](https://github.com/angri450/Nong.Cli.Net)）；模型负责判断流程、解释结果和写作。

## 安装

### 全量安装

```bash
claude plugin marketplace add https://gitcode.com/angri450/Nong.Toolkit.Net.git
claude plugin install nong-toolkit@nong-toolkit
```

### 按需安装单个 skill（更低 token 成本）

```bash
claude plugin marketplace add https://gitcode.com/angri450/Nong.Toolkit.Net.git
claude plugin install word@nong-toolkit          # ~78 tok 常驻
claude plugin install pdf@nong-toolkit
claude plugin install chart@nong-toolkit
# ... 按需组合
```

GitHub 源：

```bash
claude plugin marketplace add angri450/Nong.Toolkit.Net
claude plugin install word@nong-toolkit
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

Nong.Toolkit.Net 2.5.0 面向 Nong 4.1.0+。

## Skills

| Skill | 用途 | Plugin id |
|-------|------|-----------|
| `word` | DOC/DOCX 检查、转换交接、切片、版式证据、修复、填充、编辑、校验、合并、批注、图片、字体和保护 | `word@nong-toolkit` |
| `pdf` | PDF 检查、本地切片、`content.nongmark`、页面渲染、内嵌图片提取、文本/扫描路由、合并、分割、OCR | `pdf@nong-toolkit` |
| `literature` | 类 CNKI 检索 DSL、OpenAlex/Crossref/Unpaywall 元数据和开放获取查询、本地过滤排序，以及 JSON/Markdown/BibTeX 导出 | `literature@nong-toolkit` |
| `inspect` | 农学生论文诊断、参考文献、结构、证据、数据需求、差距分析和写作支持 | `inspect@nong-toolkit` |
| `excel` | 工作簿读取、sheet 清单、分组数据提取、工作簿创建、单元格样式、公式、数据透视表 | `excel@nong-toolkit` |
| `chart` | 统计和图表流程：analyze、ANOVA、Duncan、柱状图、折线图、散点图、饼图、箱线图、直方图、热力图、雷达图 | `chart@nong-toolkit` |
| `diagram` | 通过 Nong 生成流程图、网络图和树图 | `diagram@nong-toolkit` |
| `pptx` | PPTX 读取、幻灯片清单、PPTX 创建 | `pptx@nong-toolkit` |
| `ocr` | OCR 环境检查、图像结构 QA、云端 OCR、图片/PDF 转 Word、OCR 模型清单、受控本地 OCR | `ocr@nong-toolkit` |
| `genre` | 论文体裁列表和体裁写作指导 | `genre@nong-toolkit` |
| `icons` | Bioicons 列表和搜索 | `icons@nong-toolkit` |
| `slice` | NongPandoc 包检查、严格证据检查、block 读取和资源清单 | `slice@nong-toolkit` |
| `skill-grader` | `nong skill` 校验、扫描、清单和打包（入库） | `skill-grader@nong-toolkit` |
| `skill-breeder` | Skill 育种：模板、命名规范、结构约定 | `skill-breeder@nong-toolkit` |
| `skill-tester` | Skill 验种：触发精度检查、失败反馈回收 | `skill-tester@nong-toolkit` |
| `skill-pruner` | Skill 修剪：合并、拆分、废弃 | `skill-pruner@nong-toolkit` |

开发态和旧材料本地保存在仓库外的 `../Nong.Toolkit_archive/`。开发过程记录保留在 `log/`。

## 常用命令

Word：

```powershell
nong word check paper.docx --json
nong word dissect paper.docx --output paper.slice --json
nong word fonts paper.docx --json
nong word styles paper.docx --json
nong word validate paper.docx --json
# 文档紧缩管线
nong word estimate paper.docx --json           # 页面空白分析
nong word crop paper.docx -o cropped.docx      # 图片去白边
nong word fit-images paper.docx -o fit.docx    # 图片并排
nong word compact-tables paper.docx -o out.docx # 表格紧缩
nong word page-setup paper.docx --size A4 --margin-top 25 -o out.docx
nong word indent paper.docx --role body --first-line 7.4 -o out.docx
nong word paragraph-control paper.docx --role heading --keep-next true -o out.docx
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
nong ocr local scan.png --json
nong ocr to-word scan.png -o out.docx --json
nong ocr batch ./scans/ --pattern "*.png" --json
nong ocr video demo.mp4 -o subtitles.srt --json
nong ocr screen --x 0 --y 0 --w 800 --h 600 --json
```

`ocr cloud` 和 `ocr to-word` 需要 `PADDLEOCR_ACCESS_TOKEN`。Token 页面是 `https://aistudio.baidu.com/account/accessToken`。`ocr local` 使用 PP-OCRv6 纯 .NET 原生运行时。`ocr batch` 批量处理目录。`ocr video` 用 dHash 帧去重提取视频帧并输出 SRT 字幕。`ocr screen` 捕获 Windows 屏幕区域。

## 开发边界

这个仓库按 Claude Code 多 plugin marketplace 组织。每个 skill 目录有自己的 `.claude-plugin/plugin.json`。可安装插件面是：

```text
.claude-plugin/
word/ pdf/ literature/ inspect/ excel/ chart/ diagram/ pptx/ ocr/ genre/ icons/
slice/ skill-grader/ skill-breeder/ skill-tester/ skill-pruner/
README.md README.zh-CN.md skill.zh skills.sh.json LICENSE
```

Git 提交面还保留 `log/`，用于展示开发过程。

生成输出、旧实验、本地规则、打包产物和构建临时文件不要进入这两个面。需要本地保留时，挪到仓库外的 `../Nong.Toolkit_archive/`。

## 校验

校验 marketplace：

```bash
claude plugin validate .
```

校验单个 plugin：

```bash
claude plugin validate word
claude plugin validate chart
```

校验 Nong-facing skills：

```powershell
nong skill inventory . --json
nong skill validate .\word --json
```

## 开源协议

Apache-2.0
