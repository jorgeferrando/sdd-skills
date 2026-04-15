#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# SDD Skills validation script
# Checks skill structure, frontmatter, sync status, and plugin.json consistency
# Exit code 0 = all checks pass, 1 = errors found
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
PLUGIN_JSON="$SCRIPT_DIR/.claude-plugin/plugin.json"

errors=0
warnings=0
checked=0

red="\033[31m"
green="\033[32m"
yellow="\033[33m"
reset="\033[0m"

error() { echo -e "  ${red}ERROR${reset}  $1"; ((errors+=1)); }
warn()  { echo -e "  ${yellow}WARN${reset}   $1"; }
ok()    { echo -e "  ${green}OK${reset}     $1"; }

# ---------------------------------------------------------------------------
# 1. Validate each skill directory
# ---------------------------------------------------------------------------

echo "Validating skills in $SKILLS_DIR/"
echo ""

for skill_dir in "$SKILLS_DIR"/sdd-*/; do
    skill_name="$(basename "$skill_dir")"
    ((checked+=1))

    # --- instructions.md exists ---
    if [[ ! -f "$skill_dir/instructions.md" ]]; then
        error "$skill_name: missing instructions.md"
        continue
    fi

    # --- SKILL.md exists ---
    if [[ ! -f "$skill_dir/SKILL.md" ]]; then
        error "$skill_name: missing SKILL.md (run sync-skills.sh)"
        continue
    fi

    # --- SKILL.md matches instructions.md ---
    if ! diff -q "$skill_dir/instructions.md" "$skill_dir/SKILL.md" > /dev/null 2>&1; then
        error "$skill_name: SKILL.md differs from instructions.md (run sync-skills.sh)"
    fi

    # --- Frontmatter: name field ---
    fm_name=$(sed -n '/^---$/,/^---$/{ /^name:/p }' "$skill_dir/instructions.md" | head -1 | sed 's/^name:[[:space:]]*//')
    if [[ -z "$fm_name" ]]; then
        error "$skill_name: frontmatter missing 'name' field"
    elif [[ "$fm_name" != "$skill_name" ]]; then
        error "$skill_name: frontmatter name '$fm_name' does not match directory name"
    fi

    # --- Frontmatter: description field ---
    fm_desc=$(sed -n '/^---$/,/^---$/{ /^description:/p }' "$skill_dir/instructions.md" | head -1 | sed 's/^description:[[:space:]]*//')
    if [[ -z "$fm_desc" ]]; then
        error "$skill_name: frontmatter missing 'description' field"
    fi

    # --- No errors for this skill ---
    if [[ $errors -eq 0 ]] || ! echo "$skill_name" | grep -q "ERROR"; then
        ok "$skill_name"
    fi
done

# ---------------------------------------------------------------------------
# 2. Validate plugin.json references
# ---------------------------------------------------------------------------

echo ""
echo "Validating plugin.json"
echo ""

if [[ ! -f "$PLUGIN_JSON" ]]; then
    error "plugin.json not found at $PLUGIN_JSON"
else
    # Check each skill directory is listed in plugin.json
    for skill_dir in "$SKILLS_DIR"/sdd-*/; do
        skill_name="$(basename "$skill_dir")"
        expected="./skills/$skill_name"
        if ! grep -q "\"$expected\"" "$PLUGIN_JSON"; then
            error "plugin.json: missing entry for $expected"
        fi
    done

    # Check plugin.json doesn't reference non-existent skills
    while IFS= read -r entry; do
        entry_clean=$(echo "$entry" | tr -d '", ')
        if [[ "$entry_clean" == ./skills/sdd-* ]]; then
            dir_name="${entry_clean#./skills/}"
            if [[ ! -d "$SKILLS_DIR/$dir_name" ]]; then
                error "plugin.json: references non-existent skill $entry_clean"
            fi
        fi
    done < <(grep '"./skills/sdd-' "$PLUGIN_JSON")

    # Count skills in plugin.json
    plugin_count=$(grep -c '"./skills/sdd-' "$PLUGIN_JSON")
    dir_count=$(find "$SKILLS_DIR" -maxdepth 1 -type d -name 'sdd-*' | wc -l | tr -d ' ')

    if [[ "$plugin_count" -ne "$dir_count" ]]; then
        error "plugin.json lists $plugin_count skills but found $dir_count skill directories"
    else
        ok "plugin.json: $plugin_count skills match $dir_count directories"
    fi
fi

# ---------------------------------------------------------------------------
# 3. Validate docs pages exist
# ---------------------------------------------------------------------------

echo ""
echo "Validating docs"
echo ""

for skill_dir in "$SKILLS_DIR"/sdd-*/; do
    skill_name="$(basename "$skill_dir")"
    doc_page="$SCRIPT_DIR/docs/skills/$skill_name.md"
    if [[ ! -f "$doc_page" ]]; then
        error "docs: missing page for $skill_name at docs/skills/$skill_name.md"
    fi
done

doc_pages=$(find "$SCRIPT_DIR/docs/skills" -name 'sdd-*.md' 2>/dev/null | wc -l | tr -d ' ')
ok "docs: $doc_pages skill pages found"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Checked: $checked skills"
echo -e "Errors:  ${errors}"
echo ""

if [[ $errors -gt 0 ]]; then
    echo -e "${red}FAILED${reset} — fix errors above"
    exit 1
else
    echo -e "${green}ALL CHECKS PASSED${reset}"
    exit 0
fi
