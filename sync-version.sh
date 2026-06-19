#!/bin/bash
# Toolkit.Net version sync script
# Usage: ./sync-version.sh 12.1.0
# Updates all version references across the repo to the given version.

set -euo pipefail

NEW="${1:?Usage: $0 <version>  e.g.  $0 12.1.0}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
YEAR="$(date +%Y)"

echo "=== sync-version.sh → Toolkit.Net $NEW ==="

# ── 1. plugin.json files（root + 22 skill dirs）──
for dir in "$ROOT/.claude-plugin" "$ROOT"/*/; do
    skill=$(basename "$dir")
    pj="$dir/.claude-plugin/plugin.json"
    [ -f "$pj" ] || continue
    # bump version field
    tmp=$(mktemp)
    jq --arg v "$NEW" '.version = $v' "$pj" > "$tmp" && mv "$tmp" "$pj"
    echo "  plugin.json: $skill → $NEW"
done

# ── 2. README files ──
for f in "$ROOT/README.md" "$ROOT/README.zh-CN.md"; do
    [ -f "$f" ] || continue
    sed -i "s|Nong\.Cli\.Net [0-9.]* / [0-9]*|Nong.Cli.Net $NEW / 332|g" "$f"
    echo "  README: $f"
done

# ── 3. CLAUDE.md ──
sed -i "s|适配 [0-9.]*|适配 $NEW|g" "$ROOT/CLAUDE.md"
sed -i "s|\(v[0-9.]*→\)v[0-9.]*|\1v$NEW|g" "$ROOT/CLAUDE.md"
echo "  CLAUDE.md"

# ── 4. Reference docs with version examples ──
for f in "$ROOT/excel/references/read-excel.md" "$ROOT/ocr/references/ocr-local.md"; do
    [ -f "$f" ] || continue
    sed -i "s|\"[0-9.]*\"|\"$NEW\"|g" "$f"
    sed -i "s|Nong [0-9.]*, expect|Nong $NEW, expect|g" "$f"
    echo "  ref: $f"
done

# ── 5. marketplace.json ──
[ -f "$ROOT/.claude-plugin/marketplace.json" ] && {
    tmp=$(mktemp)
    jq --arg v "$NEW" '.version = $v' "$ROOT/.claude-plugin/marketplace.json" > "$tmp" && mv "$tmp" "$ROOT/.claude-plugin/marketplace.json"
    echo "  marketplace.json"
}

echo ""
echo "done. verify: grep -rn '12\\.1\\|$NEW' --include='*.json' --include='*.md' . | head -5"
