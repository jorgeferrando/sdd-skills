# Installation

## Requirements

- An AI coding assistant: [Claude Code](https://claude.ai/code), [Cursor](https://cursor.com), [Codex](https://openai.com/codex), or [GitHub Copilot](https://github.com/features/copilot)
- Git

No other dependencies. Skills are pure markdown instructions — no Python, Node, or other runtime needed.

## Install methods

### One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/jorgeferrando/sdd-skills/main/install-skills.sh | bash
```

The installer auto-detects your AI tool, or you can specify it:

```bash
./install-skills.sh --claude    # Claude Code
./install-skills.sh --cursor    # Cursor
./install-skills.sh --codex     # Codex (OpenAI)
./install-skills.sh --copilot   # GitHub Copilot
```

### Manual install

```bash
git clone https://github.com/jorgeferrando/sdd-skills
cd sdd-skills
./install-skills.sh
```

### Where skills are installed

| Tool | Skills destination | Context file |
|------|-------------------|-------------|
| Claude Code | `~/.claude/skills/` or `.claude/skills/` | `CLAUDE.md` |
| Cursor | `.cursor/rules/sdd/` | `.cursor/rules/sdd.md` |
| Codex | `.sdd/skills/` | `AGENTS.md` |
| GitHub Copilot | `.github/sdd/` | `.github/copilot-instructions.md` |

## After installing

1. **Restart your editor** to load the new skills
2. Verify with `/sdd-init` — it should run without errors
3. All `/sdd-*` commands are now available

## Updating

Re-run the installer. It skips skills that already exist — delete a skill directory to force reinstall:

```bash
./install-skills.sh
```

## Uninstalling

Remove the skills directory for your tool (see table above).
