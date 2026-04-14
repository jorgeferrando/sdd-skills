# Quick Start

## New project (empty repo)

If you're starting from scratch, `/sdd-init` runs a full questionnaire to understand your project:

```
/sdd-init
```

It asks about:

- **What you're building** — purpose, users, boundaries
- **Stack** — language, framework, database, testing
- **Team** — size, quality level (MVP/production/OSS), CI/CD
- **Patterns** — architecture style, TDD, commit format

For each question with trade-offs, the AI shows options with justifications. You can always answer "you decide" and the AI chooses and explains.

After the questionnaire, `/sdd-init` generates steering files in `openspec/steering/` that feed the entire workflow.

Then start your first change:

```
/sdd-new "add user registration"
/sdd-continue                        # repeat until done
/sdd-archive
```

## Existing project

If your repo already has code, `/sdd-init` detects the stack automatically and asks fewer questions:

```
/sdd-init                            # Detects stack from config files
/sdd-discover                        # Generate specs from existing code
```

After that, work normally with SDD:

```
/sdd-new "fix payment timeout"
```

## Day-to-day usage

### Standard flow (full control)

Use when you want to review each phase before proceeding:

```
/sdd-new "description"               # Creates proposal
/sdd-continue                        # Spec phase — review and confirm
/sdd-continue                        # Design phase — review and confirm
/sdd-continue                        # Tasks phase — review task list
/sdd-apply                           # Implement task by task
/sdd-verify                          # Final checks
/sdd-archive                         # Close the cycle
```

### Fast-forward (clear scope)

Use when the change is straightforward and you trust the AI's judgment:

```
/sdd-ff "add /health endpoint"       # All docs in one pass
/sdd-apply                           # Implement
/sdd-verify
/sdd-archive
```

### "What's next?"

If you lose track of where you are:

```
/sdd-continue                        # Detects next phase automatically
```

### Audit existing code

Check your code against project conventions:

```
/sdd-audit                           # Files changed in current branch
/sdd-audit src/api/                  # Specific directory
```

## Tips

- **`/sdd-continue` is your friend** — when in doubt, just run it
- **Review specs carefully** — they're the contract. Design and implementation flow from them
- **Let `project-rules.md` grow** — correct the AI once, it remembers forever
- **Archive often** — it keeps canonical specs up to date
- **Use `/sdd-ff` for small changes** — don't over-process simple tasks
