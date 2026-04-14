#!/usr/bin/env bash
set -euo pipefail

# Resolve the skills directory — this repo IS the skills directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR"

# When piped through curl, BASH_SOURCE[0] may be empty — fallback to a temp clone
if [[ ! -d "$SKILLS_SRC/sdd-init" ]]; then
    echo "Downloading SDD skills from GitHub..."
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    git clone --depth=1 --quiet https://github.com/jorgeferrando/sdd-skills "$TMP_DIR"
    SKILLS_SRC="$TMP_DIR"
fi

# Determine destination
if [[ "${1:-}" == "--global" ]]; then
    DEST="$HOME/.claude/skills"
elif [[ "${1:-}" == "--local" ]]; then
    DEST="$(pwd)/.claude/skills"
else
    echo "Install SDD skills for Claude Code"
    echo ""
    echo "  [1] Global (~/.claude/skills/) — available in all projects"
    echo "  [2] Project-local (.claude/skills/) — current project only"
    echo ""
    read -rp "Choice [1/2]: " choice
    case "$choice" in
        1) DEST="$HOME/.claude/skills" ;;
        2) DEST="$(pwd)/.claude/skills" ;;
        *) echo "Invalid choice. Use 1 or 2."; exit 1 ;;
    esac
fi

mkdir -p "$DEST"
installed=0
skipped=0

for skill_dir in "$SKILLS_SRC"/sdd-*/; do
    skill_name="$(basename "$skill_dir")"
    target="$DEST/$skill_name"
    if [[ -d "$target" ]]; then
        echo "  skip  $skill_name (already exists — delete to reinstall)"
        ((skipped+=1))
    else
        cp -r "$skill_dir" "$target"
        echo "  ✓     $skill_name"
        ((installed+=1))
    fi
done

# Install CLAUDE.md alongside the skills
CLAUDE_DIR="$(dirname "$DEST")"
SDD_CLAUDE="$SKILLS_SRC/CLAUDE.sdd.md"
TARGET_CLAUDE="$CLAUDE_DIR/CLAUDE.md"

if [[ -f "$SDD_CLAUDE" ]]; then
    echo ""
    if [[ ! -f "$TARGET_CLAUDE" ]]; then
        # No CLAUDE.md exists
        echo "  CLAUDE.md not found at $CLAUDE_DIR/"
        echo "    [1] Create CLAUDE.md with SDD context (recommended)"
        echo "    [2] Skip"
        read -rp "  Choice [1/2]: " claude_choice
        case "$claude_choice" in
            1)
                cp "$SDD_CLAUDE" "$TARGET_CLAUDE"
                echo "  ✓     CLAUDE.md created"
                ;;
            *)
                echo "  skip  CLAUDE.md"
                ;;
        esac
    else
        # CLAUDE.md already exists
        echo "  CLAUDE.md already exists at $CLAUDE_DIR/"
        echo "    [1] Overwrite with SDD context"
        echo "    [2] Append SDD context at the end"
        echo "    [3] Save as CLAUDE.sdd.md (keeps existing CLAUDE.md)"
        echo "    [4] Skip"
        read -rp "  Choice [1/2/3/4]: " claude_choice
        case "$claude_choice" in
            1)
                cp "$SDD_CLAUDE" "$TARGET_CLAUDE"
                echo "  ✓     CLAUDE.md overwritten"
                ;;
            2)
                printf "\n\n" >> "$TARGET_CLAUDE"
                cat "$SDD_CLAUDE" >> "$TARGET_CLAUDE"
                echo "  ✓     SDD context appended to CLAUDE.md"
                ;;
            3)
                cp "$SDD_CLAUDE" "$CLAUDE_DIR/CLAUDE.sdd.md"
                echo "  ✓     CLAUDE.sdd.md created (CLAUDE.md unchanged)"
                ;;
            *)
                echo "  skip  CLAUDE.md"
                ;;
        esac
    fi
fi

echo ""
echo "Installed: $installed  Skipped: $skipped"
echo "Destination: $DEST"
echo ""
echo "Restart Claude Code to load the new skills."
echo "Then use /sdd-init to get started."
