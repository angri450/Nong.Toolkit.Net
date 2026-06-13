# Fix an Overly Broad Trigger

## What the user wants

Fix the `multimodal` skill that was triggering on too many unrelated requests.

## What went wrong (before fix)

- Skill name: `multimodal` — too broad, suggested it handled ALL multi-modal tasks.
- Description: "OCR and image-structure QA" — missed that the CLI command group is `ocr`.
- Result: AI would route image-related requests here even when they belonged to `chart` or `diagram`.

## What was done

1. **Renamed** the skill from `multimodal` to `ocr` to match the CLI command group `nong ocr`.

2. **Narrowed the description**: Added explicit trigger words (OCR, PaddleOCR, scanned image, image-to-Word) and removed the vague "multimodal" keyword.

3. **Added boundaries**:
   - Not for PDF full-document OCR → route to `pdf` skill
   - Not for chart/diagram visual QA that needs this skill's `analyze-image` only as a sub-step

4. **Added a route table**: Each user intent mapped to one specific command or reference file.

## Result

After the fix:
- `nong skill validate .\ocr --json` passed
- The skill no longer overlaps triggers with `chart` or `diagram`
- Users searching for "OCR" get the right skill immediately

## Key takeaways

- The skill name should match the CLI command group whenever possible (`ocr` ↔ `nong ocr`).
- A route table is better than long prose: it forces you to list every entrypoint explicitly.
- Boundaries are not optional. Every skill should state what it does NOT handle.
