# /sdd-continue

> Detect the next pending phase and execute it. The "what's next?" command.

## Usage

```
/sdd-continue                  # Active change
/sdd-continue {change-name}    # Specific change
```

## What it does

Checks which artifacts exist in the change directory and runs the next skill:

| Missing artifact | Runs | Mode |
|-----------------|------|------|
| No `proposal.md` | `/sdd-propose` | Inline (interactive) |
| No `specs/` | `/sdd-spec` | Inline (interactive) |
| No `design.md` | `/sdd-design` | **Agent** (non-interactive) |
| No `tasks.md` | `/sdd-tasks` | Inline (interactive) |
| Pending tasks in `tasks.md` | `/sdd-apply` | Inline (manages own agents) |
| All tasks done, clean tree | `/sdd-verify` | **Agent** (non-interactive) |
| Everything complete | Suggests `/sdd-archive` | — |

**Why agents for some phases?** Design and verify are non-interactive — they read files, analyze code, and produce artifacts without needing user input. Running them as agents keeps the orchestrator context free of code-reading and test-output noise. Interactive phases (propose, spec, tasks) stay inline because the user needs to answer questions and give feedback.

If multiple active changes exist and no name is provided, prompts the user to choose.

## When to use

- You lose track of where you are in the workflow
- You want to advance without remembering which skill comes next
- After a break, to resume work

This is the most used skill in day-to-day work. When in doubt, just run `/sdd-continue`.
