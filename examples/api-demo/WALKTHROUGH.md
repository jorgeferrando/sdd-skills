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

**Friction found and resolved:**
- **F1:** ~~Step 3 referenced `scripts/sdd-env-scan.sh` with a single path that didn't resolve for installed skills.~~ Fixed: multiple path fallbacks + manual detection if script not found.
- **F2:** ~~The questionnaire had no quick mode for simple projects.~~ Fixed: added `--quick` mode that asks only Groups A and B with sensible defaults.

### 2. `/sdd-new` → `/sdd-explore` + `/sdd-propose` — Start change

**Artifacts produced:**
- `openspec/changes/add-health-check/proposal.md`

**Friction found:**
- None. `sdd-explore` already specifies `notes.md` output path and `sdd-propose` references it correctly.

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

**Friction found and resolved:**
- **F6:** ~~Step 3 said "Create a branch if needed" without specifying when.~~ Fixed: now says to check conventions.md for branching strategy and skip if already on a feature branch.

### 6. `/sdd-apply` — Implementation

**Artifacts produced:**
- `src/routes/health.js` (new)
- `src/index.js` (modified)
- `test/health.test.js` (new)

**Friction found and resolved:**
- **F7:** ~~Per-task confirmation was mandatory, tedious for small changes.~~ Fixed: added `--auto` flag that skips confirmation on success.

### 7. `/sdd-verify` — Quality checks

**Friction found and resolved:**
- **F8:** ~~No guidance for projects without linter/test runner configured.~~ Fixed: now checks tech.md, skips unconfigured tools with explicit report note, and never installs new tools during verify.

### 8. `/sdd-archive` — Close cycle

**Friction found:**
- None. The skill already handles the first canonical spec case: "If no canonical spec exists for the domain, create it."

## Summary of friction points

All friction points found during the walkthrough have been resolved.

| ID | Phase | Status | Issue | Fix |
|----|-------|--------|-------|-----|
| F1 | init | Resolved | `sdd-env-scan.sh` path didn't resolve for installed skills | Multiple path fallbacks + manual detection |
| F2 | init | Resolved | No quick mode for simple projects | `--quick` mode with sensible defaults |
| F3 | explore | False positive | `notes.md` output was already specified | N/A |
| F6 | tasks | Resolved | Branch creation guidance ambiguous | Check conventions.md for branching strategy |
| F7 | apply | Resolved | Per-task confirmation tedious for small changes | `--auto` flag |
| F8 | verify | Resolved | No guidance for missing tools | Check tech.md, skip with report note |
| F9 | archive | False positive | First canonical spec was already handled | N/A |

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
