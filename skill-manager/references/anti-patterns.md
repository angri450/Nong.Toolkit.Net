# Anti-Patterns

Common mistakes to avoid when creating or maintaining skills.

## Structural Anti-Patterns

### Mega-Skill
One skill handling > 3 unrelated domains with a SKILL.md > 700 lines.
**Fix**: Split into focused sub-skills. Use `references/merge-split.md` for the split process.

### Missing Progressive Disclosure
Everything in SKILL.md, nothing in references/.
**Fix**: Move detailed content to references/. SKILL.md should be a kernel/router.

### Duplicate Content
Same information in SKILL.md and a reference file.
**Fix**: Information lives in exactly one place. Prefer references for details.

## Description Anti-Patterns

### Overclaiming
Description claims capabilities not implemented in the skill.
**Example**: "Handles all PDF operations" when only rotation is implemented.
**Fix**: Narrow description to implemented features. See SKILL.md "Description Honesty Boundary."

### Vague Triggers
Description too general to be useful: "Use when working with files."
**Fix**: Include specific trigger phrases users actually say.

### Missing Keywords
Description uses technical jargon users don't use: "Invoke for vector embedding optimization."
**Fix**: Add common user phrases: "make my search better," "fix my search results."

## Process Anti-Patterns

### Skip Prior Art
Building from scratch without checking for existing tools/MCPs.
**Fix**: Run the 8-channel search in `references/prior-art-research.md`.

### No Evals
Shipping a skill without any test cases.
**Fix**: Minimum 2-3 realistic test prompts in `evals/evals.json`.

### Skip Security Scan
Packaging without scanning for credentials and vulnerabilities.
**Fix**: `dotnet run --project tools/SkillManager.Cli -- scan .` before every package.

### Delete Backup Versions
Removing old skill versions instead of deprecating.
**Fix**: Mark as deprecated, move to archive. See `references/deprecation.md`.

## Writing Anti-Patterns

### Second Person
"You should validate the input" instead of "Validate the input."
**Fix**: Use imperative form throughout.

### ALL CAPS Emphasis
"ALWAYS do X" and "NEVER do Y" as primary emphasis.
**Fix**: Explain the why. ALL CAPS is a yellow flag — reframe with reasoning.

### No Failure Documentation
Only documenting what works, not what was tried and failed.
**Fix**: Include "Do NOT attempt" patterns with root-cause explanations. Failed approaches are as valuable as successful ones.

## Security Anti-Patterns

### Hardcoded Paths
Absolute paths to user directories in source.
**Fix**: Use relative paths, `$HOME`, or placeholders.

### External CDNs
Loading fonts, scripts, or styles from remote servers.
**Fix**: System font stacks, bundled dependencies, no CDN.

### innerHTML Without Sanitization
Setting innerHTML with user or model-generated content.
**Fix**: Use `textContent`, or sanitize through `escapeHtml()` first.

### Verbose-Gated Security
Security checks that only run in verbose/optional mode.
**Fix**: Always-on detection. Verbose controls output detail, not whether scanning happens.
