#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# SDD Skills installer — supports multiple AI coding tools
# ---------------------------------------------------------------------------

REPO_URL="https://github.com/jorgeferrando/sdd-skills"

# Resolve the skills directory — this repo IS the skills directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR"

# When piped through curl, BASH_SOURCE[0] may be empty — fallback to a temp clone
if [[ ! -d "$SKILLS_SRC/sdd-init" ]]; then
    echo "Downloading SDD skills from GitHub..."
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    git clone --depth=1 --quiet "$REPO_URL" "$TMP_DIR"
    SKILLS_SRC="$TMP_DIR"
fi

SDD_CONTEXT="$SKILLS_SRC/sdd-context.md"
INSTRUCTION_FILE="instructions.md"

# ---------------------------------------------------------------------------
# Tool detection and configuration
# ---------------------------------------------------------------------------

detect_tool() {
    # Check flags first
    case "${1:-}" in
        --claude)  echo "claude"; return ;;
        --cursor)  echo "cursor"; return ;;
        --codex)   echo "codex"; return ;;
        --copilot) echo "copilot"; return ;;
    esac

    # Auto-detect from environment
    if command -v claude &>/dev/null; then
        echo "claude"
    elif [[ -d ".cursor" ]]; then
        echo "cursor"
    elif [[ -f "AGENTS.md" ]]; then
        echo "codex"
    elif [[ -d ".github" ]]; then
        echo "copilot"
    else
        echo ""
    fi
}

# Per-tool configuration:
#   skills_dir     — where skill folders go
#   context_file   — project context filename
#   skill_filename — what to name the instruction file inside each skill dir
tool_config() {
    local tool="$1"
    local scope="$2"  # global or local

    case "$tool" in
        claude)
            if [[ "$scope" == "global" ]]; then
                SKILLS_DEST="$HOME/.claude/skills"
                CONTEXT_DIR="$HOME/.claude"
            else
                SKILLS_DEST="$(pwd)/.claude/skills"
                CONTEXT_DIR="$(pwd)/.claude"
            fi
            CONTEXT_FILENAME="CLAUDE.md"
            SKILL_FILENAME="SKILL.md"
            ;;
        cursor)
            SKILLS_DEST="$(pwd)/.cursor/rules/sdd"
            CONTEXT_DIR="$(pwd)/.cursor/rules"
            CONTEXT_FILENAME="sdd.md"
            SKILL_FILENAME="instructions.md"
            ;;
        codex)
            SKILLS_DEST="$(pwd)/.sdd/skills"
            CONTEXT_DIR="$(pwd)"
            CONTEXT_FILENAME="AGENTS.md"
            SKILL_FILENAME="instructions.md"
            ;;
        copilot)
            SKILLS_DEST="$(pwd)/.github/sdd"
            CONTEXT_DIR="$(pwd)/.github"
            CONTEXT_FILENAME="copilot-instructions.md"
            SKILL_FILENAME="instructions.md"
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Skill installation
# ---------------------------------------------------------------------------

install_skills() {
    mkdir -p "$SKILLS_DEST"
    local installed=0
    local skipped=0

    for skill_dir in "$SKILLS_SRC"/sdd-*/; do
        local skill_name
        skill_name="$(basename "$skill_dir")"
        local target="$SKILLS_DEST/$skill_name"

        if [[ -d "$target" ]]; then
            echo "  skip  $skill_name (already exists — delete to reinstall)"
            ((skipped+=1))
        else
            mkdir -p "$target"
            # Copy and rename instruction file
            if [[ -f "$skill_dir/instructions.md" ]]; then
                cp "$skill_dir/instructions.md" "$target/$SKILL_FILENAME"
            fi
            echo "  ✓     $skill_name"
            ((installed+=1))
        fi
    done

    echo ""
    echo "Skills: $installed installed, $skipped skipped"
    echo "Destination: $SKILLS_DEST"
}

# ---------------------------------------------------------------------------
# Context file installation
# ---------------------------------------------------------------------------

install_context() {
    [[ -f "$SDD_CONTEXT" ]] || return 0

    local target="$CONTEXT_DIR/$CONTEXT_FILENAME"
    mkdir -p "$CONTEXT_DIR"

    echo ""
    if [[ ! -f "$target" ]]; then
        echo "  $CONTEXT_FILENAME not found at $CONTEXT_DIR/"
        echo "    [1] Create $CONTEXT_FILENAME with SDD context (recommended)"
        echo "    [2] Skip"
        read -rp "  Choice [1/2]: " ctx_choice
        case "$ctx_choice" in
            1)
                cp "$SDD_CONTEXT" "$target"
                echo "  ✓     $CONTEXT_FILENAME created"
                ;;
            *)
                echo "  skip  $CONTEXT_FILENAME"
                ;;
        esac
    else
        echo "  $CONTEXT_FILENAME already exists at $CONTEXT_DIR/"
        echo "    [1] Overwrite with SDD context"
        echo "    [2] Append SDD context at the end"
        echo "    [3] Save as sdd-context.md (keeps existing $CONTEXT_FILENAME)"
        echo "    [4] Skip"
        read -rp "  Choice [1/2/3/4]: " ctx_choice
        case "$ctx_choice" in
            1)
                cp "$SDD_CONTEXT" "$target"
                echo "  ✓     $CONTEXT_FILENAME overwritten"
                ;;
            2)
                printf "\n\n" >> "$target"
                cat "$SDD_CONTEXT" >> "$target"
                echo "  ✓     SDD context appended to $CONTEXT_FILENAME"
                ;;
            3)
                cp "$SDD_CONTEXT" "$CONTEXT_DIR/sdd-context.md"
                if ! grep -q "sdd-context.md" "$target" 2>/dev/null; then
                    printf "\n\n<!-- SDD workflow context -->\nSee [sdd-context.md](sdd-context.md) for SDD (Spec-Driven Development) workflow rules.\n" >> "$target"
                    echo "  ✓     sdd-context.md created + referenced in $CONTEXT_FILENAME"
                else
                    echo "  ✓     sdd-context.md created (already referenced)"
                fi
                ;;
            *)
                echo "  skip  $CONTEXT_FILENAME"
                ;;
        esac
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

TOOL=$(detect_tool "${1:-}")

if [[ -z "$TOOL" ]]; then
    echo "Install SDD skills"
    echo ""
    echo "  Which AI coding tool do you use?"
    echo "    [1] Claude Code"
    echo "    [2] Cursor"
    echo "    [3] Codex (OpenAI)"
    echo "    [4] GitHub Copilot"
    echo ""
    read -rp "Choice [1/2/3/4]: " tool_choice
    case "$tool_choice" in
        1) TOOL="claude" ;;
        2) TOOL="cursor" ;;
        3) TOOL="codex" ;;
        4) TOOL="copilot" ;;
        *) echo "Invalid choice."; exit 1 ;;
    esac
fi

# Scope selection (global only for Claude Code)
SCOPE="local"
if [[ "$TOOL" == "claude" ]]; then
    # Check if --global or --local was passed as second arg
    case "${2:-}" in
        --global) SCOPE="global" ;;
        --local)  SCOPE="local" ;;
        *)
            echo ""
            echo "  [1] Global (~/.claude/skills/) — available in all projects"
            echo "  [2] Project-local (.claude/skills/) — current project only"
            echo ""
            read -rp "  Choice [1/2]: " scope_choice
            case "$scope_choice" in
                1) SCOPE="global" ;;
                *) SCOPE="local" ;;
            esac
            ;;
    esac
fi

tool_config "$TOOL" "$SCOPE"

echo ""
echo "Installing SDD skills for $(echo "$TOOL" | sed 's/.*/\u&/')..."
echo ""

install_skills
install_context

echo ""
echo "Done! Restart your editor to load the new skills."
echo "Then use /sdd-init (or equivalent) to get started."
