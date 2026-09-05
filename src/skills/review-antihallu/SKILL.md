---
name: review-antihallu
description: Detects agent hallucinations in generated code — invented APIs, plausible-but-wrong logic, drift from the plan. Preloaded in the reviewer subagent, and the single home of the review procedure.
---
# Anti-hallucination review

An agent produces plausible code. Plausible ≠ correct. This review hunts for the gap, and a
fresh context spots it better than the agent that wrote the code.

## Verification procedure (do it, don't skim)

**1. Establish what already passed, before running anything.** The implementer wrote
`docs/verif/<id>.md`: the commands it ran, their exit codes, and the `Tree:` they covered.
Check it with `ks-gate verif-current <id>` — or `git diff --quiet <Tree> HEAD -- .
':(exclude)docs'` where the hook isn't installed.

- **Current** (exit 0, `Verification status: complete`, every recorded exit code 0) → the
  suite and the type check are proven for this exact code. Do not re-run them; say in the
  report what you took from the record, and read its "Not proven here" section.
- **Missing, incomplete, stale, or any non-zero exit code** → run them yourself and say why.

"Tests pass" written in prose is a claim; a record whose tree matches the commit is a fact.
That is the whole difference. Fail-closed: an absent record is never a pass.

**Do not run the production build or the end-to-end suite** — they run at ship (`Build stage`,
`E2E stage`). One exception: a diff that moves a route or a manifest, the rupture a type check
structurally cannot see. **Take the linter, the formatter and any dead-code scan as reported**:
they were proven by the implementer, cannot change silently since, and CI runs them anyway.

**2. Open every reference.** For each import, function call, API and config key in the diff:
open the target and verify it exists — exact name, exact signature, exact location. Invented
references are the #1 agent failure.

**3. Diff vs plan, task by task.** Every plan task actually present? Anything in the diff the
plan never asked for? Drift in either direction is a finding. A diff that contradicts a
verified fact of the research, or an accepted ADR in `docs/decisions/`, is a finding too.

**4. Read the tests like production code.**

*Judge the net.* Look for a test that names an invariant without exercising it. Check the
FIXTURES and the mock doubles, not only the assertions — a fixture whose identifier lets a
downstream guard answer for the guard under test, or a double that replays a clause instead of
evaluating it, both read as correct and prove nothing. Reject decorative tests: CSS classes,
DOM structure, static labels, prop echoes and inventories are not coverage.

*Judge the volume.* `Test budget` per story, more only if the plan justified it. A permission
matrix replayed per command, an enum tested exhaustively, an adapter re-asserting a 403 the
policy already owns — each is a finding, classified minor, and worth naming because CI time
is a real cost.

*Prove the bite.* Pick the one or two invariants the story turns on (a guard, predicate, state
transition or query clause) and neutralize them: invert the condition, return the opposite
constant, drop the clause. **Run only the test files that name that invariant — never the
whole suite**: a neutralized guard turns red where it is tested, and replaying the project to
learn it is the most expensive habit a review can have. COUNT the red tests, then restore and
prove the tree is clean (`git diff --exit-code` on the file) before writing a line of report.
Report what you neutralized and how many went red. **Zero red on a neutralized invariant means
it is untested**, whatever the suite's total says — a finding, not a detail. A presentation-only
change needs its browser evidence, not a forced mutation. An unrestored mutation is a worse
defect than the one you were hunting.

**5. Hunt plausible-but-wrong logic**: values that look right — defaults, formats, status
codes, edge conditions — but were never checked against reality.

**6. Regressions**: what else uses the touched code paths? Open it.

## Severity scale

- **critical** — ships a bug, a security hole, an invented API, or breaks existing behavior.
  Blocks the ship.
- **major** — real defect or rule violation, but scoped and not silently corrupting anything.
  Ship allowed, fix next cycle.
- **minor** — style, naming, small cleanups.
