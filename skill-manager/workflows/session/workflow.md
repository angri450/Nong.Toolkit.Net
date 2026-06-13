# Session

Runs automatically at the end of every session where errors were encountered and fixed. Read-only. Never modifies files. Never exposes user paths. Output appends to session-records.

## When this applies

At the end of a session where any tool (skill, CLI, bash, pwsh, package manager, etc.) encountered real friction — install errors, missing flags, undocumented behavior, broken files, shell quirks, font issues, version conflicts — and you diagnosed and fixed the problem.

Do **not** run this if the session went smoothly with no real problems. There is nothing to mine.

## Step 1 — Mine the conversation history

This is the most important step. Scan the conversation from its beginning to the point where this workflow was triggered. Extract concrete, literal snippets for each category below. Do not paraphrase error messages or commands — copy them verbatim.

### How to access the conversation

Where the history lives depends on whether you are in the same session that produced the debugging work or in a follow-up session:

- **Same session (most common)**: scroll your own message history upward. Start from the most recent messages and walk back until you find the first mention of the tool or error being addressed. Everything between that point and now is your source material. You already have this in context — you do not need any tool to "fetch" it.

- **Follow-up session (the user came back later)**: use the `claude-code-history-files-finder` skill if it is installed, or read the session JSONL directly from `~/.claude/projects/<escaped-cwd>/<session-id>.jsonl`. The escaped cwd is the working directory with `/` replaced by `-` (for example, `<workspace>/claude-code-skills` becomes `<escaped-cwd>`). Grep the JSONL for literal error fragments (`"error"`, `"Traceback"`, shell prompt characters), extracted shell commands, and file paths the user edited. The JSONL is newline-delimited JSON with one record per message.

- **Neither available**: stop the workflow and tell the user. Do **not** proceed by inventing plausible install commands or plausible bug fixes — that violates the workflow's entire reason to exist. Say "I cannot find the session history this workflow needs. Can you paste the relevant install log, error messages, and fix commands directly into this conversation so I can work from them?" and wait. Fabricated content is worse than no wrapper skill.

The rules that follow (1a-1e) apply regardless of which source you used.

### 1a — The working install flow

What did it take to actually get the tool installed?

- **Source**: the canonical URL, package name, git repo, or local archive
- **Download/extract commands**: exact `curl`/`wget`/`unzip` invocations that succeeded
- **Target layout**: which directories received files, on which agents
- **Distribution tool**: did you use `npx skills add` (vercel-labs/skills), a custom script, a package manager? With which flags?
- **Detection**: did you check for installed agents before writing? What was the detection rule?
- **Cleanup**: what was the staging dir strategy, and when was it removed?
- **Version pinning**: did you hard-code a version, accept env override, or both?

In `ima-copilot`, all of this became `scripts/install_ima_skill.sh`.

### 1b — Credential setup

- **What credentials the tool needs** (API key, client ID, OAuth token, SSH keys, etc.)
- **Where you chose to store them** (env var / XDG config file / keychain)
- **Permission mode** you set on the files
- **Env var fallback order** you decided on (env > file, or file > env)
- **The liveness call** you used to verify the credentials work (what endpoint, what request, what success indicator)

In `ima-copilot`, this became `references/api_key_setup.md`.

### 1c — Bugs encountered AND resolved

This is the gold. For each real bug you hit and actually fixed in the conversation, extract:

- **Symptom** — the literal error message, log line, or observed misbehavior. Copy it verbatim from the conversation.
- **Root cause** — what you discovered after investigation. Include the "aha" moment if there was one.
- **Fix commands or code change** — the exact commands or diff that resolved it.
- **Verification** — how you confirmed the fix worked. What you re-ran and what you expected to see.
- **Reversibility** — if the fix modified files, where did you back up the originals?
- **Idempotency** — can the fix run twice without harm? If not, what guards did you add?
- **Attribution** — which upstream version, which agent, which platform you saw it on.

**Rules for what counts as a bug worth capturing:**

-  It was real — you saw the symptom, not just imagined it.
-  You fixed it — there's a concrete resolution, not a "let's pivot" or "we gave up".
-  The fix is reusable — another user hitting the same symptom could run the same fix.
-  Skip dead ends where you abandoned an approach without a working fix.
-  Skip user errors (wrong password typed, wrong directory) unless the tool's error message was so unhelpful that documenting the confusion is a win.
-  Skip "Claude tried X and X was wrong, then tried Y" loops — only Y matters.

### 1d — Design decisions

Decisions the user and you made together that are not obvious from the code. For each:

- **The decision** (short noun phrase)
- **The alternatives considered**
- **Which side won**
- **Why** — quote or paraphrase the conversation

Examples from the ima-copilot session:

- Symlink vs `--copy` mode for `npx skills add`: chose symlink because "修一次同步所有 agent" was the user's explicit preference.
- XDG credentials (`~/.config/ima/`) vs env vars: chose XDG as primary with env vars as fallback because persistent files are less ceremony for local dev.
- `command mv` / `command cp` prefix in repair commands: discovered mid-dogfood that the user's shell aliased `mv` to `mv -i`, causing an interactive prompt hang.
- Root `SKILL.md` detection via explicit path-first, then depth-sorted fallback: discovered when `find` surfaced a submodule's `SKILL.md` as the "first match" and broke `npx skills add`.

Design decisions that reference real debugging moments are the most valuable, because they encode the "why" that would otherwise be lost.

### 1e — Noise to discard

What **not** to put in the mined output:

- Random conversational digressions
- Tool invocations that Claude made and then rolled back
- Code written and then replaced before it ever ran
- Debates without a resolution
- Discussions that were educational but didn't produce a code artifact
- Anything from a previous session that isn't in this conversation's history

**If you are unsure whether a piece is signal or noise, ask the user rather than guessing.** The cost of asking once is much lower than the cost of shipping a wrapper skill full of half-baked lessons.

## Output format

Append one JSON line per finding to session-records:

```jsonl
{"t":"ISO8601","skill":"<name>","type":"api|file|format|font|compat|install|credential|design|other","msg":"<what>","fix":"<how>","r":true}
```

## Anti-patterns

- Writing code that did not appear in the session. If you find yourself inventing a command, it is speculation — go back and either (a) find where in the session it actually ran, or (b) skip it.
- Documenting a bug with no fix. Known issues without fixes are noise. Omit them.
- Hardcoding the user's real file paths (`/Users/<username>/...`, etc.) into any file. Use `$HOME` or the agent's standard install locations.
- Committing credentials, tokens, or any personally identifying content.
