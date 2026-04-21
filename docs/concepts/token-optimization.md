# Token Optimization

SDD skills include several strategies to minimize token usage and cost across the workflow. These strategies work together — model selection reduces cost per token, while context management reduces the number of tokens processed.

## Model selection (`model_hint`)

Each skill declares the minimum model tier needed in its `model_hint` frontmatter field. Orchestrators (`sdd-agent`, `sdd-ff`, `sdd-continue`) pass this hint when spawning subagents.

| Hint | Use for | Skills |
|------|---------|--------|
| `opus` | Judgment-heavy phases: design decisions, solution analysis | sdd-propose, sdd-design |
| `sonnet` | Code comprehension: analysis, spec writing, implementation | sdd-explore, sdd-spec, sdd-apply (subagents), sdd-verify, sdd-audit, sdd-steer, sdd-init, sdd-new, sdd-ff, sdd-discover, sdd-agent |
| `haiku` | Mechanical phases: template-filling, search, dispatch | sdd-tasks, sdd-archive, sdd-recall, sdd-docs, sdd-continue, sdd-apply (orchestrator) |

Using `opus` only for propose and design (the judgment phases) while running mechanical phases on `haiku` can reduce cost by 60-70%.

## Context management

### The artifact chain

Each SDD phase produces a file that captures all decisions. After a phase completes, the conversation context is redundant with the artifact:

```
explore  → notes.md       (findings)
propose  → proposal.md    (scope decisions)
spec     → spec.md        (behavior)
design   → design.md      (architecture)
tasks    → tasks.md        (execution plan)
apply    → commits         (code)
verify   → PR              (result)
```

### When to clear context

| Moment | Clear? | Reason |
|--------|--------|--------|
| Between explore and propose | No | Coupled — exploration feeds proposal questions |
| After propose | Yes | `proposal.md` captures everything |
| After spec | Yes | `spec.md` captures everything |
| After design | Yes | `design.md` captures everything |
| After tasks | **Yes** (most important) | Apply is the longest phase — entering clean saves the most |
| During apply | No | Subagents already isolate context |
| After verify | Yes | PR created, everything captured |

### Why this matters

If context is 50K tokens after propose + spec and 15 turns of apply remain, that is 50K × 15 = **750K tokens of input** carrying stale context. Clearing after tasks and re-reading the artifacts (~5K tokens) saves massively.

`/sdd-continue` makes this natural — it detects the current phase from the artifacts, not from conversation history.

## Selective steering loading

Skills that read `openspec/steering/` load only relevant specialist files, not all `.md` files. The selection is based on the task's files:

- Specialists with `applies_to: all` in their manifest → always loaded
- `conventions-testing.md` → only when the task touches test files
- `conventions-security.md` → only when the task touches auth, API, or input handling
- Other specialists → only when the file matches the specialist's domain

With 5+ specialists installed, this reduces steering context from ~8KB to ~3KB per subagent.

## Prompt caching

Orchestrator skills (`sdd-apply`, `sdd-agent`) read steering files once and pass the content inline to subagent prompts. This creates a fixed prefix that benefits from LLM prompt caching (5-minute TTL) across sequential agents.

The same strategy applies to `sdd-discover`, which uses an identical prompt prefix across all parallel domain subagents.

## Output style

All skills include a terse output directive. Status reports use tables and single-line bullets instead of prose. This reduces response tokens (which also cost money) without losing information.

## English artifacts

All generated artifacts (proposal.md, spec.md, design.md, tasks.md, notes.md) are written in English. English uses approximately 30% fewer tokens than Romance languages (Spanish, French, Portuguese) for the same semantic content.
