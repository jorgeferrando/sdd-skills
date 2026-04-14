# The Openspec Directory

All SDD artifacts live in `openspec/`. It is the single source of truth for what the system does and why decisions were made.

## Structure

```
openspec/
├── config.yaml                         # Project configuration
├── INDEX.md                            # Domain index with descriptions
├── steering/                           # Project context (see Steering Files)
│   ├── product.md
│   ├── tech.md
│   ├── structure.md
│   ├── conventions.md
│   ├── environment.md
│   ├── project-skill.md
│   └── project-rules.md
├── specs/                              # Canonical specs (current system state)
│   ├── core/
│   │   └── spec.md
│   ├── auth/
│   │   └── spec.md
│   └── {domain}/
│       └── spec.md
└── changes/                            # Active and archived changes
    ├── add-user-auth/                  # Active change
    │   ├── proposal.md
    │   ├── specs/auth/spec.md          # Delta spec
    │   ├── design.md
    │   └── tasks.md
    └── archive/                        # Completed changes
        ├── 2026-03-01-bootstrap/
        ├── 2026-03-02-add-login/
        └── ...
```

## Canonical specs vs delta specs

There are two types of specs:

**Canonical specs** (`openspec/specs/{domain}/spec.md`)
:   Represent the **current state** of the system. Updated automatically when a change is archived. This is what the system does *right now*.

**Delta specs** (`openspec/changes/{change}/specs/{domain}/spec.md`)
:   Represent **what changes** in a specific change. Only the new or modified behaviors are documented — not the full spec. Merged into canonical on archive.

This separation means you can always see:

- What the system does today → canonical specs
- What a specific change introduced → delta specs in the archive
- What's about to change → delta specs in active changes

## config.yaml

Created by `/sdd-init`:

```yaml
project: my-app
created_at: 2026-03-01

paths:
  specs: openspec/specs
  changes: openspec/changes
  archive: openspec/changes/archive
  steering: openspec/steering

steering:
  project_skill: openspec/steering/project-skill.md

environment:
  mcps: [context7, github]
  tools: [git, gh, docker, uv]
```

## INDEX.md

A domain index created/updated by `/sdd-discover` and `/sdd-archive`:

```markdown
# Domain Index

| Domain | Description | Key Entities | Keywords |
|--------|-------------|-------------|----------|
| core | Core business logic | User, Account | auth, registration |
| api | REST API endpoints | Request, Response | http, routes |
| tui | Terminal interface | Screen, Widget | textual, ui |
```

## Git and openspec

By default, `/sdd-init` excludes `openspec/` from git via `.git/info/exclude`. This keeps it local — useful when you don't want to commit AI-generated artifacts.

If your team wants to share openspec (recommended for teams > 1), commit it:

```bash
# Remove the exclusion
sed -i '/openspec\//d' .git/info/exclude
git add openspec/
git commit -m "Add openspec directory"
```
