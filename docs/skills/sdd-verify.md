# /sdd-verify

> Final validation before creating a PR. Tests, quality checks, and self-review.

## Usage

```
/sdd-verify                # Verify active change
/sdd-verify {change-name}
```

## Prerequisites

- All tasks in `tasks.md` marked `[x]`

## What it checks

### 1. Tests

Checks `openspec/steering/tech.md` for the project's test command and runs the full test suite. If no test runner is configured or detected, skips with a note in the report.

### 2. Linters and formatters

Checks `openspec/steering/tech.md` for configured linters. Runs them on changed files. Fixes issues, re-runs, commits atomically if needed. If no linter is configured, skips with a note. Does not install new tools during verify.

### 3. Self-review checklist

| Check | Criteria |
|-------|----------|
| Test coverage | Tests exist for new functions, edge cases, error paths |
| Input validation | Validated at system boundaries |
| Method size | < 50 lines, < 3 nesting levels |
| No hardcoded values | Uses constants or enums |
| No duplication | DRY within reason |
| Type hints | Complete and correct |
| Null safety | Null/None checks in place |
| Spec compliance | Implementation matches the behavior spec |

### 4. Smoke test (UI projects)

For TUI/UI projects, runs the application and verifies the golden path manually. Documents any issues found as `BUGxx` in `tasks.md`.

### 5. Convention audit

If `openspec/steering/conventions.md` exists, runs `/sdd-audit` on changed files. Fixes critical violations before proceeding.

### 6. Create PR

Pushes the branch and creates the pull request using context from `proposal.md` (problem, solution, acceptance criteria).

## Output

```
VERIFY REPORT: {change-name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tests:          PASS (42 passed)
Lint:           SKIPPED (no linter configured)
Self-review:    PASS (8/8 checks)
Spec compliance: PASS
Audit:          PASS (20 rules, 0 violations)

Status: READY FOR PR
PR: https://github.com/org/repo/pull/123
```

## Next step

- `/sdd-archive` — close the cycle, merge specs into canonical
