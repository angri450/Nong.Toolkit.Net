# Packaging Guide

## Quick Start

```bash
dotnet run --project tools/SkillManager.Cli -- package .
```

This command:
1. **Validates** SKILL.md structure, frontmatter, and references
2. **Scans** for security issues (blocks on High+)
3. **Packages** into a `.zip` archive

## What Gets Packaged

All files in the skill directory except:
- `bin/`, `obj/` (build artifacts)
- `.git/`, `node_modules/`, `__pycache__/` (excluded as precaution)
- `evals/`, `workspace/`, `tests/`, `tools/` (development dirs)
- `.DS_Store`, `Thumbs.db`, `.gitignore` (config files)
- `.security-scan-passed` (scan marker)
- Temp files (`*~`, `.#*`)

## What Gets Validated Before Packaging

- SKILL.md exists with valid YAML frontmatter
- `name` is present and in hyphen-case
- `description` is present, is a string (not list/object), under 1024 chars
- SKILL.md line count is reasonable (< 700 lines is ok, < 500 is ideal)
- No version/changelog sections in SKILL.md (belongs in marketplace.json)
- Referenced resource directories actually exist

## After Packaging

### Marketplace Update

For new skills, add to `.claude-plugin/marketplace.json`:
```json
{
  "name": "skill-name",
  "description": "Copy from SKILL.md frontmatter",
  "source": "./",
  "version": "1.0.0",
  "category": "developer-tools",
  "keywords": ["relevant", "keywords"],
  "skills": ["./skill-name"]
}
```

For updated skills, bump the version following semver.

### Verification

After packaging, verify the archive:
```bash
# List contents
unzip -l skill-name.zip

# Verify SKILL.md is included
unzip -p skill-name.zip SKILL.md | head -20
```

## Legacy: Python Packager

```bash
python scripts/package_skill.py <skill-path> [output-dir]
```

The Python packager is legacy. Prefer the .NET CLI. The Python packager includes additional features (security marker hash validation, gitleaks integration).
