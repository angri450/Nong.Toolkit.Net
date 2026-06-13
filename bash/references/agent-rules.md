# Agent Invocation Rules

Rules for an AI agent calling the Bash tool. The Bash language traps live in the other reference files; this one is about the **tool call envelope**.

## Working directory

- Working directory persists across calls; **shell state (variables, functions, aliases) does not**. Each call is a fresh shell that inherits cwd.
- Prefer absolute paths. Avoid `cd` unless the user asks for it explicitly.
- Before creating files or directories, confirm the parent exists (e.g., `ls path/to/parent`) so you don't write into the wrong place.
- Quote paths with spaces: `cd "path with spaces/file.txt"`.

## Timeouts

- Default timeout applies; you may pass `timeout` (ms) up to the documented maximum.
- Don't extend the timeout to mask hangs — diagnose why the command is slow.

## Background execution

- Pass `run_in_background: true` for long-running commands. The runtime notifies you on completion.
- **Do not also append `&`** — the parameter handles it.
- Do not poll the background task; wait for the notification.

## Sleep anti-patterns

- No `sleep` between commands that can run immediately.
- No `sleep` while waiting for a background task — you'll be notified.
- No retry-with-sleep on failures — diagnose the root cause.
- If you must poll an external system, use a check command (e.g., `gh run view`) rather than blind `sleep`.
- If you must sleep, keep it 1–5 seconds.

## `find -regex` edge case (BSD `find` / `bfs`)

Alternation is leftmost-first. Put the longest extension first:

```bash
# Correct — matches both .ts and .tsx
find . -regex '.*\.\(tsx\|ts\)'

# Wrong — silently skips .tsx files
find . -regex '.*\.\(ts\|tsx\)'
```

## `description` field

See [description-style.md](description-style.md) — the `description` parameter of a Bash tool call has its own conventions.

## Permission and review

- Tool calls may go through a permission prompt. A clear `description` accelerates approval.
- A user approving one risky command does NOT approve the next — re-confirm for each.
