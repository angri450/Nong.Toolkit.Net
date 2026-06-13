# Testing and Conditionals

## `[ ]` vs. `[[ ]]`

- `[[ ]]` is a Bash keyword: no word splitting, no glob on operands, supports `&&` and `||`.
- `[ ]` is a builtin (`/usr/bin/test`): operands undergo word splitting, so unquoted variables are dangerous.
- `[ $var = "x" ]` errors when `$var` is empty (becomes `[ = "x" ]`). Always quote in `[ ]`, or switch to `[[ ]]`.
- `<` and `>` inside `[ ]` are **redirection operators**. Use `-lt`, `-gt`, or escape: `[ "$a" \< "$b" ]`.

## String comparison

- `=` and `==` work in both `[ ]` and `[[ ]]`. Prefer `==` in `[[ ]]` for readability.
- Glob match: `[[ $var == *.txt ]]` — pattern unquoted on the right. `"*.txt"` matches a literal asterisk.
- Regex match: `[[ $var =~ ^foo[0-9]+$ ]]` — regex unquoted; captures land in `BASH_REMATCH[0]`, `[1]`, ….
- Lexical compare: `[ "10" \< "9" ]` is **true** (string compare: `1` < `9`). For numbers use `-lt`/`-gt` or `(( ))`.

## Numeric comparison

- `-eq`, `-ne`, `-lt`, `-le`, `-gt`, `-ge` — numeric.
- `(( ))` is cleaner: `if (( count > 5 ))`. No `$` needed inside.
- Leading zeros mean octal: `(( 08 ))` is a syntax error. Strip with `${var#0}` or use `10#$var` to force base 10.

## File tests

- `-e file` — exists (any type).
- `-f file` — regular file (follows symlinks).
- `-d file` — directory.
- `-L file` — symlink (does NOT follow).
- `-r`/`-w`/`-x` — readable/writable/executable **for the current user**, not generally.
- `-s file` — exists and non-empty.

## `case` patterns

- Patterns are globs, not regex: `*.txt` works, `.*\.txt` does not.
- `;;` ends a clause; `;&` falls through to the next clause's body; `;;&` re-tests subsequent patterns.

```bash
case "$file" in
  *.txt|*.md) echo "text" ;;
  *.sh)       echo "shell" ;;
  *)          echo "other" ;;
esac
```
