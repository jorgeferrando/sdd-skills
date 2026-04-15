# SDD Skills

Skills for AI coding assistants that implement the **Spec-Driven Development (SDD)** workflow. Each skill is a self-contained set of instructions that guides the AI through a specific phase of the development cycle.

Works with **Claude Code**, **Cursor**, **Codex (OpenAI)**, and **GitHub Copilot**.

SDD is a methodology where every code change starts with a **specification** — not code. The workflow ensures that what you build matches what you intended, with full traceability from problem statement to implementation.

## How it works

```
You describe what you want
        |
   AI follows the SDD workflow
        |
   spec -> design -> tasks -> code -> verify
        |
   Every decision is documented in openspec/
```

Skills are **project-agnostic** and **LLM-agnostic**. They work with any language, framework, or stack. Project-specific knowledge lives in `openspec/steering/` files generated during setup — skills read those files to adapt their behavior.

## Install

### Claude Code plugin

```bash
claude plugin install jorgeferrando/sdd-skills
```

### One-liner (all tools)

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

### Manual

```bash
git clone https://github.com/jorgeferrando/sdd-skills
cd sdd-skills
./install-skills.sh
```

After installing, restart your editor. All `/sdd-*` commands become available.

## Quick start

```
/sdd-init                    # Set up a new project (or onboard an existing one)
/sdd-new "add user auth"     # Start a new change
/sdd-continue                # Advance to the next phase automatically
```

Or use fast-forward for small, clear-scope changes:

```
/sdd-ff "add health check endpoint"    # propose + spec + design + tasks in one pass
/sdd-apply                              # implement task by task
/sdd-verify                             # final quality checks
/sdd-archive                            # close the cycle, merge specs
```

For a detailed walkthrough of each step — why it runs, what it produces, and how to advance — see the **[Quick Start Guide](https://jorgeferrando.github.io/sdd-skills/getting-started/)**.

---

## The SDD workflow

### Phase diagram

```
                          /sdd-ff (fast path)
                    ┌─────────────────────────────────┐
                    |                                   |
                    v                                   v
/sdd-new ──> propose ──> spec ──> design ──> tasks ──> apply ──> verify ──> archive
                                                         |
               /sdd-continue (detects next phase) <──────┘
```

### Lifecycle of a change

Every feature, bugfix, or refactor follows the same cycle:

| Phase | Skill | Artifact | Mode |
|-------|-------|----------|------|
| 1. Explore | `/sdd-explore` | `notes.md` | Inline |
| 2. Propose | `/sdd-propose` | `proposal.md` | Inline (interactive) |
| 3. Spec | `/sdd-spec` | `specs/{domain}/spec.md` | Inline (interactive) |
| 4. Design | `/sdd-design` | `design.md` | Agent (non-interactive) |
| 5. Tasks | `/sdd-tasks` | `tasks.md` | Inline (interactive) |
| 6. Apply | `/sdd-apply` | code + commits | Agent per task |
| 7. Verify | `/sdd-verify` | report + PR | Agent (non-interactive) |
| 8. Archive | `/sdd-archive` | canonical specs | Inline |

All artifacts live under `openspec/changes/{change-name}/`.

---

## Skills reference

### Setup & context

#### `/sdd-init`

Bootstrap a new project for SDD. Creates the `openspec/` directory structure and runs a guided questionnaire to generate steering files.

```
/sdd-init
```

**What it does:**
- Creates `openspec/` with `specs/`, `changes/`, `steering/` directories
- Scans the environment (runtimes, tools, Docker containers, config files)
- Asks about the project: what it builds, for whom, boundaries
- If no code exists: asks about stack, framework, database, architecture, testing strategy
- If code exists: detects stack from config files, asks only project-level questions
- Generates 7 steering files in `openspec/steering/`

**Steering files generated:**

| File | Content |
|------|---------|
| `product.md` | What the project builds, for whom, bounded context |
| `tech.md` | Stack, dependencies, dev/test commands |
| `structure.md` | Directory layout, layers, responsibilities |
| `conventions.md` | Rules that cause PR failures (RFC 2119: MUST/SHOULD/MAY) |
| `environment.md` | Available MCPs, CLI tools, runtimes, Docker containers |
| `project-skill.md` | Quick reference index pointing to other steering files |
| `project-rules.md` | Empty initially — grows as Claude learns project-specific rules |

**Safe to re-run.** If steering already exists, shows current state instead of re-running.

---

#### `/sdd-discover`

Reverse-engineer canonical specs from an existing codebase. Run once after `/sdd-init` on projects with existing code.

```
/sdd-discover              # Analyze entire project
/sdd-discover {domain}     # Analyze specific domain only
```

**What it does:**
- Scans `src/`, `app/`, `lib/` to detect domains
- Shows detected domains with file counts, asks confirmation
- Launches parallel analysis per domain
- Generates `openspec/specs/{domain}/spec.md` with `Status: inferred`
- Creates/updates `openspec/INDEX.md`

---

#### `/sdd-steer`

Generate or update steering files. Use when conventions drift or after major refactors.

```
/sdd-steer          # Bootstrap: generate all steering files from scratch
/sdd-steer sync     # Detect drift and propose updates (does not auto-apply)
```

**Sync mode** compares current conventions against code, skills, and MEMORY.md, then presents proposed additions, updates, and removals for confirmation.

---

### Change lifecycle

#### `/sdd-new`

Start a new change. Combines explore + propose in one command.

```
/sdd-new "add user authentication"
/sdd-new TICKET-123
```

**What it does:**
1. Picks a kebab-case change name from the description
2. Creates `openspec/changes/{change-name}/`
3. Explores the codebase (read-only) to understand patterns and affected files
4. Creates `proposal.md` with problem, solution, alternatives, and impact

**Output:** `proposal.md`
**Next:** `/sdd-continue` (proceeds to spec)

---

#### `/sdd-explore`

Read-only codebase exploration. Used internally by `/sdd-new` or standalone to understand context.

```
/sdd-explore "how does authentication work"
/sdd-explore
```

Reads code, identifies patterns, checks canonical specs. Produces a summary — no files are created or modified.

---

#### `/sdd-propose`

Create a proposal documenting the problem, solution, and alternatives.

```
/sdd-propose "add rate limiting to API"
/sdd-propose TICKET-456
```

**Output:** `openspec/changes/{change-name}/proposal.md`

```markdown
# Proposal: {Change Title}

## Problem
{What's wrong or missing}

## Proposed Solution
{High-level approach}

## Alternatives Discarded
{Other approaches and why they were rejected}

## Impact
{Files affected, domains, tests needed}
```

---

#### `/sdd-spec`

Create a behavior specification — what the system should do, not how.

```
/sdd-spec                  # Spec for active change
/sdd-spec {change-name}    # Spec for specific change
```

**Prerequisites:** `proposal.md` approved

**What it does:**
- Identifies affected domains/bounded contexts
- Checks existing canonical spec in `openspec/specs/{domain}/spec.md`
- Creates a **delta spec** (only what changes, not a full replacement)
- Clarifies edge cases, validation rules, error behavior with the user
- Uses Given/When/Then format for behavior definitions

**Output:** `openspec/changes/{change-name}/specs/{domain}/spec.md`

---

#### `/sdd-design`

Translate the behavior spec into a concrete implementation plan.

```
/sdd-design                # Design for active change
/sdd-design {change-name}
```

**Prerequisites:** `proposal.md` and `specs/` approved

**Output:** `openspec/changes/{change-name}/design.md`

```markdown
# Design: {Change Title}

## Technical Summary
{1-2 paragraphs on approach}

## Files to Create
| File | Type | Purpose |
|------|------|---------|

## Files to Modify
| File | Change | Reason |
|------|--------|--------|

## Scope Assessment
{< 10 files: Ideal | 10-20: Evaluate | > 20: Split required}

## Design Decisions
{Alternatives considered and why this approach was chosen}
```

---

#### `/sdd-tasks`

Break the design into an ordered list of atomic tasks.

```
/sdd-tasks                 # Tasks for active change
/sdd-tasks {change-name}
```

**Prerequisites:** `design.md` approved

**Rules:**
1. Interfaces and contracts first
2. Base files before files that use them
3. Tests after or interleaved with implementation
4. One file per task, one commit per task

**Output:** `openspec/changes/{change-name}/tasks.md`

```markdown
# Tasks: {Change Title}

## Implementation Tasks

- [ ] **T01** Create `path/to/file` — description
  - Commit: `[{change-name}] Add file description`

- [ ] **T02** Modify `path/to/file` — what changes
  - Commit: `[{change-name}] Update file description`
  - Depends on: T01

## Quality Gate

- [ ] **QG** Run tests and quality checks
```

---

#### `/sdd-apply`

Implement the change following `tasks.md`, one task at a time.

```
/sdd-apply                 # Start from first pending task
/sdd-apply {change-name}   # Implement specific change
/sdd-apply T03             # Continue from specific task
```

**Prerequisites:**
- `tasks.md` approved
- `openspec/steering/conventions.md` must exist (hard requirement)

**How it works:**

1. **Loads steering silently** — reads `conventions.md`, `project-rules.md`, and `tech.md`. Applies all rules during implementation.
2. **For each pending task:**
   - Announces the task
   - Implements the code following existing patterns
   - Runs quality checks (tests, lint) on the changed file
   - Commits atomically: `[{change-name}] Description`
   - Marks task as `[x]` in `tasks.md`
   - Asks before continuing to next task
3. **Unplanned work** — if something comes up not in `tasks.md`, it gets registered as `BUGxx` or `IMPxx` before implementation. Nothing is implemented without being tracked.
4. **Unexpected situations** — Claude stops and asks the user, presenting options. No unilateral decisions.

---

#### `/sdd-verify`

Final validation before creating a PR.

```
/sdd-verify                # Verify active change
/sdd-verify {change-name}
```

**Prerequisites:** All tasks in `tasks.md` marked `[x]`

**Checks:**
1. Full test suite passes
2. Linter/formatter clean on changed files
3. Self-review checklist:
   - Tests exist for new code
   - Input validation at boundaries
   - Methods small and focused (< 50 lines)
   - No hardcoded values
   - No code duplication
   - Type hints complete
   - Spec compliance verified
4. Smoke test for UI projects

**Output:** VERIFY REPORT with status READY FOR PR or list of issues to fix.

---

#### `/sdd-archive`

Close the change cycle. Merge specs and move to archive.

```
/sdd-archive                # Archive active change
/sdd-archive {change-name}
```

**Prerequisites:** `/sdd-verify` passed, PR created

**What it does:**
1. Merges delta specs into canonical specs at `openspec/specs/{domain}/spec.md`
2. Updates `openspec/INDEX.md` with new/modified domains
3. Moves the change to `openspec/changes/archive/{date}-{change-name}/`

After archive, canonical specs reflect the current system state and the change artifacts are preserved for history.

---

### Shortcuts

#### `/sdd-ff` (Fast-Forward)

Run propose + spec + design + tasks in one pass. For when the scope is clear.

```
/sdd-ff "add health check endpoint"
/sdd-ff TICKET-789
```

Generates all 4 artifacts without pausing between phases. If ambiguity is found, pauses to ask, then continues.

**Output:** `proposal.md` + `specs/` + `design.md` + `tasks.md`
**Next:** `/sdd-apply`

---

#### `/sdd-continue`

Detect the next pending phase and execute it. The "what's next?" command.

```
/sdd-continue                  # Active change
/sdd-continue {change-name}
```

Checks which artifacts exist and runs the next skill in sequence:
- No `proposal.md` -> runs `/sdd-propose`
- No `specs/` -> runs `/sdd-spec`
- No `design.md` -> runs `/sdd-design`
- No `tasks.md` -> runs `/sdd-tasks`
- Pending tasks -> runs `/sdd-apply` from next pending task
- All tasks done -> runs `/sdd-verify`
- All done -> suggests `/sdd-archive`

---

### Utilities

#### `/sdd-audit`

Analyze codebase against conventions and project rules.

```
/sdd-audit                  # Check files modified in current branch
/sdd-audit src/components/  # Check specific path
```

**Prerequisites:** `openspec/steering/conventions.md` must exist

Loads rules from `conventions.md` and `project-rules.md`, classifies violations:
- **Critical** (MUST/MUST NOT) — blocks PR
- **Important** (SHOULD) — technical debt
- **Minor** (MAY) — stylistic

Produces a report with fix recommendations and `/sdd-new` prompts for critical violations.

---

#### `/sdd-docs`

Generate publishable MkDocs documentation from `openspec/`.

```
/sdd-docs
```

Runs `sdd-docs --fill --force` to produce:
- `mkdocs.yml` with Material theme
- `docs/index.md` — narrative homepage
- `docs/reference/{domain}.md` — one page per domain
- `docs/changelog.md` — from archived changes

Requires `ANTHROPIC_API_KEY` for AI-enriched content (no placeholders). Without it, generates templates with placeholders.

---

## The `openspec/` directory

All SDD artifacts live in `openspec/`. This is the single source of truth for what the system does and why.

```
openspec/
├── config.yaml                         # Project config
├── INDEX.md                            # Domain index
├── steering/                           # Project context (generated by /sdd-init)
│   ├── product.md                      #   What it builds, for whom
│   ├── tech.md                         #   Stack, tools, commands
│   ├── structure.md                    #   Directory layout, layers
│   ├── conventions.md                  #   Rules (MUST/SHOULD/MAY)
│   ├── environment.md                  #   Available tools, MCPs
│   ├── project-skill.md                #   Quick reference index
│   └── project-rules.md                #   Grows with corrections
├── specs/                              # Canonical specs (current system state)
│   └── {domain}/
│       └── spec.md
└── changes/                            # Active and archived changes
    ├── {change-name}/                  #   Active change
    │   ├── proposal.md
    │   ├── specs/{domain}/spec.md      #   Delta spec
    │   ├── design.md
    │   └── tasks.md
    └── archive/                        #   Completed changes
        └── {date}-{change-name}/
```

### Steering vs Skills

| | Skills (`/sdd-*`) | Steering (`openspec/steering/`) |
|---|---|---|
| **Contains** | Generic process steps | Project-specific context |
| **Scope** | Universal — works on any project | One project |
| **Changes** | Updated by skill maintainers | Updated by `/sdd-steer sync` or user corrections |
| **Example** | "Run quality checks before commit" | "Quality checks = `pytest` + `ruff check`" |

### How `project-rules.md` grows

When Claude makes a decision during `/sdd-apply` and the user corrects it:

1. **Explicit correction** ("always use X", "remember this") — saved immediately
2. **Implicit correction** (user overrides Claude's choice) — Claude asks "save as rule?"
3. **Second correction of same pattern** — saved automatically without asking

Rules use RFC 2119 format: `**MUST** use X — reason from correction context`

---

## Examples

### New project from scratch

```
/sdd-init                              # Answer questions about your project
/sdd-new "user registration"           # Start first feature
/sdd-continue                          # Spec phase
/sdd-continue                          # Design phase
/sdd-continue                          # Tasks phase
/sdd-apply                             # Implement
/sdd-verify                            # Validate
/sdd-archive                           # Close and merge specs
```

### Existing project, first time using SDD

```
/sdd-init                              # Detects existing stack, shorter questionnaire
/sdd-discover                          # Generate specs from existing code
/sdd-new "fix payment timeout"         # Start working with SDD
```

### Quick change, clear scope

```
/sdd-ff "add /health endpoint"         # All docs in one pass
/sdd-apply                             # Implement
/sdd-verify && /sdd-archive            # Validate and close
```

### Audit existing code

```
/sdd-audit                             # Check branch changes against conventions
/sdd-audit src/api/                    # Check specific directory
```

### Update conventions after a refactor

```
/sdd-steer sync                        # Detect drift, propose updates
```

---

## Requirements

- An AI coding assistant: [Claude Code](https://claude.ai/code), [Cursor](https://cursor.com), [Codex](https://openai.com/codex), or [GitHub Copilot](https://github.com/features/copilot)
- Git

No other dependencies. Skills work with any language and framework.

## License

MIT
