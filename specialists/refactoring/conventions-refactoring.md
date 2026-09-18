# Specialist: Refactoring (Code Smells & Design Patterns)

> Rules for naming structural code-quality problems consistently and fixing them with the smallest effective change.
> Read by sdd-apply, sdd-audit, and sdd-verify as part of the steering ruleset.
> Works together with **anti-overengineering**: that specialist blocks unjustified patterns; this one names the smell that justifies one when it's real.

## Bloaters (code that outgrew a size it can be reasoned about at)

- **MUST** flag a method that cannot be summarized in one sentence as **Long Method** — fix: extract method.
- **MUST** flag a class accumulating unrelated responsibilities as **Large Class / God Class** — fix: extract class, delegate by responsibility.
- **MUST** flag raw strings/ints/arrays standing in for a concept with rules (money, IDs, email) as **Primitive Obsession** — fix: replace primitive with value object.
- **SHOULD** flag a growing function signature as **Long Parameter List** — fix: introduce parameter object.
- **SHOULD** flag the same group of fields/params reappearing together as **Data Clumps** — fix: extract class or parameter object.

## Object-Orientation Abusers

- **MUST** flag repeated type-checks or branching that grows with every new case as **Switch Statements** — fix: replace conditional with polymorphism, or Strategy — but only once there are 3+ variants (see anti-overengineering).
- **SHOULD** flag a field only populated on certain call paths as **Temporary Field** — fix: extract class for that conditional behavior.
- **SHOULD** flag a subclass that overrides/ignores most of what it inherits as **Refused Bequest** — fix: prefer composition over inheritance.
- **SHOULD** flag two classes doing the same job with inconsistent method names as **Alternative Classes with Different Interfaces** — fix: unify the interface.

## Change Preventers

- **MUST** flag a class that changes for many unrelated reasons as **Divergent Change** — fix: split by reason-to-change (single responsibility).
- **MUST** flag one logical change requiring edits across many unrelated files as **Shotgun Surgery** — fix: consolidate the scattered logic behind one abstraction.
- **SHOULD** flag hierarchies that must be extended in lockstep as **Parallel Inheritance Hierarchies** — fix: merge hierarchies or replace with composition.

## Dispensables (remove, don't fix)

- **MUST** flag copy-pasted logic as **Duplicated Code** — fix: extract method/function, consolidate call sites.
- **MUST** flag unreachable or unused code as **Dead Code** — fix: delete it; rely on git history, not comments.
- **MUST** flag unused hooks/params "for future use" as **Speculative Generality** — fix: remove it; this overlaps directly with anti-overengineering's abstraction rules.
- **SHOULD** flag a comment explaining what the code should say on its own as a smell — fix: rename/extract until the comment is unnecessary; keep only comments explaining *why*.

## Couplers

- **MUST** flag a method more interested in another object's data than its own as **Feature Envy** — fix: move method closer to the data it uses.
- **SHOULD** flag two classes routinely reaching into each other's internals as **Inappropriate Intimacy** — fix: move method/field, or introduce a clear interface.
- **SHOULD** flag long call chains reaching through several objects (`a.getB().getC().getD()`) as **Message Chains** — fix: hide delegate, introduce a facade method.
- **SHOULD** flag a class that only forwards calls with no behavior of its own as **Middle Man** — fix: remove it, call the real object directly (do not overcorrect Inappropriate Intimacy into this).

## Design pattern rules

- **MUST NOT** recommend a design pattern without naming the specific smell above it fixes. A pattern is a fix for a named problem, not a default.
- **MUST** prefer the smallest fix that removes the smell — extract method/class, rename, inline — before escalating to a full pattern.
- **MUST** defer to anti-overengineering's 3-concrete-uses threshold before introducing Factory, Strategy, Observer, or any other GoF pattern.
- **SHOULD** check existing project conventions (via domain-language / repo precedent) before importing a pattern the codebase has consistently avoided; flag the inconsistency instead of silently introducing it.

### Smell → common fix

| Smell | Typical fix |
|---|---|
| Switch Statements / conditional on type or state | Strategy, State, or replace conditional with polymorphism (3+ variants only) |
| Long Parameter List / Data Clumps | Builder or parameter object |
| Alternative Classes with Different Interfaces | Adapter |
| Message Chains / clients coupled to subsystem internals | Facade |
| Subclass explosion combining optional behaviors | Decorator |
| Manual "notify everyone who needs to know" at every mutation site | Observer |
| Duplicated Code across near-identical algorithm variants | Template Method |
| Divergent Change from unrelated operations added to one hierarchy | Visitor |

## How to detect violations

When reviewing code (during sdd-apply, sdd-audit, or sdd-verify), flag:
1. A method/function whose name needs "and" to describe what it does, or exceeds ~30 lines of mixed concerns.
2. A class with more than one clear reason to change.
3. A raw primitive used for a value with validation rules (money, email, locator/ID) instead of a value object.
4. A conditional branching on type/status that keeps growing new cases.
5. A design pattern introduced for fewer than 3 concrete variants, or with no named smell justifying it.

Classify as **Important** by default (blocks nothing on its own); escalate to **Critical** only when the smell sits in a shared/critical path (payment, auth, booking core) and actively blocks the current change.
