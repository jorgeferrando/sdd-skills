# /sdd-bug

> Bug-specific entry point. Validates 8-item evidence gate before drafting a proposal.

## Usage

```
/sdd-bug "checkout returns 500 when promo code is expired"
/sdd-bug TICKET-123
/sdd-bug --issue 42
```

Use this instead of `/sdd-new` when the change is a bug fix.

## Prerequisites

- `openspec/` initialized (auto-bootstrapped with `sdd-init --quick` if missing)

## What it does

1. **Reads the bug source** — direct description, GitHub issue, or Jira ticket
2. **Runs the 8-item audit** — presents a table with ✅ / ⚠️ / ❌ for each item
3. **Decides the exit path** — sufficient → proposal; unknown root cause → escalate to `sdd-diagnose`; anything else → `Bug intake incomplete` with one focused question
4. **Drafts `notes.md` and `proposal.md`** — pre-filled with bug context so downstream `sdd-spec` has structured evidence to consume

## The 8-item evidence gate

Every bug proposal must have all eight before drafting:

| # | Field | What "present" means |
|---|-------|----------------------|
| 1 | Current broken behavior | Observable symptom in concrete terms |
| 2 | Expected correct behavior | Stated distinctly from current |
| 3 | Reproduction steps or trigger | Exact sequence, or the trigger when non-deterministic |
| 4 | Evidence source | Log, trace, screenshot, ticket, alert — something you can cite |
| 5 | Impact / severity | Who, how many, how badly, business consequence |
| 6 | Affected scope | Module, service, environment, user segment, provider |
| 7 | Root cause status | `known` \| `suspected` \| `unknown` |
| 8 | Regression guard | The test that will fail if this returns |

## Key concepts

**One question per turn on missing evidence.** When the audit finds gaps, `sdd-bug` picks the single most blocking item and asks about it — never batches. Batching collapses answer quality.

**Draft-with-blockers escape hatch.** Users can override the gate explicitly (`draft what you have`) — in that case the proposal is drafted with `Needs clarification` assessment and every gap listed as a blocking Open Question.

**Do not invent to close a gap.** An unfilled item is data. Guessing produces specs that mask the missing information.

## Artifacts produced

- `openspec/changes/{change-name}/notes.md` — structured bug context
- `openspec/changes/{change-name}/proposal.md` — pre-filled proposal with bug framing

Both are only written when the gate passes (or under the explicit override).

## Next step

- Evidence sufficient → `/sdd-continue` (runs `/sdd-spec`)
- Root cause `unknown` + non-deterministic repro → `/sdd-diagnose "{symptom}"`
- Evidence insufficient → answer the focused clarification, then re-run `/sdd-bug`
