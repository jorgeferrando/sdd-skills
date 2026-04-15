# SDD Workflow Walkthrough: api-demo

This example demonstrates the full SDD lifecycle on a minimal Node.js API.

## Project

A simple HTTP server with one endpoint (`GET /`). The change adds a `GET /health` endpoint.

## Workflow executed

```
/sdd-init → /sdd-new "add health check" → /sdd-ff → /sdd-apply → /sdd-verify → /sdd-archive
```

## Phase-by-phase results

### 1. `/sdd-init` — Bootstrap

**Artifacts produced:**
- `openspec/config.yaml`
- `openspec/steering/` — 7 files (product, tech, structure, conventions, environment, project-skill, project-rules)

**Friction found:**
- **F1:** Step 3 references `scripts/sdd-env-scan.sh` but the path assumes the script is in the sdd-skills repo, not the user's project. When running as an installed skill, the path won't resolve. The fallback path also assumes a specific directory structure. Needs a clearer resolution strategy or should detect where the script is installed.
- **F2:** The questionnaire (Steps 4-5) is thorough but the 454-line instruction file is heavy for the AI's context window. In practice, the AI follows it well, but a `--quick` mode that skips Groups D and E would reduce friction for simple projects.

### 2. `/sdd-new` → `/sdd-explore` + `/sdd-propose` — Start change

**Artifacts produced:**
- `openspec/changes/add-health-check/proposal.md`

**Friction found:**
- **F3:** `sdd-explore` produces `notes.md` but `sdd-propose` references it as optional context. The handoff works but `notes.md` is never explicitly created by `sdd-explore` — the skill says "produce summary" without specifying the output file path in a consistent way. Step 1 of sdd-explore should specify: "Write findings to `openspec/changes/{change-name}/notes.md`".

### 3. `/sdd-spec` — Behavior specification

**Artifacts produced:**
- `openspec/changes/add-health-check/specs/api/spec.md`

**Friction found:**
- **F4:** None. The skill is clear: read proposal, identify domain, create delta spec, present to user. The Given/When/Then format works well for API behavior.

### 4. `/sdd-design` — Implementation plan

**Artifacts produced:**
- `openspec/changes/add-health-check/design.md`

**Friction found:**
- **F5:** None. Scope analysis is useful (3 files = "Ideal"). The design template produces everything the next phase needs.

### 5. `/sdd-tasks` — Task breakdown

**Artifacts produced:**
- `openspec/changes/add-health-check/tasks.md`

**Friction found:**
- **F6:** Step 3 says "Create a branch if needed" but doesn't specify *when* it's needed vs. not. For a smoke test running in an existing repo (like this example inside sdd-skills), creating a branch would be wrong. The instruction should say: "Create a branch if the project uses feature branches (check conventions.md for commit/branching strategy)."

### 6. `/sdd-apply` — Implementation

**Artifacts produced:**
- `src/routes/health.js` (new)
- `src/index.js` (modified)
- `test/health.test.js` (new)

**Friction found:**
- **F7:** The subagent prompt template in Step 3 is excellent — gives the agent everything it needs. However, the instruction "Wait for user confirmation before launching the next agent" can be tedious for small changes. Consider a `--auto` flag that skips confirmation when tasks are sequential and independent.

### 7. `/sdd-verify` — Quality checks

**Friction found:**
- **F8:** The skill lists 5 checks (tests, linter, self-review, convention audit, smoke test) but doesn't specify what to do when the project has no linter configured. Should say: "Skip checks that are not configured in tech.md — do not install new tools during verify."

### 8. `/sdd-archive` — Close cycle

**Friction found:**
- **F9:** The skill says to merge delta specs into canonical specs at `openspec/specs/{domain}/spec.md`. For the first change in a new project, this means *creating* the canonical spec, not merging into one. The instruction should handle the "first spec" case explicitly: "If no canonical spec exists, copy the delta spec as the initial canonical spec."

## Summary of friction points

| ID | Phase | Severity | Issue |
|----|-------|----------|-------|
| F1 | init | Medium | `sdd-env-scan.sh` path resolution doesn't work for installed skills |
| F2 | init | Low | 454-line instruction is heavy; `--quick` mode would help |
| F3 | explore→propose | Low | `notes.md` output path not explicitly specified in sdd-explore |
| F6 | tasks | Low | Branch creation guidance is ambiguous |
| F7 | apply | Low | Per-task confirmation is tedious for small changes |
| F8 | verify | Low | No guidance for missing tools (linter not configured) |
| F9 | archive | Medium | First-time canonical spec creation not handled |

## Files in this example

```
examples/api-demo/
├── package.json
├── src/
│   ├── index.js
│   └── routes/
│       └── health.js
├── test/
│   └── health.test.js
└── openspec/
    ├── config.yaml
    ├── steering/
    │   ├── product.md
    │   ├── tech.md
    │   ├── structure.md
    │   ├── conventions.md
    │   ├── environment.md
    │   ├── project-skill.md
    │   └── project-rules.md
    └── changes/
        └── add-health-check/
            ├── proposal.md
            ├── specs/api/spec.md
            ├── design.md
            └── tasks.md
```
