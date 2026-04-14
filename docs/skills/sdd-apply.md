# /sdd-apply

> Implement the change following tasks.md. One task = one file = one atomic commit.

## Usage

```
/sdd-apply                 # Start from first pending task
/sdd-apply {change-name}   # Implement specific change
/sdd-apply T03             # Continue from specific task
```

## Prerequisites

- `tasks.md` approved with task list
- Correct git branch created
- `openspec/steering/conventions.md` **must exist** — Claude refuses to start without it

## How it works

### Step 0: Load steering

Before writing any code, Claude reads:

1. `openspec/steering/project-skill.md` (index)
2. `openspec/steering/conventions.md` (rules)
3. `openspec/steering/project-rules.md` (learned rules)
4. `openspec/steering/tech.md` (stack details)

All rules are applied throughout the implementation. This is what makes `/sdd-apply` project-aware despite being a generic skill.

### For each pending task

1. **Announce** — shows task ID, description, and target file
2. **Implement** — writes code following existing patterns and steering conventions
3. **Quality check** — runs test/lint commands on the changed file
4. **Atomic commit** — `git add {file}` + `git commit -m "[change-name] Description"`
5. **Update tasks.md** — marks task as `[x]`
6. **Confirm** — asks before continuing to next task

### Unplanned work

If something comes up that's not in `tasks.md`:

1. Register it as `BUGxx` or `IMPxx` in `tasks.md` **before** implementing
2. Implement and commit atomically
3. Mark as done

**Nothing is implemented without being tracked.**

### Unexpected situations

Claude does NOT make unilateral decisions. If something unexpected appears:

```
During T03 I found {situation}.
The tasks don't cover this case. How should I proceed?
1. {Option A}
2. {Option B}
3. Stop and update design/tasks
```

## Commit format

```
[{change-name}] {Description in English, imperative mood}

Co-Authored-By: Claude <noreply@anthropic.com>
```

- Max 70 characters on first line
- Imperative mood: "Add", "Fix", "Update" (not "Added", "Fixes")
- Only the file(s) for this task (atomic)

## Next step

- `/sdd-verify` — final quality checks before PR
