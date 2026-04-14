# /sdd-continue

> Detect the next pending phase and execute it. The "what's next?" command.

## Usage

```
/sdd-continue                  # Active change
/sdd-continue {change-name}    # Specific change
```

## What it does

Checks which artifacts exist in the change directory and runs the next skill:

| Missing artifact | Runs |
|-----------------|------|
| No `proposal.md` | `/sdd-propose` |
| No `specs/` | `/sdd-spec` |
| No `design.md` | `/sdd-design` |
| No `tasks.md` | `/sdd-tasks` |
| Pending tasks in `tasks.md` | `/sdd-apply` (from next pending task) |
| All tasks done, clean tree | `/sdd-verify` |
| Everything complete | Suggests `/sdd-archive` |

If multiple active changes exist and no name is provided, prompts the user to choose.

## When to use

- You lose track of where you are in the workflow
- You want to advance without remembering which skill comes next
- After a break, to resume work

This is the most used skill in day-to-day work. When in doubt, just run `/sdd-continue`.
