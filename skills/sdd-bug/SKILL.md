---
name: sdd-bug
description: SDD Bug - Bug-specific entry point that validates minimum evidence before drafting a proposal. Alternative to /sdd-new when the change is a bug fix. Usage - /sdd-bug "short bug summary" or /sdd-bug TICKET-123.
model_hint: sonnet
requires: ["openspec/config.yaml"]
produces: ["openspec/changes/{change}/notes.md", "openspec/changes/{change}/proposal.md"]
---

# SDD Bug

> Bug-specific readiness gate. Validates minimum evidence before drafting the proposal. Prevents specs and code built on guesses.

## Usage

```
/sdd-bug "checkout returns 500 when promo code is expired"
/sdd-bug TICKET-123
/sdd-bug --issue 42
```

Use this instead of `/sdd-new` when the change is a bug fix. For features and refactors, use `/sdd-new` or `/sdd-ff`.

## Prerequisites

- `openspec/` initialized (if not, runs `sdd-init --quick` automatically)

## Minimum bug evidence (the 8-item gate)

A bug-like request is intake-ready only when all of these are present. Missing any single item makes evidence **insufficient**.

| # | Field | What "present" means |
|---|-------|----------------------|
| 1 | **Current broken behavior** | Observable symptom in concrete terms (error message, wrong output, missing UI, timing anomaly) |
| 2 | **Expected correct behavior** | Distinct from current; states what should happen instead |
| 3 | **Reproduction steps or trigger** | Exact sequence, or the trigger condition when repro isn't deterministic |
| 4 | **Evidence source** | Log line, stack trace, screenshot, ticket ID, alert URL, user report — something you can point at |
| 5 | **Impact / severity** | Who is affected, how many, how badly, with what business consequence |
| 6 | **Affected scope** | Which module, service, environment, user segment, or provider |
| 7 | **Root cause status** | `known` \| `suspected` \| `unknown` — decides whether the fix is direct or needs `sdd-diagnose` first |
| 8 | **Regression guard** | What test or check will prevent this from silently coming back |

Fields 5, 7, and 8 are the ones users most often skip. Do not fill them in from guesses.

## Step 1: Parse input

Read the bug source from:
- Direct description (string argument)
- GitHub issue (`--issue N`): read title + body + comments via `gh issue view N`
- Jira ticket (`--ticket ID`): read from Jira API if available

Extract every field of the 8-item checklist that is already present in the source. Do not paraphrase — quote verbatim so you can distinguish reported claims from inferences.

## Step 2: Bootstrap if needed

```bash
ls openspec/steering/conventions.md
```

If missing, run `sdd-init --quick`. Do not ask.

## Step 3: Evidence audit

For each of the 8 items, mark one of:

- ✅ **present** (evidence exists in the source, quote it)
- ⚠️ **partial** (some info but not testable — e.g., "impact: users are complaining" without count or segment)
- ❌ **missing** (nothing in the source)

Show the audit to the user as a table before doing anything else:

```
BUG INTAKE AUDIT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[✅] Current behavior      : {quoted evidence}
[✅] Expected behavior     : {quoted evidence}
[⚠️] Reproduction          : {what's partial}
[❌] Evidence source       : —
[❌] Impact/severity       : —
[✅] Affected scope        : {quoted evidence}
[⚠️] Root cause status     : {suspected|unknown — inferred}
[❌] Regression guard      : —
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Status: INSUFFICIENT — 3 missing, 2 partial
```

## Step 4: Decide the exit path

Apply this decision table:

| Situation | Path |
|-----------|------|
| All 8 present | → Step 5 (draft proposal + notes) |
| Root cause = `unknown` AND repro is not deterministic | → Step 6 (recommend `sdd-diagnose`) |
| Any other missing/partial item | → Step 7 (Bug intake incomplete) |

**Rule:** never invent an answer to close a missing item. An unfilled gap is data.

## Step 5: Draft proposal and notes

Create the change directory and write two artifacts:

```bash
mkdir -p openspec/changes/{change-name}
```

**`notes.md`** — structured bug context that `sdd-spec` will consume downstream:

```markdown
# Bug Notes: {change-name}

## Source
- {URL, ticket ID, or "direct description"}
- Reporter: {who or "internal"}
- Date reported: {YYYY-MM-DD}

## Evidence

### Current behavior (observed)
{Verbatim symptom from the source}

### Expected behavior
{What should happen instead — stated positively, not "not this"}

### Reproduction
{Steps or trigger — exact}

### Evidence source
- {log line / stack trace / screenshot / ticket comment — with reference}

### Impact
- Who: {segment, count if known}
- How often: {frequency or "every request" / "intermittent"}
- Business consequence: {revenue lost, user friction, compliance risk, etc.}

### Affected scope
- Module/service: {name}
- Environment: {prod | staging | all}
- Provider/version if relevant: {e.g., "Adyen SDK v5.19"}

### Root cause status
- Status: {known | suspected | unknown}
- Hypothesis (if suspected): {current best guess with reasoning}

### Regression guard
- Test to add: {file path or description of the check that will fail if this returns}
```

**`proposal.md`** — the standard change proposal with bug context pre-filled:

```markdown
# Proposal: Fix — {short title}

## Problem
{Current behavior + impact in 2-3 sentences. Cite notes.md for details.}

## Proposed Solution
{High-level fix approach. If root cause is `known`, be specific. If `suspected`, state the hypothesis explicitly.}

## Alternatives Discarded
{Fixes considered but rejected, and why — often "fix symptom vs fix root cause".}

## Impact
- Files affected: {list, or "TBD in design"}
- Tests needed: {regression test from notes.md + any others}
- Rollout risk: {low | medium | high — with reason}
```

Mark `proposal.md` header with the assessment:

```markdown
> Assessment: **Ready for spec** — all 8 bug-intake items satisfied.
```

Present a short confirmation to the user:

```
BUG INTAKE COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Change: openspec/changes/{change-name}/
Artifacts: notes.md, proposal.md
Assessment: Ready for spec
Next: /sdd-continue → runs /sdd-spec
```

## Step 6: Escalate to `sdd-diagnose`

When root cause is `unknown` and repro is non-deterministic, drafting a proposal on top would be a guess. Emit:

```
BUG INTAKE — DIAGNOSIS REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Evidence is present for most items, but root cause is `unknown` and
reproduction is not deterministic. Drafting a fix now would be
guessing.

Recommended: /sdd-diagnose "{short symptom description}"

After diagnosis lands (produces diagnosis.md with a root cause statement
or an explicit "most likely cause" plus discriminating evidence),
re-run: /sdd-bug — the diagnosis will satisfy items 3, 6, and 7.
```

Do not create `proposal.md`. Do not create `notes.md`. Nothing is written until evidence is sufficient.

## Step 7: Return `Bug intake incomplete`

When evidence is insufficient (any item missing or partial and Step 6 doesn't apply), emit one focused clarification request and stop:

```markdown
**Bug intake incomplete**

- Reason: missing evidence (see audit above)

- Known facts:
  - {each ✅ item, one line, verbatim from source}

- Blocking gap:
  - {the single most important missing item — pick one, don't batch}

- Why it blocks:
  - {one line explaining what decision downstream can't be made without this}

- First question:
  - {ONE focused question that would close the blocking gap}
```

**Rules for the clarification:**

- **One question per turn.** Batching collapses answer quality. If two items are missing, ask about the more consequential one first; the second becomes the next turn.
- **The question must be answerable in a sentence.** "What are the steps to reproduce?" — good. "Explain the whole flow" — bad.
- **Prefer questions the user can answer without leaving the chat.** If a log line is needed, ask them to paste it; if a ticket comment, ask for its content.

Do not create `proposal.md`. Do not create `notes.md`. Do not proceed to `sdd-spec`.

## Draft-with-blockers escape hatch

If the user explicitly overrides the gate — *"draft what you have"*, *"proceed with open questions"*, *"write a non-ready proposal"* — do this:

1. Create `notes.md` with every ✅ item filled and every ❌/⚠️ item marked `TBD (blocking open question — needs {who} answer)`.
2. Create `proposal.md` with the header:
   ```markdown
   > Assessment: **Needs clarification** — bug intake incomplete, drafted at user's explicit request.
   ```
3. Add an "Open Questions" section listing every missing/partial item with owner.
4. In the confirmation, **do not** suggest `/sdd-continue` — surface that spec cannot be safely written until blockers are resolved.

Never do this silently. The override must be explicit and named in `notes.md`.

## Anti-patterns

Do not:

- Fill missing items with plausible-sounding assumptions ("probably affects all users").
- Batch several missing items into one question hoping the user answers them all.
- Skip Step 3 (the audit table). The user needs to see the gate, not just the verdict.
- Recommend `sdd-diagnose` for a bug where root cause is already `known`. Diagnose is for when there is genuinely no confirmed cause, not to pad the workflow.
- Silently downgrade a `Bug intake incomplete` into `Ready for spec` after one round of clarification. Re-audit against the 8 items every time.

## Notes

- This skill is the bug-flow analog of `/sdd-new`. Features and refactors keep using `/sdd-new` / `/sdd-ff`.
- Downstream skills (`sdd-spec`, `sdd-design`) do not need modification — `notes.md` and `proposal.md` produced here fit the existing pipeline.
- If the change turns out to be a feature midway (the reporter mis-classified it), just tell the user: *"This looks like a feature request, not a bug — use `/sdd-new` instead."* Don't force it through this gate.

## Next Step

- Evidence sufficient → `/sdd-continue` (runs `/sdd-spec`)
- Root cause unknown + non-deterministic repro → `/sdd-diagnose "{symptom}"`
- Evidence insufficient → answer the focused clarification question, then re-run `/sdd-bug`
