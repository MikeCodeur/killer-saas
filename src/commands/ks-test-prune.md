---
description: Audit an existing end-to-end suite against the testing doctrine, then prune it — keep, rewrite or delete each spec, after a human validates the list
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Edit
  - Write
  - AskUserQuestion
---
# ks-test-prune — Prune the end-to-end suite

The doctrine stops new specs from bloating the suite. This command treats the specs already
there: a project that ran before the rules has a suite that is slow, coupled to its copy, and
replayed by every story. Run it on demand, outside any story's cycle.

It changes tests, not the product. **The one product change allowed is adding a
`data-testid` attribute** a rewritten spec selects on. Anything else the audit uncovers — a
real bug, a missing test — goes to the issue tracker.

## Phase 1 — Prerequisites (fail-closed)

1. `AGENTS.local.md` exists, `E2E` is not `—`? Otherwise STOP and say which.
2. Find the suite: the test directory of the end-to-end runner's own config. Never guess it.
3. Id: `test-prune-<YYYYMMDD>`. Create or verify `.worktrees/<id>` on `feature/<id>` exactly as
   AGENTS.md, "Where work happens", specifies for a story — sandbox included. Report the
   absolute path, the branch and the environment files copied (names only). Every read and
   write below happens there.

## Phase 2 — Audit (read-only)

Load the `testing-doctrine` skill: its end-to-end rules are the grid. For every spec file,
read it whole and record:

- tests, lines, and the scenarios a loop multiplies them into;
- what each test **asserts as an effect** — URL reached, row persisted and read back, HTTP
  status, server-side refusal — versus what it only finds visible;
- selectors on copy that can change (text, accessible name of a translated label);
- the unit or integration test that already covers the same rule, found by grepping the
  suite for the rule — cite it, never assume it.

Then one verdict per spec:

| Verdict | When |
| --- | --- |
| **keep** | it asserts an effect no lower layer can see, with stable selectors |
| **rewrite** | the effect is real, but the spec is a matrix to cut to one case, or selects on copy |
| **delete** | it only asserts visibility, or replays a rule a lower layer already owns (cite it) |

A spec that is the **only** net on a guard, an authorization or a persisted side effect is
never deleted — rewritten at worst. Doubt → keep, and say why.

Write `docs/plans/<id>.md`: a table spec | tests | verdict | reason (with the covering test
for a delete) | what a rewrite keeps; then the totals before → after (specs, tests, lines).
Frontmatter `validated: no`.

## Phase 3 — CHECKPOINT (always human)

Present the totals and the deletes, then ask via AskUserQuestion: "Apply this pruning?" —
Validate / Modify / Stop. Modify → apply the human's changes to the plan and ask again. Only
Validate writes `validated: yes` into the frontmatter; Stop ends the command, the plan stays
as a record. Deleting a test is the one decision here nobody may take for the human.

## Phase 4 — Apply

Delete and rewrite exactly as the validated plan says, nothing more. A rewrite keeps the
effect assertion, cuts the matrix to its one representative case, and moves copy selectors to
a role or a `data-testid`.

Then **one run** of `<E2E>` over the whole remaining suite, against the sandbox. Red on a
spec this command touched → fix the rewrite and run once more; red on an untouched spec →
not this command's problem: an issue, and say so. Record the run in `docs/verif/<id>.md`
(@templates/verification-record.md), with its duration.

One commit: `test(e2e): prune the suite — <before> → <after> tests`.

## Phase 5 — Land it

There is no review gate: the human validated each deletion at the checkpoint, and no
product behavior changed. Follow `Merge mode` and `Ship confirmation` as /ks-ship does —
squash, PR or local merge, then its cleanup on a proven merge only.

End with the totals before → after, the run's duration, and the issues opened.
