# 2026-06-05 GroundPA 同步 Nong 3.2.3 纯 .NET 本地 OCR

## 背景

Nong 本地 OCR 从 Python bridge 改为纯 .NET PP-OCRv5 runtime。GroundPA skill 不能再提示安装 Python、pip、`paddleocr` Python 包，也不能继续读取 `localPythonPaddleOcr` 字段。

## 同步内容

- `multimodal/SKILL.md`：
  - 预检版本更新为 Nong `3.2.3+`。
  - 本地 OCR gate 改为 `localDotNetPpOcrV5.status=ok`。
  - `install-model --dry-run` 说明改为国内 NuGet 镜像部署方案，要求 `noPython=true`。
- `multimodal/references/ocr-local.md`：
  - 重写为纯 .NET PP-OCRv5 工作流。
  - 明确客户机不安装 Python、pip 或外部 OCR 可执行文件。
  - 保留真实图片 smoke test 要求。
- `README.md` / `README.zh-CN.md` / `DEVELOP.md`：
  - 从 Python bridge 口径改成纯 .NET PP-OCRv5。
  - 版本提示更新为 `3.2.3+`。

## 验收

- 9 个 Nong-facing skill 逐个 `nong skill validate`：0 error / 0 warning。
- `nong skill scan .\GroundPA-Toolkit --json`：0 findings。
- `claude plugin validate .\GroundPA-Toolkit`：Validation passed。
- Nong OCR 实测：`check-env` 报 `localDotNetPpOcrV5.status=ok`，中文图 `测试123` 本地识别成功。
