# Wrapper

将挖掘结果包装成带完整文档的可复用 skill。在 Improve Skill Step 3 时运行。Session 环节（挖掘会话历史）已抽离为独立工作流，运行时需已有挖掘数据。

## Step 1 — Confirm scope with the user

Before scanning, check with the user (via **AskUserQuestion** — see fallback note below if that tool is unavailable):

1. **What is the tool we're wrapping?** (exact name, distribution URL if known)
2. **What should the wrapper skill be called?** Suggest `<tool-name>-copilot` or `<tool-name>-companion` as defaults. Let the user override.
3. **Which repo does this land in?** (e.g. `claude-code-skills`, `claude-code-skills-pro`, a private repo)
4. **Which target agents should it install to?** Defaults to the three that `vercel-labs/skills` handles cleanly: Claude Code, Codex, OpenClaw. Allow user to narrow or expand.

Confirm in one sentence before mining. If the user hasn't given you enough context to fill these in, ask — don't guess.

### AskUserQuestion fallback

This workflow references `AskUserQuestion` repeatedly — it is the Claude Code tool that renders a multi-choice prompt with labeled options and lets the user pick one, returning a structured answer. It is the best possible affordance for decisions that have more than one right answer (like "which repair strategy should I apply?").

**Not every harness exposes this tool.** Codex does not have it. Older Claude Code versions do not have it. Custom agent builds may not have it. **The consent requirement is not the tool — it is the explicit user choice.** If `AskUserQuestion` is unavailable, fall back to printing the options inline in plain text with numbered labels and then stop, waiting for the user's reply before continuing. Example:

```
I need your consent before touching upstream files. Pick one:

 1) Strategy A — rename notes/SKILL.md -> notes/MODULE.md and patch root references (recommended, smaller footprint)
 2) Strategy B — prepend minimal frontmatter to the submodule files (minimal diff, creates two sub-skill names)
 3) Skip — leave it broken for now

Reply with 1, 2, or 3.
```

After the user replies, continue with the chosen strategy's exact commands. The requirement is that the user makes an informed choice before any upstream-file modification happens — `AskUserQuestion` is the preferred rendering, not the definition.

## Step 2 — Scaffold the skeleton

Run the scaffolding script:

```bash
skill-manager scaffold <wrapper-skill-name> \
  --tool "<tool-display-name>" \
  --target-dir <path/to/repo>
```

This creates the directory layout and writes stub files with `<!-- FILL FROM STEP 2X -->` placeholders. The layout matches `ima-copilot/` for consistency and to take advantage of the shared validation tooling.

If the scaffolding script is missing or fails (e.g. the target repo has an unusual layout), fall back to creating the directories manually — the shape matters more than the tooling:

```
<wrapper-skill-name>/
├── SKILL.md
├── scripts/
│   ├── install_<tool>.sh
│   └── diagnose.sh
├── references/
│   ├── installation_flow.md
│   ├── credentials_setup.md
│   ├── known_issues.md
│   └── best_practices.md
└── config-template/
    └── <tool>.json.example        # only if the tool has meaningful user-level preferences
```

If the tool has no meaningful user preferences (no priority lists, no per-user config), drop `config-template/` entirely. Don't invent configuration surface area that wasn't in the original session.

## Step 3 — Fill SKILL.md

Open `patterns.md` and copy the SKILL.md template. Fill in:

- `name` (from Step 1)
- `description` — a dense, trigger-heavy description including tool name, related keywords, and "when to use" signals extracted from session mining (install flow 1a and bugs 1c). The description should be *pushy* per skill-manager's guidance: err on the side of triggering slightly too often.
- Routing table referring to the scripts and references you're about to fill
- A "What this skill refuses to do" section that pins down the wrapper contract (see `architecture_contract.md`).

Important: the description lists the symptoms from session mining Step 1c verbatim as triggers. If the session uncovered `Skipped loading skill(s) due to invalid SKILL.md` as an error, that exact string goes in the description. Users hit by the same error will then have their future sessions trigger this skill.

## Step 4 — Fill install_<tool>.sh

Copy the install script template from `patterns.md`. Fill from session mining Step 1a. Every command in the template must be justified by a command the user or Claude actually ran in the conversation. Do not add command lines that were never executed — those are speculative and have not been verified.

Include the patterns from `patterns.md` that are almost always needed:

- `set -euo pipefail`
- `trap cleanup EXIT` for staging
- **Prerequisite checks**: `command -v` loop for `curl`, `unzip`, `npx`, plus a separate numeric Node.js >=18 check (parsing `node --version`). The Node check is its own step because `command -v node` only verifies presence, and `npx skills add` fails opaquely on Node 16.
- **Download integrity defense in depth**: `curl --fail -o <path> -w "%{http_code}"`, explicit `!= "200"` branch with a version-override hint, then a `wc -c` size sanity check rejecting archives below an absolute floor before extraction. The size check is what catches redirect-to-HTML-error-page failures that return a "success" status.
- Agent auto-detection against known home directories, plus a documented **zero-agents-detected fallback policy** — default to claude-code after printing a "looked for: ..." explanation, because aborting is hostile and silent-skip is mystifying.
- Version override via `--version` flag and env var
- `command` prefix on any `cp`/`mv`/`rm`/`sed` operations
- Root-file search that prefers known layouts before falling back to depth-sorted search

## Step 5 — Fill known_issues.md

Copy the known_issues format from `patterns.md`. For each bug from session mining Step 1c, create one entry with the full schema:

```markdown
### ISSUE-<NNN> — <short title>

**Status**: <Name the loader/runtime that exhibits the symptom. Prefer version-agnostic phrasing so the entry doesn't go stale — "Observed on recent upstream releases when loaded by X" beats "Open in upstream v1.1.2".>
**Symptom**: ...literal error message from session, verbatim...
**Root cause**: ...what was discovered...
**Impact**: ...what the user sees if unfixed...
**Why upstream probably hasn't fixed it**: <one-paragraph explanation. This field is non-optional — without it, future readers will assume the wrapper is out of date and remove the repair on the next upgrade.>
**How to explain it to the user** (plain language): ...

**Repair strategies**:

#### Strategy A — <name>
... exact commands using `command cp` / `command mv` / `command rm` / `command sed` ...
**Rollback**: ... exact commands ...
**Pros**: ...
**Cons**: ...

#### Strategy B — <alternative>
... if there's a real tradeoff ...

#### Strategy skip — Leave the file alone
<Every issue with more than one strategy should also document the "do nothing" branch and the conditions under which it's actually valid. Naming it as a first-class option makes it clear the user chose inaction rather than forgetting.>
```

Every command in every strategy must be:

- **Idempotent** — rerunning after the fix is applied is a safe no-op. Guard every backup `cp` with `[ -f "..." ] && \` so reruns don't print "file not found".
- **Reversible** — it backs up originals to `/tmp/<wrapper-skill-name>-backups/$(date +%Y%m%d-%H%M%S)/` before modifying anything. The `%Y%m%d-%H%M%S` format sorts correctly and is human-readable.
- **Alias-safe** — uses `command cp` / `command mv` / `command rm` / `command sed`, never the bare form, to dodge user shell aliases like `alias mv='mv -i'` that would hang the script on a prompt. `alias rm='rm -i'` is equally common and affects cleanup and rollback paths.
- **Cross-platform portable for sed** — use `sed -i.bak ... && command rm -f "<file>.bak"` which works on both BSD sed (macOS) and GNU sed (Linux). Bare `-i` and `-i ''` are mutually incompatible.

See `ima-copilot/references/known_issues.md` for a fully-fleshed example with two strategies (rename vs prepend frontmatter) plus the skip branch.

## Step 6 — Fill diagnose.sh

Copy the diagnose template from `patterns.md`. For each bug from session mining Step 1c, add a detection check that returns a **distinct code for every post-repair state** the wrapper can produce. Binary "OK / BROKEN" detection is not enough — see the "Detection function return-code contract" subsection of `patterns.md` for the full state list, but the short version is:

- One code for "original untouched and already valid"
- One code for "original untouched and still broken"
- One code for "target file not present at all" (legitimately different from BROKEN)
- One code per healthy post-repair state (one per Strategy A, B, ...)
- **One code for the dual-state conflicted case** where files from more than one strategy exist simultaneously

The dual-state code is the single hardest lesson from the ima-copilot session and the single place a careless author will skip. It prevents the "I ran the repair, diagnose says clean, but my install is subtly broken" failure mode.

diagnose.sh is **strictly read-only**. It never modifies files. It returns:

- `0` — everything healthy
- `1` — one or more issues need user action (including CONFLICTED states that require manual cleanup)
- `2` — diagnostic itself failed (e.g. network error on liveness check)

If the tool installs to multiple agents via symlinks (common with `npx skills add` in its default mode), diagnose must recognize shared canonical installs via `realpath` and scan each underlying directory exactly once. Otherwise users see the same issue reported once per agent, which is confusing.

`find_install` should take a *variadic list* of candidate paths per agent, not a single path. This matters most for agents whose home-directory layout has not stabilized (like OpenClaw), where multiple candidate paths need to be probed in order. Designing the helper as variadic from day one avoids a painful refactor when a second candidate path becomes necessary.

## Step 7 — Fill references

Four standard files. Content comes from session mining:

- `installation_flow.md` — prose deep dive on how the installer works, why the flags are what they are, troubleshooting for common failures (from 1a)
- `credentials_setup.md` — XDG paths, env var fallback, liveness check, rotation procedure (from 1b)
- `known_issues.md` — already written in Step 5
- `best_practices.md` — the non-obvious usage patterns discovered in the session (from 1d and general usage observations)

Each reference file should be lean. If it grows beyond ~200 lines, split it.

## Step 8 — Fill config-template (if applicable)

Only if Step 1 established that the tool has meaningful per-user configuration. Write a JSON template with illustrative-only values and `_comment_<field>` entries explaining each field. Do NOT include any real user data — the values in the template are examples that users replace.

## Step 9 — Verify the generated skill

See `verification_protocol.md` for the full verification procedure. The short version:

1. Run `quick_validate.py` against the generated directory
2. Run `security_scan.py` against the generated directory
3. Run the generated `diagnose.sh` against the actual state the session left you in, and confirm it reports the issues that were present and the fixes that were applied — this closes the loop between the session's real work and the skill's description of that work
4. Update the relevant marketplace `marketplace.json` with a new plugin entry and bump versions
5. Update `CHANGELOG.md` / `README.md` / `README.zh-CN.md` / repo `CLAUDE.md` per the hosting repo's release guide

## Step 10 — Commit

One commit per wrapper skill. Commit message format:

```
feat(<wrapper-skill-name>): add <tool-name> companion skill v1.0.0

<2-3 sentence summary of what this skill wraps and why>

Distilled from a real install-and-debug session that encountered <N>
issues, all of which are documented in references/known_issues.md with
working repair commands.
```

Do not push. Let the user decide when to push.

## Anti-patterns

Things that should make you stop and reconsider:

- Writing code that did not appear in the session. If you find yourself inventing a command, it is speculation — go back and either (a) find where in the session it actually ran, or (b) skip it.
- Documenting a bug with no fix. Known issues without fixes are noise. Omit them.
- Vendoring any upstream files into the new skill directory. If you need to reference upstream, reference it by URL or by install-path, not by copying.
- Generating a repair command that you haven't mentally walked through for idempotency. Every command should be safe to run twice.
- Hardcoding the user's real file paths into any file. Use `$HOME` or the agent's standard install locations.
- Committing credentials, tokens, or any personally identifying content.

If you catch yourself doing any of the above, stop and ask the user.
