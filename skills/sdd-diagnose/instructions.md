---
name: sdd-diagnose
description: SDD Diagnose - Evidence-based diagnosis for bugs, regressions, incidents, alerts, and performance issues. Establishes root cause before fixes are proposed. Usage - /sdd-diagnose "symptom" or invoked from /sdd-bug when evidence is insufficient.
model_hint: sonnet
requires: ["openspec/config.yaml"]
produces: ["openspec/changes/{change}/diagnosis.md"]
---

# SDD Diagnose

> Build a reliable diagnosis from evidence before proposing fixes. Symptom-first, hypothesis-second, fix-last.

## Usage

```
/sdd-diagnose "checkout intermittently returns 500 on promo apply"
/sdd-diagnose                    # Diagnose the active change (bug context assumed)
/sdd-diagnose {change-name}      # Diagnose a specific existing change
```

Use when:

- Symptom is reported but root cause is unknown.
- Multiple plausible causes exist.
- Confidence is too low to choose a safe fix.
- Validation is unclear without first understanding why behavior diverged.

Skip when the bug's root cause is already `known` and reproducible — go straight to `/sdd-bug` or `/sdd-new`.

## Prerequisites

- `openspec/` initialized (if not, runs `sdd-init --quick`)

## Core rule

**Do not propose fixes, implementation plans, or continue into spec/design/code work until diagnosis is complete for the current evidence set.** Diagnosis output is the exit — not "let's also start fixing while we're here".

## Step 1: Identify the reported symptom

Restate the symptom in observable terms without assuming a cause. Separate what the reporter *claimed* from what is *currently verifiable*.

**Anti-pattern:** *"The cache is broken."* — that's a hypothesis, not a symptom.
**Correct:** *"After N requests within M seconds, endpoint X returns stale data (evidence: log line at 12:04:17, user report #4231)."*

Write to `diagnosis.md` as **Symptom statement**:

```markdown
## Symptom statement

**Reported:** {what the reporter said, verbatim if possible}
**Observable:** {what can be independently verified right now}
**Not yet verified:** {parts of the report that need confirmation}
```

If reported ≠ observable, that gap alone is often the diagnosis (e.g., reporter conflated two symptoms).

## Step 2: Collect available evidence

Gather what exists and record what does not. Evidence sources to check depending on the domain:

- **Logs** — application logs, error tracker (Sentry, etc.), audit trails
- **Metrics** — dashboards, RUM, APM traces, alert history
- **Reproduction** — steps that trigger the symptom, or the trigger condition
- **Configuration** — environment variables, feature flags, deployed version, recent config changes
- **Recent changes** — `git log` since the last known-good state, recent PRs, recent deploys
- **Related tickets** — prior reports of the same or adjacent symptoms

Write **Evidence inventory** to `diagnosis.md`:

```markdown
## Evidence inventory

### Available
- {source}: {what it contains, one line}
- {source}: {what it contains, one line}

### Missing / inaccessible
- {source}: {why it's missing — no access, not yet collected, not existent}
- {source}: {…}
```

**Missing-evidence rule:** if a key source is missing, do not skip. Record the gap and (in Step 4) reason about which candidate causes it would help discriminate.

## Step 3: Establish the expected behavior

Define what "correct" looks like using specs, documentation, test assertions, or known-good prior behavior. This is the baseline for judging what "diverged" means.

Write **Expected behavior baseline** to `diagnosis.md`:

```markdown
## Expected behavior baseline

**Expected:** {precise statement of what should happen}
**Source:** {spec path, doc URL, test name, commit hash of known-good version, or PM statement}
```

Without this baseline, "wrong" is unfalsifiable. If no baseline exists — e.g., undocumented behavior with no test coverage — say so explicitly and treat the diagnosis as also producing a spec gap.

## Step 4: Narrow the scope

Use the evidence to eliminate candidate causes. Trace from symptom toward origin. Identify where behavior diverges from expectation. Reduce investigation to the smallest component or interaction that still reproduces the issue.

Write **Narrowed scope** to `diagnosis.md`:

```markdown
## Narrowed scope

### Candidates eliminated
- {candidate}: {why ruled out — evidence link}
- {candidate}: {why ruled out — evidence link}

### Remaining investigation boundary
- {file/module/interaction that still contains the divergence}
- {…}
```

**Do this before proposing a cause.** The eliminated list is as important as the retained one — it shows the reasoning is falsifiable.

## Step 5: State the diagnosis

Declare the root cause or the most likely cause with supporting evidence.

If certainty is not achievable with current evidence, list the remaining candidates and — critically — the additional evidence that would discriminate between them.

**Diagnosis is complete only when it explains *why* the symptom occurs, not just *where* it appears.**

Write **Diagnosis statement** to `diagnosis.md`:

```markdown
## Diagnosis statement

**Confidence:** {confirmed | most likely | unresolved}

### Root cause (or most likely cause)
{One paragraph: what is happening, why it causes the symptom, and how it connects to the expected behavior baseline}

### Supporting evidence
- {evidence item → why it supports this cause}
- {evidence item → why it supports this cause}

### Remaining candidates (only if unresolved)
| Candidate | Discriminating evidence needed | Notes |
|-----------|-------------------------------|-------|
| {A} | {what would confirm or rule out} | {…} |
| {B} | {what would confirm or rule out} | {…} |

### Currently favored (only if unresolved)
{Which candidate, and what tips it}
```

## Complete diagnosis output

The completed `diagnosis.md` has all 5 sections:

1. Symptom statement
2. Evidence inventory
3. Expected behavior baseline
4. Narrowed scope
5. Diagnosis statement

Missing any one → diagnosis is not complete. Do not present it as complete.

Store the file at:

```
openspec/changes/{change-name}/diagnosis.md
```

If there is no active change yet (user invoked `/sdd-diagnose` cold), create a change dir with a kebab-case slug derived from the symptom.

## Anti-patterns

Do not:

- **Jump from intuition straight to fix.** Even when you "know" the answer, write it as a diagnosis statement with supporting evidence — future readers need the trail.
- **Treat correlation as root cause.** "It started when we deployed X" is a hypothesis, not a diagnosis. Prove that X causes the symptom (revert X, does it stop? feature-flag X off in one env, does it stop?).
- **Skip the expected behavior baseline.** If you cannot state what should happen, you cannot state that anything is wrong.
- **Advance past unresolved evidence gaps silently.** If Step 2 has ❌ items critical to Step 4 or Step 5, name that dependency in Step 5 as "cannot resolve without X".
- **Bundle a fix into the diagnosis.** This skill outputs `diagnosis.md` — nothing else. The fix goes through `/sdd-bug` → `/sdd-spec` → `/sdd-design`, informed by this diagnosis.

## When diagnosis is `unresolved`

Present the output to the user with a next-action recommendation:

```
DIAGNOSIS INCOMPLETE — evidence gaps prevent root-cause identification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Written: openspec/changes/{change-name}/diagnosis.md

Currently favored: {candidate}

To close the gap:
  [1] Collect: {specific evidence — how to get it}
  [2] Run: {command or experiment that would discriminate}
  [3] Escalate: {who owns the answer if it's not investigable from code}

Re-run /sdd-diagnose after collecting evidence.
```

Do not push forward to `/sdd-bug` or `/sdd-spec` until diagnosis is at least `most likely` with named supporting evidence.

## When diagnosis is `confirmed` or `most likely`

Present:

```
DIAGNOSIS COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Written: openspec/changes/{change-name}/diagnosis.md
Confidence: {confirmed | most likely}
Root cause: {one line}

Next: /sdd-bug — the diagnosis fills bug-intake items 3, 6, and 7.
```

The diagnosis feeds `sdd-bug` — root cause status becomes `known` (or `suspected` with strong evidence), reproduction / trigger is documented, affected scope is narrowed.

## Notes

- This skill is **read-only + write-diagnosis**. No code changes, no fixes, no spec edits.
- Diagnose applies beyond bugs: performance regressions, flaky tests, alerts, incidents — any situation where behavior diverges from expectation and cause is unclear.
- If invoked from `/sdd-bug` Step 6, the change directory already exists — write `diagnosis.md` there, do not create a second slug.

## Next Step

- Diagnosis confirmed / most likely → `/sdd-bug` (or `/sdd-continue` if a bug proposal already exists that just needed root-cause data)
- Diagnosis unresolved → collect the discriminating evidence listed, then re-run `/sdd-diagnose`
