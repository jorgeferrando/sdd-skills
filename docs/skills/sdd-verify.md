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

Runs the full test suite for the project:

```bash
# Whatever your project uses:
pytest
npm test
go test ./...
```

All tests **must pass** before proceeding.

### 2. Linters and formatters

Runs lint/format on changed files. Fixes issues, re-runs, commits atomically if needed.

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
Lint:           PASS
Self-review:    PASS (8/8 checks)
Spec compliance: PASS
Audit:          PASS (20 rules, 0 violations)

Status: READY FOR PR
PR: https://github.com/org/repo/pull/123
```

## Next step

- `/sdd-archive` — close the cycle, merge specs into canonical
