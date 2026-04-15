# SDD Skills

**Spec-Driven Development skills for AI coding assistants.**

Works with [Claude Code](https://claude.ai/code), [Cursor](https://cursor.com), [Codex](https://openai.com/codex), and [GitHub Copilot](https://github.com/features/copilot).

SDD is a methodology where every code change starts with a specification — not code. These skills guide the AI through a structured workflow that ensures what you build matches what you intended, with full traceability from problem statement to implementation.

## Why SDD?

Without structure, AI-assisted development can produce code that works but drifts from intent. SDD solves this by making every decision explicit and traceable:

- **Specifications before code** — define behavior, then implement
- **Atomic commits** — one task, one file, one commit
- **Living documentation** — specs are always up to date with the codebase
- **Project memory** — conventions and rules survive across sessions

## How it works

```mermaid
graph LR
    A[You describe what you want] --> B["/sdd-new"]
    B --> C[proposal]
    C --> D[spec]
    D --> E[design]
    E --> F[tasks]
    F --> G["/sdd-apply"]
    G --> H[code + commits]
    H --> I["/sdd-verify"]
    I --> J["/sdd-archive"]
    J --> K[canonical specs updated]
```

Skills are **project-agnostic**. They work with any language, framework, or stack. Project-specific knowledge lives in steering files generated during setup.

## Quick start

```bash
# Install skills
curl -fsSL https://raw.githubusercontent.com/jorgeferrando/sdd-skills/main/install-skills.sh | bash

# In your project
/sdd-init                    # Set up project context
/sdd-new "add user auth"     # Start a change
/sdd-continue                # Advance to next phase
```

## What you get

| What | Where | Purpose |
|------|-------|---------|
| 17 skills | Installed per tool | Process automation |
| Steering files | `openspec/steering/` | Project context |
| Canonical specs | `openspec/specs/` | Living documentation |
| Change artifacts | `openspec/changes/` | Traceability |
