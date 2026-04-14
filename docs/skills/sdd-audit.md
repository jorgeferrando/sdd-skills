# /sdd-audit

> Analyze codebase against conventions and project rules.

## Usage

```
/sdd-audit                  # Check files modified in current branch
/sdd-audit src/components/  # Check specific path
```

## Prerequisites

- `openspec/steering/conventions.md` must exist

## What it does

1. **Loads ruleset** from `conventions.md` and `project-rules.md`
2. **Determines scope:**
   - No argument: files modified since branch diverged from main
   - With path: files at the provided path
3. **Analyzes each file** against MUST/SHOULD/MAY rules
4. **Classifies violations:**

| Severity | Rule level | Impact |
|----------|-----------|--------|
| Critical | MUST / MUST NOT | Blocks PR |
| Important | SHOULD | Technical debt |
| Minor | MAY | Stylistic |

5. **Generates report** with fix recommendations

## Output format

```
AUDIT REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CRITICAL (blocks PR):
  src/api/handler.py:15 — MUST NOT inject Repository directly
  src/api/handler.py:42 — MUST use type hints for all parameters

IMPORTANT (technical debt):
  src/api/handler.py:28 — SHOULD keep methods under 50 lines (current: 67)

Summary: 2 critical, 1 important, 0 minor

Recommendation: Fix critical violations before PR.
  /sdd-new "fix-audit-violations-api-handler"
```

## When to use

- Before creating a PR — catch convention violations early
- After a refactor — verify nothing drifted
- On a new team member's first PR — educational tool
- Periodically — track technical debt
