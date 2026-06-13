# Multimodal Skill

`multimodal` is exposed as a GroundPA skill for Nong OCR and image-structure QA commands.

Use `nong ocr analyze-image` for structure/blank/whitespace/content-region QA. Use `nong ocr cloud` and `nong ocr to-word` only when `PADDLEOCR_ACCESS_TOKEN` is available. Treat `ocr local` as a gated local path that may return E005/E009 unless the environment and a real image smoke test pass.

Do not route GroundPA through Python OCR libraries or custom OCR wrappers.
