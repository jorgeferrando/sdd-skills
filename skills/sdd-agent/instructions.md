---
name: sdd-agent
description: SDD Agent - Autonomous orchestrator that executes the full SDD cycle for a given task. Interacts via chat (Slack, web, or terminal) when it needs input. Usage - /sdd-agent "task description" or triggered by external systems.
model_hint: sonnet
requires: ["openspec/config.yaml"]
produces: ["openspec/changes/{change}/proposal.md", "openspec/changes/{change}/specs/*/spec.md", "openspec/changes/{change}/design.md", "openspec/changes/{change}/tasks.md"]
---

# SDD Agent

> Autonomous orchestrator that runs the full SDD cycle for a task. Works without supervision when it can, asks via chat when it can't.

## Usage

```
/sdd-agent "add rate limiting to the public API"
/sdd-agent --issue 42          # From GitHub issue #42
/sdd-agent --ticket PROJ-123   # From Jira ticket
```

## Prerequisites

- `openspec/` initialized (if not, runs `sdd-init --quick` automatically)
- Git repo with clean working tree

## Model selection

Each sub-skill declares a `model_hint` in its frontmatter. When spawning subagents, use the hint to select the most cost-effective model:

| Hint | Model | Use for |
|------|-------|---------|
| `opus` | Most capable | Judgment-heavy phases: propose, design |
| `sonnet` | Balanced | Code comprehension: explore, spec, apply subagents, verify, audit, steer |
| `haiku` | Fastest/cheapest | Mechanical phases: tasks, archive, recall, docs, continue, apply orchestrator |

Pass `model: "{model_hint}"` when spawning each subagent. If the tool does not support model selection, ignore the hint and proceed with the default model.

## Confidence model

Before each phase, assess confidence:

| Level | Criteria | Action |
|-------|----------|--------|
| **HIGH** | Scope < 5 files, existing pattern to follow, clear requirements | Proceed silently |
| **MEDIUM** | Scope 5-10 files, some ambiguity but reasonable defaults exist | Proceed, flag in PR description as "needs review" |
| **LOW** | Scope > 10 files, ambiguous requirements, no similar pattern, conflicting conventions | **Stop and ask** via chat |

Always classify before proceeding. When in doubt, ask — a junior that asks is better than one that guesses wrong.

## Step 1: Parse input

Read the task from:
- Direct description (string argument)
- GitHub issue (if `--issue N`): read title + body + comments via `gh issue view N`
- Jira ticket (if `--ticket ID`): read from Jira API

Extract:
- **Goal:** what needs to be built/fixed
- **Constraints:** any mentioned limitations, deadlines, or dependencies
- **Acceptance criteria:** explicit conditions if provided, otherwise derive from the goal

If the input is too vague to determine scope (e.g., "improve performance"), ask:
```
The task is broad. To proceed, I need to know:
- Which part of the system? (e.g., API response time, database queries, frontend load)
- What is the target? (e.g., < 200ms response, 50% reduction)
```

## Step 2: Bootstrap + load steering

```bash
ls openspec/steering/conventions.md
```

If missing, run `sdd-init --quick` to bootstrap openspec/ with sensible defaults. Do not ask — a junior sets up their workspace without being told.

**Prompt caching**: read all steering files once here (conventions.md, project-rules.md, tech.md, relevant specialists). Pass this content as a fixed prefix in all subsequent subagent prompts. This ensures cache hits across the sequential agents in Steps 4-8.

## Step 3: Explore with recall

Run the `sdd-explore` workflow:
1. Search archived specs and past decisions (recall)
2. Scan the codebase for similar patterns
3. Identify affected files and domains
4. Write findings to `openspec/changes/{change-name}/notes.md`

**Confidence check:** If recall finds a previous spec in the same domain that was explicitly scoped differently, flag it:
```
I found a previous spec for this domain that explicitly excluded {X}.
Your task seems to include {X}. Should I proceed including it, or respect the previous boundary?
```

## Steps 4-8: Execute SDD phases

Run each phase using the corresponding skill instructions. Use the `model_hint` from each skill's frontmatter when spawning subagents.

| Step | Skill | Mode | Confidence check |
|------|-------|------|-----------------|
| 4. Propose | `sdd-propose` | inline | Show proposal summary in chat, wait for approval before continuing |
| 5. Spec | `sdd-spec` | inline | Ask about business logic edge cases only; technical decisions follow conventions |
| 6. Design + Tasks | `sdd-design` (agent) → `sdd-tasks` (inline) | agent+inline | If > 10 files: ask whether to proceed, split, or hand off |
| 7. Apply | `sdd-apply --auto` | inline | Report progress per task; if a task fails after 1 retry, ask with context |
| 8. Verify | `sdd-verify` | agent | Do not create the PR — the orchestrator creates it in Step 9 |

Between phases, apply the **confidence model** above. At LOW confidence on any phase, stop and ask.

## Step 9: Create PR

Create the pull request with structured description:

```bash
git push -u origin {branch-name}
gh pr create --title "{title}" --body "{body}"
```

PR body template:
```markdown
## Task
{Original task description or issue link}

## What this PR does
{1-3 sentences from proposal.md}

## Spec
{Key behaviors from spec.md — Given/When/Then summary}

## Design decisions
{Decision table from design.md}

## Changes
{File list from tasks.md with one-line descriptions}

## Acceptance criteria
{From proposal.md}

---
Generated by SDD Agent | [View full artifacts](openspec/changes/{change}/)
```

Report in chat:
```
✅ PR created: {repo}#{number}
  {title}
  {N} commits, {N} files changed
  Tests: all passing
  
  Waiting for review.
```

## Step 10: PR review loop

After creating the PR, monitor for review comments:

```bash
gh pr view {number} --json reviews,comments
```

When a review comment arrives:
1. Read the comment
2. If it's a change request: implement the fix, commit, push, reply to the comment
3. If it's a question: answer based on the spec/design context
4. If it requires a decision outside scope: ask via chat

```
Review comment on PR #{number} from @reviewer:
  "Why did you use middleware instead of a decorator pattern?"

My response (from design.md):
  "The middleware pattern was chosen because the existing codebase uses
   middleware for all cross-cutting concerns (auth, logging). Following
   the established pattern per conventions.md."

Should I reply with this, or do you want to adjust?
```

After addressing all comments, report:
```
PR #{number}: addressed {N} review comments, pushed {N} new commits.
Waiting for re-review.
```

Repeat until the PR is approved or the user stops the agent.

## Escalation protocol

**Ask** when: business logic is ambiguous, scope changes beyond proposal, tests fail after 2 attempts, review requests architectural change, or confidence is LOW.

**Don't ask** when: covered by conventions.md, project-rules.md, or existing patterns.

**How**: be specific ("Should X return 404 or 204?"), offer options with trade-offs, max 3 questions at a time.

## Notes

- The chat channel (Slack, web, terminal) is injected by the runtime — this skill is channel-agnostic
- `AskUserQuestion` is the mechanism for all chat interactions
- If running headless (no chat), treat all MEDIUM confidence as HIGH and skip questions
- The PR review loop runs until approval, explicit stop, or configured timeout
