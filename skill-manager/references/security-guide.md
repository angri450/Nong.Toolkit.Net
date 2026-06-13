# Security Guide

The .NET CLI `scan` command provides always-on security detection.

## Quick Start

```bash
dotnet run --project tools/SkillManager.Cli -- scan .
```

Default scan (non-verbose) detects ALL pattern types. There is no verbose gate.

## What the Scanner Detects

| Category | Rule | Severity | Examples |
|----------|------|----------|---------|
| Email addresses | `EMAIL_EXPOSED` | High | real email addresses in source files |
| Private keys | `PRIVATE_KEY` | Critical | private key block markers |
| GitHub tokens | `GITHUB_TOKEN` | Critical | provider token patterns |
| API keys | `API_KEY` | Critical | API key assignment patterns |
| JWT tokens | `JWT_TOKEN` | High | JWT-shaped token strings |
| Absolute user paths | `ABSOLUTE_USER_PATH` | High | hardcoded user profile paths |
| Home paths | `HOME_PATH_REFERENCE` | Medium | shell home-directory shortcuts |
| Unsafe shell commands | `DANGEROUS_RM` | Critical | rm -rf without safeguards |
| HTTP URLs | `HTTP_URL` | Low | Non-HTTPS URLs |
| External CDNs | `EXTERNAL_CDN` | High | remote CDN hostnames |
| Unsafe innerHTML | `UNSAFE_INNERHTML` | High | innerHTML without sanitization |

## Handling Findings

### Critical / High
Must be fixed before packaging. Package exits with code 2 if any exist.

### Medium / Low  
Reported but don't block packaging. Review and fix at discretion.

### False Positives
Test fixtures with intentional patterns (fake keys, test emails) in `tests/` directories are fine — tests/ is excluded from packaging.

## Manual Review

For public distribution, also run the sanitization checklist (`references/sanitization_checklist.md`) which covers categories the automated scanner can't detect: company names, internal jargon, business logic patterns.

## XLSX Preview Degradation

The eval viewer (`eval-viewer/viewer.html`) no longer renders XLSX output as inline preview. This is a deliberate security decision:

- **Removed**: SheetJS CDN — eliminated XSS risk from `XLSX.utils.sheet_to_html` output being inserted via `innerHTML`
- **Removed**: Google Fonts CDN — eliminated Referer-header data leakage
- **Current behavior**: XLSX files in eval outputs are offered as download only. A text message explains the limitation.
- **Future restoration path**: To restore XLSX preview, vendor the SheetJS library locally in `assets/sheetjs/`, verify the integrity hash, and update `viewer.html` to reference the local copy. Add HTML sanitization of `sheet_to_html` output before `innerHTML` insertion. **Never** use a remote CDN.
