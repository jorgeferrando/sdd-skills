# Installation

## Requirements

- [Claude Code](https://claude.ai/code) — CLI, desktop app, web app, or IDE extension
- Git

No other dependencies. Skills are pure markdown instructions — no Python, Node, or other runtime needed.

## Install methods

### One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/jorgeferrando/sdd-skills/main/install-skills.sh | bash
```

The installer asks whether to install globally or locally:

- **Global** (`~/.claude/skills/`) — available in all projects
- **Local** (`.claude/skills/`) — current project only

### Manual install

```bash
git clone https://github.com/jorgeferrando/sdd-skills
cd sdd-skills
./install-skills.sh --global    # or --local
```

### Direct copy

If you prefer full control:

```bash
git clone https://github.com/jorgeferrando/sdd-skills
cp -r sdd-skills/sdd-* ~/.claude/skills/
```

## After installing

1. **Restart Claude Code** to load the new skills
2. Verify with `/sdd-init` — it should run without errors
3. All `/sdd-*` commands are now available in any project

## Updating

Re-run the installer. It skips skills that already exist — delete a skill directory to force reinstall:

```bash
rm -rf ~/.claude/skills/sdd-apply
./install-skills.sh --global
```

## Uninstalling

```bash
rm -rf ~/.claude/skills/sdd-*
```
