---
name: tdd-skill
description: Test-first discipline for agentic implementation. Preloaded in the implementer subagent.
---
# Agentic TDD

For each task in the plan:
1. Write a failing test that describes the expected behavior.
2. Run it and watch it fail. This step is not optional: a test you never saw fail proves nothing.
3. Write the minimum code to make it pass.
4. Run the suite. Refactor if needed, tests always green.
5. Atomic commit: one task, its test, its code.

Rules:
- No production code without a test motivating it.
- Test behavior, not implementation: assert what the user gets, not which internal function got called.
- Minimal scope: YAGNI. Implement the task, nothing more.
- One commit per task, tests green at commit. The commit also ticks the task's checkbox in the plan file — the plan is the live progress tracker.

Failure modes — and what to do:
- The new test passes immediately → it doesn't test the new behavior. Rewrite the test, not the code.
- The tests can't run (broken setup, missing runner) → stop and report. Never "skip testing just this once".
- The test is flaky (passes and fails across runs) → fix the flakiness before moving on; a flaky test guards nothing.
- The task is untestable as written → the plan is wrong at that point. Stop and report; don't improvise.

<< IP Mike: test conventions, what to test / not to test, quality bar. >>
