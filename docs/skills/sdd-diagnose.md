# /sdd-diagnose

> Build a reliable diagnosis from evidence before proposing fixes. Symptom-first, hypothesis-second, fix-last.

## Usage

```
/sdd-diagnose "checkout intermittently returns 500 on promo apply"
/sdd-diagnose                    # Diagnose the active change
/sdd-diagnose {change-name}      # Diagnose a specific change
```

## Prerequisites

- `openspec/` initialized (auto-bootstrapped with `sdd-init --quick` if missing)

## When to use

- Symptom reported but root cause is unknown
- Multiple plausible causes exist
- Confidence too low to choose a safe fix
- Validation is unclear without first understanding *why* behavior diverged

Skip when the root cause is already `known` and reproducible — go straight to `/sdd-bug` or `/sdd-new`.

## What it does

Runs the 5-step evidence-first workflow:

1. **Symptom statement** — restate observable, separate reporter claims from currently verifiable facts
2. **Evidence inventory** — collect what's available; record what's missing
3. **Expected behavior baseline** — define what "correct" is, cite the source (spec, doc, test, known-good version)
4. **Narrowed scope** — eliminate candidates with evidence; state the remaining boundary
5. **Diagnosis statement** — root cause (confirmed / most likely / unresolved) with supporting evidence

Only after all 5 sections exist is the diagnosis considered complete.

## Key concepts

**Diagnosis explains *why*, not just *where*.** A statement like *"the bug is in `CheckoutService`"* is a location, not a diagnosis. Why does the code produce the symptom? What invariant is being violated?

**Correlation is not diagnosis.** *"It started when we deployed X"* is a hypothesis. Prove causation before recording it as root cause (revert X and confirm the symptom stops; flag-off X in one env and compare).

**Missing evidence is named, not skipped.** If a source is inaccessible or missing, it goes in the inventory as `missing / inaccessible` with why. The final diagnosis references those gaps if they block resolution.

## Artifacts produced

- `openspec/changes/{change-name}/diagnosis.md` — the 5-section document

No code changes. No fixes. No proposal.md or spec.md — those come after diagnosis, informed by it.

## Anti-patterns

- Jumping from intuition to fix without recording the diagnostic trail
- Treating correlation as root cause
- Skipping the expected behavior baseline ("we all know how it should work")
- Bundling a fix into the diagnosis document
- Advancing to spec / design with an unresolved diagnosis

## Next step

- Diagnosis confirmed or most likely → `/sdd-bug` (root cause now `known` / `suspected`, gate closes cleanly)
- Diagnosis unresolved → collect the discriminating evidence listed in the doc, then re-run `/sdd-diagnose`
