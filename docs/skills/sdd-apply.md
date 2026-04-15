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
- `openspec/steering/conventions.md` **must exist** — the AI refuses to start without it

## How it works

### Step 0: Load steering

Before writing any code, the AI reads:

1. `openspec/steering/project-skill.md` (index)
2. `openspec/steering/conventions.md` (rules)
3. `openspec/steering/project-rules.md` (learned rules)
4. `openspec/steering/tech.md` (stack details)

All rules are applied throughout the implementation. This is what makes `/sdd-apply` project-aware despite being a generic skill.

### For each pending task (one agent per task)

Each task is implemented by a **subagent** to keep the main conversation clean. The orchestrator does not accumulate code-reading, test output, or implementation details — only the summary from each agent.

**Agent per task:**

1. Receives the task description, file path, steering files, and spec context
2. Reads similar existing code to follow patterns
3. Implements the change
4. Runs quality checks on the changed file
5. Commits atomically: `[change-name] Description`
6. Returns a short summary (what was done, files touched, commit hash, test result)

**Orchestrator between tasks:**

1. Checks the agent result
2. Marks task as `[x]` in tasks.md
3. Reports progress and asks before continuing to the next task

### Unplanned work

If something comes up that's not in `tasks.md`:

1. Register it as `BUGxx` or `IMPxx` in `tasks.md` **before** implementing
2. Implement and commit atomically
3. Mark as done

**Nothing is implemented without being tracked.**

### Unexpected situations

The AI does NOT make unilateral decisions. If something unexpected appears:

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

Co-Authored-By: AI Assistant <noreply@sdd-skills.dev>
```

- Max 70 characters on first line
- Imperative mood: "Add", "Fix", "Update" (not "Added", "Fixes")
- Only the file(s) for this task (atomic)

## Next step

- `/sdd-verify` — final quality checks before PR
