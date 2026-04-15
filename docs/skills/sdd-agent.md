# /sdd-agent

> Autonomous orchestrator that runs the full SDD cycle for a task. Interacts via chat when it needs input, works silently when it doesn't.

## Usage

```
/sdd-agent "add rate limiting to the public API"
/sdd-agent --issue 42
/sdd-agent --ticket PROJ-123
```

## What it does

Executes the complete SDD workflow autonomously:

1. **Explore** — recall past decisions + scan codebase
2. **Propose** — generate proposal, ask clarifying questions via chat
3. **Spec** — behavior specification, ask about business edge cases
4. **Design** — technical plan (autonomous)
5. **Tasks** — atomic task breakdown (autonomous)
6. **Apply** — implement task by task with progress reporting
7. **Verify** — tests, lint, self-review, convention audit
8. **Create PR** — structured PR with spec, design decisions, and acceptance criteria
9. **PR review loop** — monitor comments, address feedback, push fixes until approved

## Confidence model

The agent assesses confidence before each phase:

| Level | Criteria | Action |
|-------|----------|--------|
| HIGH | Small scope, existing pattern, clear requirements | Proceed silently |
| MEDIUM | Some ambiguity, reasonable defaults exist | Proceed, flag for review |
| LOW | Large scope, ambiguous requirements, no pattern | Stop and ask via chat |

## Escalation

The agent asks when:
- Business logic is ambiguous
- Scope exceeds 10 files
- Tests fail after 2 attempts
- Review comments request architectural changes

The agent does NOT ask when:
- Technical decisions are covered by conventions.md
- Code style follows project-rules.md
- Patterns exist in the codebase

## PR review loop

After creating the PR, the agent monitors for review comments:
- Change requests → implement, commit, push, reply
- Questions → answer from spec/design context
- Architectural concerns → escalate via chat

Continues until the PR is approved or the user stops the agent.

## When to use

- Assign a well-scoped task and let the agent work
- Best for tasks with clear requirements and existing patterns
- The human reviews the PR, not each intermediate phase
