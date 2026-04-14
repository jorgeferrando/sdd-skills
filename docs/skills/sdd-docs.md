# /sdd-docs

> Generate publishable MkDocs documentation from openspec/.

## Usage

```
/sdd-docs
```

## Prerequisites

- `openspec/` exists in the project
- For AI-enriched content: `ANTHROPIC_API_KEY` environment variable set

## What it does

Runs `sdd-docs --fill --force` to generate a complete documentation site:

| Output | Content |
|--------|---------|
| `mkdocs.yml` | MkDocs Material config with nav, Mermaid, theme |
| `docs/index.md` | Narrative homepage (problem, tools, quick start, diagram) |
| `docs/reference/{domain}.md` | One page per domain (prose + requirement/decision tables) |
| `docs/changelog.md` | Generated from `openspec/changes/archive/` |

## With vs without API key

| Mode | Command | Result |
|------|---------|--------|
| With API key | `sdd-docs --fill --force` | Fully written documentation, no placeholders |
| Without API key | `sdd-docs --force` | Templates with `{placeholder}` markers to fill manually |

## Supported LLM providers

- `ANTHROPIC_API_KEY` — Claude (Haiku by default)

## After generating

Preview locally:

```bash
mkdocs serve
```

Deploy to GitHub Pages:

```bash
mkdocs gh-deploy
```

!!! note
    This skill requires the `sdd-tui` package with the `fill` extra: `pip install sdd-tui[fill]`. The docs generation is a Python CLI tool, not a pure skill.
