# Parameter Expansion Traps

## Defaults

- `${var:-default}` — use `default` if `var` is unset OR empty.
- `${var-default}` — use `default` only if `var` is unset (empty stays empty).
- `${var:=default}` — same as `:-` but **assigns** the default to `var`.
- `${var:?error message}` — exit with error if unset/empty.
- `${var:-$(cmd)}` — `cmd` runs even when only checking. Subshell side effects fire.

## Substring

- `${var:0:5}` — first 5 chars (bytes in some locales, not characters).
- `${var: -3}` — last 3 chars; the **leading space is required**, otherwise it parses as `${var:-3}` default-value syntax.

## Pattern stripping (glob, not regex)

- `${var#pattern}` — remove shortest match from start.
- `${var##pattern}` — remove longest match from start.
- `${var%pattern}` — remove shortest match from end.
- `${var%%pattern}` — remove longest match from end.
- Pattern is a glob: `*` is wildcard, `.` is literal.

```bash
path=/usr/local/bin/foo.sh
echo "${path##*/}"   # foo.sh   (basename)
echo "${path%/*}"    # /usr/local/bin   (dirname)
echo "${path##*.}"   # sh   (extension)
```

## Replacement

- `${var/pattern/replace}` — first match.
- `${var//pattern/replace}` — all matches.
- `${var/#pattern/replace}` — anchored to start.
- `${var/%pattern/replace}` — anchored to end.
- Empty replacement deletes: `${var//pattern}` removes all matches.

## Case (Bash 4.0+)

- `${var^}` — uppercase first char; `${var^^}` — uppercase all.
- `${var,}` — lowercase first char; `${var,,}` — lowercase all.

## Indirection

- `${!var}` — value of the variable whose name is in `$var`.
- `${!prefix*}` / `${!prefix@}` — list **names** of variables starting with `prefix` (not their values).
