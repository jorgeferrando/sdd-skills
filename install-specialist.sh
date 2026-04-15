#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# SDD Specialist installer
# Copies specialist steering files into the project's openspec/steering/
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECIALISTS_DIR="$SCRIPT_DIR/specialists"
TARGET_DIR="openspec/steering"

# Colors
if [[ -t 1 ]]; then
    GREEN="\033[32m" YELLOW="\033[33m" CYAN="\033[36m"
    BOLD="\033[1m" DIM="\033[2m" RESET="\033[0m"
else
    GREEN="" YELLOW="" CYAN="" BOLD="" DIM="" RESET=""
fi

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo -e "${BOLD}Install SDD specialists${RESET}"
    echo ""
    echo "  Usage:"
    echo "    ./install-specialist.sh                # list available specialists"
    echo "    ./install-specialist.sh <name>          # install a specialist"
    echo "    ./install-specialist.sh --all           # install all specialists"
    echo "    ./install-specialist.sh --remove <name> # remove a specialist"
    echo ""
    echo "  Specialists add domain-specific conventions to openspec/steering/"
    echo "  that are read by sdd-apply, sdd-audit, and sdd-verify."
    exit 0
fi

# ---------------------------------------------------------------------------
# List available specialists
# ---------------------------------------------------------------------------

if [[ $# -eq 0 ]]; then
    echo -e "${BOLD}Available specialists:${RESET}"
    echo ""
    for dir in "$SPECIALISTS_DIR"/*/; do
        [[ -f "$dir/manifest.yaml" ]] || continue
        name=$(basename "$dir")
        desc=$(grep "^description:" "$dir/manifest.yaml" | sed 's/^description:[[:space:]]*//')
        installed=""
        # Check if any file from this specialist is in steering
        for f in "$dir"/*.md; do
            fname=$(basename "$f")
            if [[ -f "$TARGET_DIR/$fname" ]]; then
                installed=" ${GREEN}(installed)${RESET}"
                break
            fi
        done
        echo -e "  ${CYAN}$name${RESET}$installed"
        echo -e "    ${DIM}$desc${RESET}"
        echo ""
    done
    echo "  Run: ./install-specialist.sh <name>"
    exit 0
fi

# ---------------------------------------------------------------------------
# Remove
# ---------------------------------------------------------------------------

if [[ "${1:-}" == "--remove" ]]; then
    name="${2:?Specify specialist name to remove}"
    spec_dir="$SPECIALISTS_DIR/$name"
    [[ -d "$spec_dir" ]] || { echo "Specialist '$name' not found."; exit 1; }

    removed=0
    for f in "$spec_dir"/*.md; do
        fname=$(basename "$f")
        target="$TARGET_DIR/$fname"
        if [[ -f "$target" ]]; then
            rm "$target"
            echo -e "  ${GREEN}removed${RESET}  $fname"
            ((removed+=1))
        fi
    done
    echo ""
    echo "$removed file(s) removed from $TARGET_DIR/"
    exit 0
fi

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "openspec/steering/ not found. Run /sdd-init first."
    exit 1
fi

install_specialist() {
    local name="$1"
    local spec_dir="$SPECIALISTS_DIR/$name"

    if [[ ! -d "$spec_dir" ]]; then
        echo "Specialist '$name' not found."
        echo "Run without arguments to list available specialists."
        return 1
    fi

    local installed=0
    for f in "$spec_dir"/*.md; do
        fname=$(basename "$f")
        target="$TARGET_DIR/$fname"
        if [[ -f "$target" ]]; then
            echo -e "  ${YELLOW}skip${RESET}   $fname ${DIM}(already exists)${RESET}"
        else
            cp "$f" "$target"
            echo -e "  ${GREEN}✓${RESET}      $fname"
            ((installed+=1))
        fi
    done
    echo -e "  ${DIM}→ Active for sdd-apply, sdd-audit, sdd-verify${RESET}"
    return 0
}

if [[ "$1" == "--all" ]]; then
    for dir in "$SPECIALISTS_DIR"/*/; do
        [[ -f "$dir/manifest.yaml" ]] || continue
        name=$(basename "$dir")
        echo -e "${BOLD}$name${RESET}"
        install_specialist "$name"
        echo ""
    done
else
    echo -e "${BOLD}Installing specialist: $1${RESET}"
    echo ""
    install_specialist "$1"
fi

echo ""
echo -e "${GREEN}Done.${RESET} Specialists are now active in the SDD workflow."
