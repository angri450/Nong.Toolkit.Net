# 2026-06-05 Nong CLI Preflight / Word / OCR 修复同步

> Superseded on 2026-06-05 by `2026-06-05-pure-dotnet-ppocrv5-sync.md` for OCR. The Python/PaddleOCR bridge notes in this file are historical and must not be used for current GroundPA multimodal guidance.

## 背景

用户反馈表明，GroundPA skill 层没有清楚表达 `nong` CLI 前置依赖，导致通过 Plugin Marketplace 安装后只得到 skills，agent 执行 `nong` 时会直接遇到 command not found。同时，Word 既有文档编辑和 OCR 文档仍在沿用阶段 17 的旧口径，容易把 VML 图片、`.doc` 转换、blockId、E009 空桩等问题继续传给使用者。

## 修复内容

- 所有 Nong-facing skills 增加 CLI preflight：先运行 `nong commands --json`，缺失时提示 `dotnet tool install/update --global Angri450.Nong.Cli`。
- 明确 Plugin Marketplace 只安装 skills，不安装必需的 `nong` CLI；README 给出经典 skills 安装路径和 marketplace 实验路径的差异。
- Word skill 默认从 `nong word check <file> --json` 开始；`.doc` 使用 `nong word convert <file> -o <file.docx> --json` 进入后续 docx 管线。
- Word references 同步 `content.jsonl` 的 `id/blockId/index`、VML 图片 asset/warning、`word check`、`word convert`、`word images` 行为。
- Multimodal skill 同步本地 OCR 真实状态：`ocr local` 是 Python/PaddleOCR bridge，稳定使用前必须 `check-env` + 真实图片 smoke test；`install-model --dry-run` 给安装计划，非 dry-run 安装 Python PaddleOCR 依赖。
- OCR cloud / to-word 文档补充 `PADDLEOCR_ACCESS_TOKEN` 来源：`https://aistudio.baidu.com/account/accessToken`。
- 错误恢复指引不再只说 “status:error failed”，而是给出 E002/E005/E006/E009 的下一步。
- README / README.zh-CN / DEVELOP 同步 `2.2.0`、roll-forward、Plugin Marketplace 与 Nong CLI 分离安装说明。

## 验证口径

本次同步以本地 Nong CLI 修复后的真实命令面为准：

- `nong commands --json`：73 implemented commands，`meta.version=3.2.2`。
- CLI contract tests：68/68 PASS。
- `ocr install-model pp-ocrv5-mobile --dry-run --json`：OK，返回 Python PaddleOCR 安装计划。
- 9 个 Nong-facing skill：逐个 `nong skill validate` 均为 0 error / 0 warning。
- `nong skill scan .\GroundPA-Toolkit --json`：0 findings。
- `claude plugin validate .\GroundPA-Toolkit`：Validation passed。

## 发布提醒

GroundPA plugin 可以继续通过 GitCode/Gitee/GitHub 作为 skill 镜像分发；但无论 classic skills install 还是 Plugin Marketplace install，都必须额外安装或更新 `Angri450.Nong.Cli`。这不是 marketplace 能自动解决的二进制分发问题。
