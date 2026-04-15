#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Sync SKILL.md from instructions.md in each skill directory
# SKILL.md is required by the Claude plugin system (.claude-plugin/)
# instructions.md is the source of truth (used by all tools)
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
count=0

for dir in "$SCRIPT_DIR"/sdd-*/; do
    src="$dir/instructions.md"
    dst="$dir/SKILL.md"

    if [[ -f "$src" ]]; then
        cp "$src" "$dst"
        count=$((count + 1))
    fi
done

echo "Synced $count SKILL.md files from instructions.md"
