#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# SDD Skills installer — supports multiple AI coding tools
# ---------------------------------------------------------------------------

REPO_URL="https://github.com/jorgeferrando/sdd-skills"

# Colors (disabled if not a terminal)
if [[ -t 1 ]]; then
    GREEN="\033[32m"
    YELLOW="\033[33m"
    CYAN="\033[36m"
    BOLD="\033[1m"
    DIM="\033[2m"
    RESET="\033[0m"
else
    GREEN="" YELLOW="" CYAN="" BOLD="" DIM="" RESET=""
fi

# Resolve the skills directory — this repo IS the skills directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR"

# When piped through curl, BASH_SOURCE[0] may be empty — fallback to a temp clone
if [[ ! -d "$SKILLS_SRC/skills/sdd-init" ]]; then
    echo "Downloading SDD skills from GitHub..."
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    git clone --depth=1 --quiet "$REPO_URL" "$TMP_DIR"
    SKILLS_SRC="$TMP_DIR"
fi

SDD_CONTEXT="$SKILLS_SRC/sdd-context.md"
INSTRUCTION_FILE="instructions.md"

# All available skills (in workflow order)
ALL_SKILLS=(
    sdd-init sdd-discover sdd-steer
    sdd-new sdd-explore sdd-propose sdd-spec
    sdd-design sdd-tasks sdd-apply
    sdd-verify sdd-archive
    sdd-ff sdd-continue sdd-audit sdd-docs
)

# Parse flags
SELECTED_SKILLS=()
DRY_RUN=false
TOOL_FLAG=""

for arg in "$@"; do
    case "$arg" in
        --claude|--cursor|--codex|--copilot) TOOL_FLAG="$arg" ;;
        --global|--local) SCOPE_FLAG="$arg" ;;
        --dry-run) DRY_RUN=true ;;
        --all) SELECTED_SKILLS=("${ALL_SKILLS[@]}") ;;
        sdd-*) SELECTED_SKILLS+=("$arg") ;;
    esac
done

# ---------------------------------------------------------------------------
# Tool detection and configuration
# ---------------------------------------------------------------------------

detect_tool() {
    case "${TOOL_FLAG:-}" in
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

tool_config() {
    local tool="$1"
    local scope="$2"

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
# Skill selection
# ---------------------------------------------------------------------------

select_skills() {
    echo ""
    echo -e "  ${BOLD}Available skills:${RESET}"
    echo ""
    echo -e "  ${DIM}Setup${RESET}"
    echo "    sdd-init        sdd-discover      sdd-steer"
    echo ""
    echo -e "  ${DIM}Lifecycle${RESET}"
    echo "    sdd-new         sdd-explore       sdd-propose       sdd-spec"
    echo "    sdd-design      sdd-tasks         sdd-apply"
    echo "    sdd-verify      sdd-archive"
    echo ""
    echo -e "  ${DIM}Shortcuts & utilities${RESET}"
    echo "    sdd-ff          sdd-continue      sdd-audit         sdd-docs"
    echo ""
    echo -e "  Install ${BOLD}[a]ll${RESET} 16 skills or ${BOLD}[s]elect${RESET} specific ones?"
    read -rp "  Choice [a/s]: " sel_choice

    case "$sel_choice" in
        s|S)
            echo ""
            echo "  Enter skill names separated by spaces:"
            echo -e "  ${DIM}Example: sdd-init sdd-apply sdd-verify${RESET}"
            read -rp "  > " skill_input
            # shellcheck disable=SC2206
            SELECTED_SKILLS=($skill_input)

            # Validate
            for s in "${SELECTED_SKILLS[@]}"; do
                if [[ ! -d "$SKILLS_SRC/skills/$s" ]]; then
                    echo -e "  ${YELLOW}Warning:${RESET} '$s' not found — skipping"
                fi
            done
            ;;
        *)
            SELECTED_SKILLS=("${ALL_SKILLS[@]}")
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
    local selected=0

    for skill_name in "${SELECTED_SKILLS[@]}"; do
        local skill_dir="$SKILLS_SRC/skills/$skill_name"
        local target="$SKILLS_DEST/$skill_name"

        [[ -d "$skill_dir" ]] || continue
        ((selected+=1))

        if [[ -d "$target" ]]; then
            echo -e "  ${YELLOW}skip${RESET}   $skill_name ${DIM}(already exists — delete to reinstall)${RESET}"
            ((skipped+=1))
        else
            mkdir -p "$target"
            if [[ -f "$skill_dir/instructions.md" ]]; then
                cp "$skill_dir/instructions.md" "$target/$SKILL_FILENAME"
            fi
            echo -e "  ${GREEN}✓${RESET}      $skill_name"
            ((installed+=1))
        fi
    done

    echo ""
    echo -e "  Skills: ${GREEN}$installed installed${RESET}, $skipped skipped"
    echo -e "  Destination: ${CYAN}$SKILLS_DEST${RESET}"
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
                echo -e "  ${GREEN}✓${RESET}      $CONTEXT_FILENAME created"
                ;;
            *)
                echo -e "  ${YELLOW}skip${RESET}   $CONTEXT_FILENAME"
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
                echo -e "  ${GREEN}✓${RESET}      $CONTEXT_FILENAME overwritten"
                ;;
            2)
                printf "\n\n" >> "$target"
                cat "$SDD_CONTEXT" >> "$target"
                echo -e "  ${GREEN}✓${RESET}      SDD context appended to $CONTEXT_FILENAME"
                ;;
            3)
                cp "$SDD_CONTEXT" "$CONTEXT_DIR/sdd-context.md"
                if ! grep -q "sdd-context.md" "$target" 2>/dev/null; then
                    printf "\n\n<!-- SDD workflow context -->\nSee [sdd-context.md](sdd-context.md) for SDD (Spec-Driven Development) workflow rules.\n" >> "$target"
                    echo -e "  ${GREEN}✓${RESET}      sdd-context.md created + referenced in $CONTEXT_FILENAME"
                else
                    echo -e "  ${GREEN}✓${RESET}      sdd-context.md created (already referenced)"
                fi
                ;;
            *)
                echo -e "  ${YELLOW}skip${RESET}   $CONTEXT_FILENAME"
                ;;
        esac
    fi
}

# ---------------------------------------------------------------------------
# Dry-run summary
# ---------------------------------------------------------------------------

show_dry_run() {
    local tool_label
    tool_label="$(echo "$TOOL" | sed 's/.*/\u&/')"

    echo ""
    echo -e "${BOLD}Dry run — nothing will be installed${RESET}"
    echo ""
    echo -e "  Tool:        ${CYAN}$tool_label${RESET}"
    echo -e "  Scope:       $SCOPE"
    echo -e "  Destination: ${CYAN}$SKILLS_DEST${RESET}"
    echo -e "  Skills:      ${#SELECTED_SKILLS[@]}"
    echo ""

    for s in "${SELECTED_SKILLS[@]}"; do
        local target="$SKILLS_DEST/$s"
        if [[ -d "$target" ]]; then
            echo -e "  ${YELLOW}skip${RESET}   $s ${DIM}(already exists)${RESET}"
        else
            echo -e "  ${GREEN}new${RESET}    $s"
        fi
    done

    if [[ -f "$SDD_CONTEXT" ]]; then
        local ctx_target="$CONTEXT_DIR/$CONTEXT_FILENAME"
        echo ""
        if [[ -f "$ctx_target" ]]; then
            echo -e "  Context: ${YELLOW}$CONTEXT_FILENAME exists${RESET} — will ask how to handle"
        else
            echo -e "  Context: ${GREEN}$CONTEXT_FILENAME will be created${RESET}"
        fi
    fi

    echo ""
    echo "  Run without --dry-run to install."
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

TOOL=$(detect_tool)

if [[ -z "$TOOL" ]]; then
    echo -e "${BOLD}Install SDD skills${RESET}"
    echo ""
    echo "  Which AI coding tool do you use?"
    echo -e "    [1] Claude Code"
    echo -e "    [2] Cursor"
    echo -e "    [3] Codex (OpenAI)"
    echo -e "    [4] GitHub Copilot"
    echo ""
    read -rp "  Choice [1/2/3/4]: " tool_choice
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
    case "${SCOPE_FLAG:-}" in
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

# Skill selection (if not already specified via CLI args)
if [[ ${#SELECTED_SKILLS[@]} -eq 0 ]]; then
    select_skills
fi

# Dry-run or install
if $DRY_RUN; then
    show_dry_run
    exit 0
fi

echo ""
echo -e "${BOLD}Installing SDD skills for $(echo "$TOOL" | sed 's/.*/\u&/')...${RESET}"
echo ""

install_skills
install_context

echo ""
echo -e "${GREEN}Done!${RESET} Restart your editor to load the new skills."
echo "Then use /sdd-init (or equivalent) to get started."
