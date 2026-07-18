---
name: review-antihallu-skill
description: Detects agent hallucinations in generated code — invented APIs, plausible-but-wrong logic, drift from the plan. Preloaded in the reviewer subagent.
---
# Anti-hallucination review

An agent produces plausible code. Plausible ≠ correct. This review hunts for the gap.

Verification procedure (do it, don't skim):
1. Run the test suite yourself. A summary claiming "tests pass" is a claim, not a fact.
2. For every import, function call, API and config key in the diff: open the target and verify it exists — exact name, exact signature, exact location. Invented references are the #1 agent failure.
3. Diff vs plan, task by task: every plan task present? anything in the diff the plan never asked for? Drift in either direction is a finding.
4. Read the tests like production code: do the assertions pin the acceptance criteria, or would they pass on a broken implementation? An assertion-free test is a hallucinated safety net.
5. Hunt plausible-but-wrong logic: values that look right (defaults, formats, status codes, edge conditions) but were never checked against reality.
6. Regressions: what else uses the touched code paths? Open it.

Severity scale:
- **critical** — ships a bug, a security hole, an invented API, or breaks existing behavior. Blocks the ship.
- **major** — real defect or rule violation, but scoped and not silently corrupting anything. Ship allowed, fix next cycle.
- **minor** — style, naming, small cleanups.

A fresh context spots these gaps better than the agent that wrote the code. That's why this review runs in an isolated subagent.

<< IP Mike: real heuristics, hallucination examples seen in prod, severity thresholds. >>
