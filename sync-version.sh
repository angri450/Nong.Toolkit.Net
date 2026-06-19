#!/bin/bash
# Toolkit.Net version sync — zero dependencies (bash + sed only)
# Usage: ./sync-version.sh 12.1.0
set -euo pipefail
NEW="${1:?Usage: $0 <version>  e.g.  $0 12.1.0}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
echo "=== Toolkit.Net → $NEW ==="

# 1. All plugin.json files — replace "version" line
while IFS= read -r f; do
    sed -i 's|\"version\": \"[0-9.]*\"|\"version\": \"'"$NEW"'\"|' "$f"
    echo "  $(basename "$(dirname "$(dirname "$f")")")/plugin.json"
done < <(find "$ROOT" -path "*/.claude-plugin/plugin.json")

# 2. README files — version + command count line
for f in "$ROOT/README.md" "$ROOT/README.zh-CN.md"; do
    [ -f "$f" ] || continue
    sed -i "s|Nong\.Cli\.Net [0-9.]* / [0-9]*|Nong.Cli.Net $NEW / 332|g" "$f"
    echo "  $(basename "$f")"
done

# 3. CLAUDE.md
sed -i "s|适配 [0-9.]*|适配 $NEW|g; s|\(v[0-9.]*→\)v[0-9.]*|\1v$NEW|g" "$ROOT/CLAUDE.md"
echo "  CLAUDE.md"

# 4. Reference docs with inline version examples
for f in "$ROOT/excel/references/read-excel.md" "$ROOT/ocr/references/ocr-local.md"; do
    [ -f "$f" ] || continue
    sed -i "s|\"version\": \"[0-9.]*\"|\"version\": \"$NEW\"|g; s|Nong [0-9.]*, expect|Nong $NEW, expect|g" "$f"
    echo "  $(basename "$f")"
done

echo "done — $NEW"
