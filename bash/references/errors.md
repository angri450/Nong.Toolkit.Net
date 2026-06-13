# Error Handling Traps

## `set -e` (errexit) blind spots

`set -e` does NOT exit when an error occurs in:

- The condition of `if`, `while`, `until`.  → `if ! cmd; then` is safe.
- Either side of `||` or `&&`.              → `cmd || true` is the standard "swallow" pattern.
- Subshells inside command substitution.    → `x=$(failing_cmd)` does not propagate `-e`.
- Functions called from those contexts (controversial; avoid relying on it).

Recommendation: `set -euo pipefail` at script top, plus explicit checks for the cases above.

## Pipelines

- A pipeline's exit code is the **last** stage by default: `bad | good` returns 0.
- `set -o pipefail` makes the pipeline fail if any stage fails — but you cannot tell which without `${PIPESTATUS[@]}`.
- `${PIPESTATUS[0]}`, `${PIPESTATUS[1]}`, … hold each stage's exit code; capture immediately after the pipeline.
- Pipes spawn subshells: `cat file | while read line; do ((count++)); done` loses `count` in the parent shell. Use `< <(cmd)` instead:

```bash
count=0
while read -r line; do ((count++)); done < <(grep pattern file)
echo "$count"   # preserved
```

## Subshells

- `( … )` is a subshell — variables set inside do not escape.
- `{ … }` is a group in the same shell — variables persist.
- `$(cmd)` captures stdout only; stderr still goes to the terminal.
- `exit` inside `( … )` exits only the subshell; the parent script keeps running.

## Traps

- `trap cleanup EXIT` runs on **any** exit, including errors and `Ctrl-C` (after the signal handler).
- `trap '' SIGINT` ignores a signal; `trap - SIGINT` resets to default.
- Only one trap per signal — the latest one wins. Compose multiple cleanups in a single function.

## Redirection order

- `command 2>&1 >file` — stderr goes to terminal, stdout goes to file (wrong for "log everything").
- `command >file 2>&1` — both go to file. **Order matters**: redirections apply left to right.
- `&>file` is a Bash shortcut for `>file 2>&1`.

## Other

- `return` outside a function is an error — use `exit` at the top level.
- Exit codes are 0–255; values outside wrap modulo 256.
