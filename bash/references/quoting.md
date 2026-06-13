# Quoting and Word Splitting

## Variable expansion

- `"$var"` always — unquoted `$var` undergoes word splitting and globbing.
- `file="my file.txt"; cat $file` reads two files (`my` and `file.txt`).
- `"$@"` preserves arguments individually; `$*` joins them.
- `"$(cmd)"` to capture, not `$(cmd)` — same word-splitting risk.
- Single quotes are literal: `'$var'` does not expand. Use for fixed strings.

## Globbing

- Unquoted `*` expands to matching filenames in the cwd.
- `set -f` disables globbing globally (rarely needed if quoting is correct).
- Quote literal asterisks: `"*"` or `\*`.

## Tricky cases

- Empty variables: `[ $var = "x" ]` becomes `[ = "x" ]` and errors. Quote both sides or use `[[ ]]`.
- Newlines in values survive `"$var"` but disappear in `$var`.
- IFS-sensitive: word splitting follows `$IFS`, not just spaces.
- `read -r line` then `printf '%s\n' "$line"` is the safe read-print idiom.

## When NOT to quote

- Right side of `[[ … == pattern ]]` and `[[ … =~ regex ]]` — quoting makes the pattern literal.
- Inside `(( ))` arithmetic — variables are bare, no `$` needed.
- Glob patterns you want to expand: `for f in *.txt; do …; done`.
