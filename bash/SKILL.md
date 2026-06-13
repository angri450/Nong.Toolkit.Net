---
name: bash
description: Bash scripting and CLI operations. Trigger on shell scripts, quoting bugs, set -e, trap, git commands, sandbox failures, or tool-selection between Bash and Glob/Grep.
---

# Claude Code Bash

Two failure modes covered here, because they fail in different ways and need different mental models:

1. **Bash language traps** — quoting, expansion, arrays, subshells silently doing the wrong thing because POSIX semantics are surprising.
2. **Agent invocation traps** — calling the Bash tool when a dedicated tool would be safer and easier to review, serializing independent calls, amending a commit that was never created, blanket-disabling the sandbox.

The single most useful heuristic: **default to dedicated tools, reach for Bash only when shell semantics are required.** Diff/permission review is tighter, and the user doesn't have to reason about quoting in a context where they wouldn't have to.

## Tool Selection (use these BEFORE Bash)

| Need | Tool |
|---|---|
| Find files by name pattern | Glob |
| Search file contents | Grep |
| Read a file | Read |
| Edit a file | Edit |
| Create a file | Write |
| Communicate with the user | plain text output |

Why: dedicated tools render diffs cleanly, respect line-number addressing for edits, and give the user a sharper permission prompt. Falling through to Bash for `find`/`grep`/`cat`/`head`/`tail`/`sed`/`awk`/`echo` is acceptable only when the dedicated tool genuinely cannot do the job — e.g., piping through `awk` for a transformation that has no equivalent in Edit.

## Concurrent vs. Sequential Calls

- **Independent commands** (e.g., `git status` and `git diff`): emit multiple Bash calls **in a single message** so they run in parallel.
- **Dependent commands** (output of A feeds B): one Bash call, chained with `&&`.
- `;` only when failure of the earlier command is acceptable.
- **Never separate commands by newline** outside of quoted strings — newlines are silently dropped by the tool framing layer.

The parallel-in-one-message pattern is the single biggest latency win, because round-trip-per-call dominates the wall clock for short commands.

## Quoting Essentials

- Always quote variable expansions: `"$var"`, not `$var`. Unquoted variables undergo word splitting on `$IFS` and then globbing.
- Quote arrays as `"${arr[@]}"`. `${arr[*]}` joins into one string; unquoted `${arr[@]}` splits on whitespace and you lose elements with spaces in them.
- Single quotes are literal: `'$var'` does not expand.
- Quote command substitutions: `"$(cmd)"`, not `$(cmd)` — same word-splitting risk as a plain variable.
- Paths with spaces always need double quotes — Windows users especially are likely to hand you `"C:/Program Files/…"` paths.

## Test Brackets

- Prefer `[[ ]]` over `[ ]` — no word splitting on the operands, supports `&&`/`||`/regex, and the right-hand side of `==` is a glob pattern.
- `[[ $var == pattern* ]]` — glob on the right side, **unquoted**. Quoting `"pattern*"` makes it match the literal asterisk.
- `[[ $var =~ regex ]]` — regex unquoted, captures land in `BASH_REMATCH[0]`, `[1]`, ….
- `[[ -z "$var" ]]` empty, `[[ -n "$var" ]]` non-empty.
- `[ $var = "x" ]` breaks if `$var` is empty (becomes `[ = "x" ]` and errors). Prefer `[[ ]]`, or quote both sides.

## Set Flags

- `set -e` — exit on error. Does **not** trigger inside `if`, after `||`/`&&`, or in command-substitution assignment. So `x=$(failing_cmd)` swallows the failure.
- `set -u` — error on undefined variable; catches typos.
- `set -o pipefail` — pipeline fails if any stage fails (otherwise only the last stage's exit code matters). Combine: `set -euo pipefail` at script top.
- `trap cleanup EXIT` — runs on any exit, including errors and `Ctrl-C` (after the signal handler).

## Arithmetic

- `$(( ))` for value; `(( ))` for condition: `if (( count > 5 ))`.
- No `$` needed inside `(( ))`: `$((count + 1))`, not `$(($count + 1))`.
- `08`, `09` are invalid in arithmetic — the leading zero means octal.

## The Subshell Trap (one-liner)

`cmd | while read; do ((count++)); done` — `count` is gone in the parent shell, because the pipe spawned a subshell. Use process substitution instead: `while read; do …; done < <(cmd)`.

## Common Mistakes Quick List

- `if [ -f $file ]` with spaces in `$file` — quote and prefer `[[ ]]`.
- `local` missing in functions — variables leak to global scope.
- `read` without `-r` — backslashes get interpreted as escapes, mangling content.
- `echo` for portability — prefer `printf "%s\n"` for reliable formatting (BSD `echo` and GNU `echo` differ on `-e`).
- `git add -A` — risks committing `.env`, credentials, build artifacts. Add files by name.
- `git commit --amend` after a hook failure — the original commit never happened, so amend modifies the **previous** commit and may lose work. Fix the issue, re-stage, create a **NEW** commit.

## Reference Index

For deeper coverage, read the relevant file from `references/`. Each file is self-contained — only load what you need:

| Topic | File | Read when |
|---|---|---|
| Quoting and word splitting | [references/quoting.md](references/quoting.md) | Variables behave unexpectedly across whitespace, or you need to know when **not** to quote |
| Arrays | [references/arrays.md](references/arrays.md) | Building or iterating arrays, especially from command output (`mapfile` vs. `arr=($(cmd))`) |
| Parameter expansion | [references/expansion.md](references/expansion.md) | Using `${var:-…}`, `${var#…}`, `${var/…/…}`, indirection, case modification |
| Error handling | [references/errors.md](references/errors.md) | `set -e` not catching what you expected, pipeline exit codes, traps, redirection order |
| Testing and conditionals | [references/testing.md](references/testing.md) | `[[ ]]` vs. `[ ]`, regex with `BASH_REMATCH`, file tests, numeric vs. string comparison |
| Agent invocation rules | [references/agent-rules.md](references/agent-rules.md) | Working directory persistence, timeouts, `run_in_background`, sleep anti-patterns, `find -regex` quirks |
| Description field style | [references/description-style.md](references/description-style.md) | Writing the `description` parameter for a Bash tool call (active voice, 5–10 words, banned words) |
| Git Safety Protocol | [references/git-protocol.md](references/git-protocol.md) | About to run `git commit`, `git push`, or open a PR with `gh pr create` |
| Sandbox decisions | [references/sandbox.md](references/sandbox.md) | Considering `dangerouslyDisableSandbox`, judging whether a failure is sandbox-caused, deciding what to allowlist |
| Command detection and semantics | [references/command-detection.md](references/command-detection.md) | Classifying a command prefix for permission systems (BASH_POLICY_SPEC), judging exit codes (`grep`/`diff`/`test` exit 1 is not an error), surfacing destructive-command warnings |
