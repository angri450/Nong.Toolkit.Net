# Array Traps

- `arr=($(cmd))` splits on whitespace — use `mapfile -t arr < <(cmd)` for line-by-line.
- Associative arrays need `declare -A`; without it, string keys silently become index 0.
- `${arr[*]}` joins into a single string; `${arr[@]}` preserves elements.
- Unquoted `${arr[@]}` splits on whitespace — always `"${arr[@]}"`.
- `${#arr}` is the length of the **first element**; `${#arr[@]}` is the count.
- `for item in ${arr[@]}` splits — use `for item in "${arr[@]}"`.
- `for i in {1..$n}` does NOT expand `$n` (brace expansion runs before parameter expansion). Use `seq 1 "$n"` or `for ((i=1; i<=n; i++))`.
- `unset 'arr[2]'` leaves a gap; subsequent indices do not shift down.
- `${arr[-1]}` is a syntax error in older Bash. Portable: `"${arr[@]: -1}"` (space required before `-1`).
- Indexing an indexed array with a non-numeric string silently uses index 0 — `arr[foo]=x` overwrites `arr[0]`.

## Building arrays safely

```bash
# From command output, line-per-element:
mapfile -t lines < <(grep pattern file)

# Append:
arr+=("new item")

# Iterate by index (handles sparse arrays):
for i in "${!arr[@]}"; do
  printf '%s\t%s\n' "$i" "${arr[$i]}"
done
```
