---
name: testing-doctrine
description: What to test, where, how much, and when to run it. Preloaded in the implementer and the reviewer; the rest of the pipeline does not need it.
---
# Testing doctrine

The rules here decide what gets written and what gets run. They live in a skill rather than
in AGENTS.md because only two agents act on them — the one that writes the tests and the one
that judges them — and every other context was paying to load them.

**Budget: `Test budget` from `AGENTS.local.md` (25 by default), and a story that needs more says why in its plan.**

Measured in production use: the suite grows by dozens of tests per story, and **most of
those stories still ship their central invariant with no net at all** — every one found by
mutation during review, none by the volume. The number does not measure the net. It buys false confidence, and it is
slow: a suite that takes half an hour to run is a suite nobody runs.

**Where the tests go**

| Layer | What to test |
| --- | --- |
| Business/service layer and its authorization | Everything that matters. The **role or permission matrix belongs to the policy test, written once** — a service command invents no access rule, it calls the policy. The service test then covers the **business rule**: one nominal case, one refusal per rule it owns. |
| Persistence | Only what no reading catches: the idempotency ordering of a retryable mutation, and the tenant/ownership clause of each query. Call the repository **directly** — the service refuses upstream, so an applicative call never reaches the guard. |
| Adapter (HTTP route, server action, controller) | Only what the service does not do: payload parsing, field clearing, status mapping. **An adapter never re-tests a 403** — it verifies once that a refusal becomes a 403, never per role and never per rule. |
| Component / view | Almost none. Only genuine conditional logic of its own; rendering a list is not a rule. |
| End-to-end | One scenario, for what unit tests structurally cannot see — typically a side effect written inside a transaction, which mocked repositories hide. |

**Four cuts, each measured in real use**

1. **The matrix once, in the policy test.** Replayed per command, it takes a single service test file past fifty tests.
2. **No enum exhaustiveness.** Testing every ordered pair of a transition table proves nothing the legal transitions plus one representative refusal do not already say.
3. **Never the same rule at two layers.** Pick the layer where the rule lives.
4. **No adapter re-asserting a 403.**

**No red-first ceremony, and no invariant mutations in implementation.** Do not write a
failing test to watch it fail, and do not neutralize a guard to confirm a test goes red.
Write the code as whole blocks, write the tests that belong to it, run them. Measured:
repeated mutations across a story and its fix pass, each costing a full suite run plus a
restore plus another run, and **zero findings** — the author who just wrote the test
already knows it passes. It verifies the tests, not the code.

**The same technique stays in review, and there it earns its place.** Run in fresh context
on someone else's net, it found a critical, six majors, and — repeatedly — an invariant with
no test at all. The safety moves downstream to where it works; it is not dropped.

**The failure mode this pipeline keeps producing: a test that names an invariant without
exercising it.** Most stories ship one. Six shapes seen repeatedly, worth citing
verbatim in a prompt because they are hard to spot by reading:

1. a hand-written query in the test instead of a call to the code under test — it tests the database, not the repository;
2. a payload the real interface never produces;
3. a `catch` that swallows the failure, so the assertion passes when nothing throws;
4. an end-to-end test that stays green while rendering zero rows;
5. a **fixture** whose identifier lets a downstream guard answer for the guard under test — invisible when reading assertions;
6. a **mock double that replays** the clause instead of evaluating it.

**The criterion that replaces the count: a test that stays green when the rule it names is
deleted is worse than no test** — it hides the hole it claims to cover.

**When to run what — each thing once, and once only**

A deterministic command re-run on the same code returns the same answer. Running the suite
in Execute, again in Review, again per mutation and again at Ship buys nothing and costs
four times the wall clock. Each check therefore has exactly one stage, and the stage is a
setting in `AGENTS.local.md`.

| Run | When | Setting |
| --- | --- | --- |
| Focused suite | after each task — the working loop. Target the task's own test files, never the whole project | — |
| Full suite | **once**, after the last task | `Full suite` |
| Type check | **once at the very end, after the last edit, and not optional** — most runners transpile without checking types and most linters do not type, so a type error in a test file passes lint, passes the suite, and fails CI | — |
| End-to-end | **once, at ship, just before the merge** — never in the loop, never twice: a run costs a cold server start, a migration, a seed and a browser driver | `E2E stage` · `E2E scope` · `E2E browsers` |
| Production build | at ship, and **only when a route or a manifest moved** — that is the one rupture a type check cannot see. A modern build type-checks on its way, so it is the build or the type check, never both | `Build stage` |
| Format | never as a repo-wide sweep — format the staged files at commit; a story is one commit | — |

**The reviewer's mutations run on the invariant's own test files, not on the suite.** A
neutralized guard turns red in the one or two files that name it; replaying the whole
project to learn that is the single most expensive habit this pipeline ever had.
