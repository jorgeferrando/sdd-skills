# Quick Start Guide

This guide walks you through the complete SDD workflow step by step. Each section explains **why** the skill is launched, **what** it produces, and **how** to advance to the next phase.

## Phase 0: Bootstrap (once per project)

### Step 1: `/sdd-init`

**Why:** It is the first command of any SDD project. Without it, the `openspec/` structure and steering files do not exist, and the rest of the workflow cannot function. `/sdd-apply`, for example, refuses to start if it cannot find `conventions.md`.

**What it does:** Init runs a guided onboarding — scans the environment (language, framework, tools), presents a questionnaire about the product, stack, team and rigor level, and generates 7 files in `openspec/steering/` from the answers:

| File | Content |
|------|---------|
| `product.md` | What the project builds and for whom |
| `tech.md` | Stack, dependencies, dev/test commands |
| `structure.md` | Directory layout, layers, responsibilities |
| `conventions.md` | Rules that cause PR failures (RFC 2119: MUST/SHOULD/MAY) |
| `environment.md` | Available MCPs, CLIs, runtimes |
| `project-skill.md` | Quick-reference index pointing to the other steering files |
| `project-rules.md` | Empty at first — grows as the AI learns from user corrections |

It also creates `config.yaml` with the openspec paths and the directory structure (`specs/`, `changes/`, `archive/`).

**How to advance:** Init finishes with a summary and suggests two paths: `/sdd-new` to start a feature, or `/sdd-discover` if the project already has code.

**Why this skill:** There is no alternative. Without the bootstrap, no other skill has project context. This is the starting point.

```
/sdd-init
```

---

### Step 2: `/sdd-discover` (only if the project already has code)

**Why:** If the project is not new, there are already implemented domains with no spec. Discover reverse-engineers the existing code to generate initial specs, so that future changes via `/sdd-spec` can write deltas against a known baseline instead of starting from scratch.

**What it does:** Discover scans the source directories (`src/`, `app/`, `lib/`), infers domains, asks for confirmation, and launches one parallel subagent per domain. Each subagent reads the domain code, infers its purpose, main entities and behavior, and writes a canonical spec to `openspec/specs/{domain}/spec.md` with `Status: inferred`. It also creates or updates `openspec/INDEX.md` — a keyword index that helps future explores find relevant specs quickly.

**How to advance:** Inferred specs are automatic drafts. Review and edit them directly in `openspec/specs/`. When a domain needs changes later, `/sdd-new` will create a delta spec via `/sdd-spec`.

**Why this skill:** It is the only way to populate `openspec/specs/` without creating a formal change for every existing domain. It is a retrospective shortcut, not a step in the change workflow.

```
/sdd-discover                # Analyze entire project
/sdd-discover {domain}       # Analyze a specific domain only
```

---

## Phase 1: Change cycle (repeated for each feature, fix or refactor)

### Step 3: `/sdd-new "description"`

**Why:** The user wants to make a change — a new feature, a fix, a refactor. `/sdd-new` is the canonical entry point. The user does not need to know which skills run internally.

**What it does:** Internally, sdd-new runs two things in sequence:

1. **Explore** (`sdd-explore`): Reads the codebase in read-only mode. Looks for patterns similar to the requested change, identifies files that will be affected, consults `openspec/INDEX.md` to find relevant canonical specs, and analyzes how tests are structured for similar code. Writes findings to `openspec/changes/{change-name}/notes.md` so the next phase can read them.

2. **Propose** (`sdd-propose`): Reads the exploration notes and project steering. Analyzes whether the user's description is sufficient to fill all sections of a complete proposal (Context, Problem, Scope, Solution, Alternatives, Risks, Impact, Dependencies, Acceptance Criteria). If there are gaps, asks specific questions until all sections are covered. Only then generates `openspec/changes/{change-name}/proposal.md`.

**How to advance:** Once proposal.md exists, the user approves it or gives feedback. When satisfied, run `/sdd-continue`.

**Why this skill:** `/sdd-new` abstracts the decision of "first explore, then propose". The user says what they want; the skill decides how to investigate and what to ask. The alternative would be running `/sdd-explore` and `/sdd-propose` separately, which is valid but requires knowing the internal flow.

```
/sdd-new "add user authentication"
/sdd-new TICKET-123
```

---

### Step 4: `/sdd-continue` (runs `sdd-spec`)

**Why:** After proposal.md is approved, the user needs to advance. Instead of remembering that the next phase is spec, they run `/sdd-continue`. Continue reads the change directory, sees that `proposal.md` exists but there is no `specs/*/spec.md`, and deduces that the pending phase is spec.

**What it does:** Spec reads proposal.md to understand the problem and proposed solution. From there it identifies which domain/bounded context is affected. It checks whether a canonical spec exists at `openspec/specs/{domain}/spec.md` — if it does, the change spec will be a **delta** (only what changes), not a full rewrite. Before writing, it uses `AskUserQuestion` to resolve edge cases, validation rules and error behavior that the proposal does not cover. It generates `openspec/changes/{change-name}/specs/{domain}/spec.md` with Given/When/Then format, error tables, business rules and decisions made.

**How to advance:** Spec is presented to the user for review. With the spec approved, run `/sdd-continue` again.

**Why spec after propose:** The proposal defines the *what* and the *why* at business level. The spec defines the *expected system behavior* precisely and verifiably. These are different levels of detail: the proposal says "add rate limiting to the API", the spec says "Given a user with more than 100 requests/minute, When they send a request, Then they receive 429 with a Retry-After header". Without the spec, the technical design has no behavioral reference to validate against.

```
/sdd-continue
```

---

### Step 5: `/sdd-continue` (runs `sdd-design`)

**Why:** Continue sees that proposal.md and spec.md exist, but not design.md. It deduces that the pending phase is design.

**What it does:** Design reads both proposal.md and spec.md, plus existing code that follows similar patterns. It translates the specified behavior into a concrete technical plan: which files to create, which to modify, what architecture to use, what dependencies exist between the changes. It includes a scope analysis — if the change touches more than 20 files, it proposes splitting before continuing. It generates `openspec/changes/{change-name}/design.md` with architecture diagrams, file tables, and technical decisions with discarded alternatives.

**How to advance:** Design is presented to the user. If the technical approach is correct and all affected files are identified, approve it and run `/sdd-continue`.

**Why design after spec:** Spec says *what* the system must do. Design says *how* to implement it technically. This is a deliberate separation: you can have the same spec implemented with different architectures. Separating spec from design lets you discuss behavior without contaminating the conversation with implementation decisions, and vice versa.

```
/sdd-continue
```

---

### Step 6: `/sdd-continue` (runs `sdd-tasks`)

**Why:** Continue sees that design.md exists but not tasks.md. It deduces that the pending phase is tasks.

**What it does:** Tasks reads design.md and extracts the complete list of files to create/modify. It orders them by dependency: interfaces and contracts first, base files before files that use them, tests after or interleaved with the implementation. Each task is atomic: one file, one commit. It verifies git state and creates a branch if one does not exist. It generates `openspec/changes/{change-name}/tasks.md` with task IDs (T01, T02...), file paths, commit descriptions, and dependencies between tasks.

**How to advance:** Tasks is presented to the user to verify the order, granularity and completeness. With tasks approved, run `/sdd-continue`.

**Why tasks after design:** Design defines *which* files and *what* to change in each. But it does not define *in what order* to implement them. Tasks does that work: if T03 depends on an interface created in T01, that must be explicit. Without tasks, apply would not know where to start or how to make atomic commits.

```
/sdd-continue
```

---

### Step 7: `/sdd-continue` (runs `sdd-apply`)

**Why:** Continue sees that tasks.md exists with pending `[ ]` items. It deduces that the phase is apply. If there are partially completed tasks (`[x]` and `[ ]`), it passes the next pending ID (e.g. `T03`) to apply.

**What it does:** Apply is the actual implementation phase. Before touching code, it verifies that `conventions.md` exists (it refuses to start without it) and silently loads all steering (`conventions.md`, `project-rules.md`, `tech.md`) to apply project rules throughout implementation. Then, task by task:

1. Announces what it will do (T02/T05: description)
2. Reads similar existing code to follow patterns
3. Implements the change
4. Runs tests/lint on the modified file
5. Makes an atomic commit with format `[{change-name}] Description`
6. Marks `[x]` in tasks.md
7. Asks for confirmation before moving to the next task

If the user requests an unplanned change, apply registers it as BUG01/IMP01 in tasks.md before implementing. tasks.md is the single source of truth for everything that was done.

**How to advance:** When all tasks are `[x]`, apply shows a summary and suggests `/sdd-verify`.

**Why apply after tasks:** Apply does not decide what to implement or in what order — it just executes. All planning happened in previous phases. This lets apply be mechanical and predictable: follow the list, commit by commit, with no architecture decisions in the middle of implementation.

```
/sdd-continue
```

---

### Step 8: `/sdd-continue` (runs `sdd-verify`)

**Why:** Continue sees that all tasks are `[x]` and the working tree has changes relative to main. It deduces that the phase is verify.

**What it does:** Verify is the final quality gate. It runs in sequence:

1. **Full tests** — the project's entire test suite, not just the changed files
2. **Linters/formatters** — on changed files, with fix+commit if there are issues
3. **Self-review checklist** — 8 criteria (test coverage, input validation, method size, no hardcoded values, no duplication, type hints, null safety, spec compliance)
4. **Smoke test** — if it is a UI project, runs the app and verifies the golden path
5. **Convention audit** — if `conventions.md` exists, runs `sdd-audit` on the branch files
6. **Creates the PR** — pushes the branch, creates the pull request using context from proposal.md

**How to advance:** With a green report and the PR created, run `/sdd-archive`.

**Why verify after apply:** Apply already runs tests per individual file, but verify validates the ensemble. A unit test can pass for each file individually and fail in integration. The self-review checklist catches problems that tests do not cover (methods that are too long, hardcoded values, missing type hints). The audit checks architectural conventions that no linter detects.

```
/sdd-verify
```

---

### Step 9: `/sdd-archive`

**Why:** The PR exists and has been reviewed. The change cycle is complete. Now the loop must be closed: update canonical specs with what this change introduced and archive the change documentation.

**What it does:** Archive does three things:

1. **Merges delta specs into canonical** — the change specs (`openspec/changes/{change}/specs/{domain}/spec.md`) are integrated into the canonical specs (`openspec/specs/{domain}/spec.md`). If no canonical spec existed for the domain, one is created. This ensures that `openspec/specs/` always reflects the current state of the system.

2. **Updates INDEX.md** — adds new entities and keywords that the change introduced, so that future explores will find them.

3. **Moves to archive** — the change directory moves to `openspec/changes/archive/{date}-{change-name}/`. It is no longer active but serves as historical context for future changes in the same domain.

**Why archive at the end:** Without archive, canonical specs become outdated. The next developer who runs `/sdd-explore` would read specs that do not reflect what the code actually does. Archive closes the feedback loop: what was specified, designed and implemented is integrated back into the project's knowledge base.

```
/sdd-archive
```

---

## Fast-forward path: `/sdd-ff`

When the scope is clear and there is no ambiguity, the fast-forward path skips the review pauses between phases:

```
/sdd-ff "add /health endpoint"    # Generates proposal + spec + design + tasks in one pass
/sdd-apply                        # Implement task by task
/sdd-verify                       # Final checks + PR
/sdd-archive                      # Close the cycle
```

**When to choose it over `/sdd-new` + continue:** When the change is straightforward, the scope is clear, and the user does not need to approve each phase separately. FF generates all 4 documents in a single pass, only asking questions when it finds ambiguities it cannot resolve on its own.

**When NOT to choose it:** When the change is large, uncertain, or affects multiple domains. In those cases, the pauses between phases let you correct course before investing more time.

---

## Visual summary

```
BOOTSTRAP (once per project)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  /sdd-init → /sdd-discover (if existing code)

STANDARD CHANGE (with /sdd-continue as the engine)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  /sdd-new → /sdd-continue (x5) → /sdd-archive

FAST-FORWARD CHANGE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  /sdd-ff → /sdd-apply → /sdd-verify → /sdd-archive

AUXILIARY SKILLS (at any time)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  /sdd-steer sync    Update steering when the project evolves
  /sdd-audit         Validate code against conventions
  /sdd-explore       Investigate without creating a change
  /sdd-docs          Generate documentation site from openspec
```

---

## Tips

- **`/sdd-continue` is your friend** — when in doubt, just run it
- **Review specs carefully** — they are the contract. Design and implementation flow from them
- **Let `project-rules.md` grow** — correct the AI once, it remembers forever
- **Archive often** — it keeps canonical specs up to date
- **Use `/sdd-ff` for small changes** — don't over-process simple tasks
