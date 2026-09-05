---
description: One small story, end to end, in three contexts instead of six — research and plan fused, same implementer, same fresh-context review, same gates
argument-hint: <story id or name>
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - AskUserQuestion
  - Agent
  - Bash
---
# ks-flow — The short track for a small story

Target story: $ARGUMENTS

A story of complexity 1 does not need six cold contexts to read the same four documents.
This track runs the same cycle in three: you research and plan in one pass, the
`implementer` builds, the `reviewer` judges in fresh context, and it ships.

**Nothing is relaxed.** The dedicated worktree, the validated plan, the fresh-context review
with its neutralization proof, the browser pass, the `Ship allowed` gate and the test budget
all hold exactly as on the full track. What disappears is repetition, not verification —
if you find yourself dropping a check to go faster, you are on the wrong track: stop and
escalate.

## Execution contract (non-negotiable)
You are FORBIDDEN from:
- Writing or modifying production code yourself. Implementation is delegated to the
  `implementer` subagent, always.
- Judging the implementation yourself. Review is delegated to the `reviewer` subagent in a
  fresh context, always — you are the context that planned it, hence blind to your own gaps.
- Running this track on a story that trips any escalation signal, in Phase 0 or in Phase 2.
- Skipping the plan checkpoint, the review, or the ship gate to save time.

## Phase 0 — Prerequisites and eligibility (fail-closed)

1. `AGENTS.local.md` exists? Missing → STOP: "This project has no settings. Run /ks-setup."
   Read `Story track`, `Flow threshold`, `Plan validation`, `Merge mode`, `Ship confirmation`,
   the project commands and the stages from it.
2. `docs/prd.md`, `docs/stories.md` and `docs/architecture.md` exist? Any missing → STOP and
   point at the phase that produces it. This track drives one story; it never replaces framing.
3. Resolve $ARGUMENTS to the story id (`s<number>-<slug>`) against `docs/stories.md`. No
   unambiguous match → list the available stories and stop.
4. `Story track: full` → STOP: "This project runs every story on the full pipeline. Use
   /ks-orchestrator <id>." `Story track: flow` → continue. `Story track: auto` → continue
   only if the story's complexity is at or below `Flow threshold`; above it, STOP and say:
   "Story <id> is complexity <n>, above `Flow threshold` <t>. Run /ks-orchestrator <id>."

**Escalation signals.** Whatever the score, this track does not carry a story that involves
a schema migration, a genuinely new screen, a change to authorization or tenant scope, a
change to an API contract, or an added dependency. If `docs/stories.md` already shows one,
STOP now and say which: "Story <id> <signal>. That belongs on the full pipeline —
/ks-orchestrator <id>."

## Phase 1 — Workspace (fail-closed)

Bootstrap or verify the story's workspace exactly as AGENTS.md, "Where work happens",
specifies, and perform every read and write there. Report the absolute path, the branch and
the environment files copied (names only, never values). Any conflict it names is a hard stop.

## Phase 2 — Research and plan, one pass

Apply the `testing-doctrine` skill when you write the test strategy.

Read: `docs/stories.md` (the target story), `docs/architecture.md`, AGENTS.md — and
`docs/design-system.md` plus `docs/designs/<id>/design.md` when the story touches UI.
Output structure: @templates/plan-flow.md

The two acts are fused, not skipped. Apply the `codebase-analysis` skill to the story's
scope and establish the facts **before** writing a single task:

1. **Verify the story's PREMISE, not just that the things it names exist.** Open the code
   and check each assertion: exact name, signature, location, AND behaviour on the story's
   own case. A function that exists and throws on that case invalidates the premise — say
   it first, and repair the story rather than patching around it.
2. Locate the files actually involved and their current state; note the existing tests, the
   dependencies between modules, the traps left by previous stories.
3. Write what you could not settle under "Open questions". An honest unknown beats a
   plausible guess.
4. **Run the escalation check again, now that you have read the code.** Reading it is what
   reveals a migration hiding behind a nullable column, a screen that turns out to be new,
   or a guard that has to move. One signal → STOP, say which, and hand over:
   "Escalating <id> to the full pipeline: <signal>. Run /ks-research <id>." The research
   you just did was needed either way; nothing is lost.
5. Break the story into ordered tasks, each small and verifiable, resting on the facts you
   just established. A behaviour, business rule, data contract or interaction names the test
   that can fail; a purely presentational task names its visual check plus lint and typecheck
   instead — never a manufactured component test. `Test budget` from AGENTS.local.md; a plan
   that wants more says why. Where the tests go is settled in the `testing-doctrine` skill.
6. Past roughly six tasks, the story is not small: say so and suggest `/ks-orchestrator <id>`
   rather than growing a short-track plan into a long one.
7. Write `docs/plans/<id>.md`, frontmatter `validated: no` and `track: flow`. **Cap it at
   ~150 lines.**

**CHECKPOINT — per `Plan validation`.** `human`: present the summary (verified facts, tasks,
files touched, test strategy) and ask via AskUserQuestion: "Validate this plan?" — options:
Validate / Modify / Stop. Only Validate writes `validated: yes`; anything else stops.
`autonomous`: re-read the plan against the story's acceptance criteria, set `validated: yes`
yourself, and say plainly that nobody else looked at it. An existing plan file never counts
as validated on its own.

Write no code in this phase.

## Phase 3 — Execute (delegated)

Fail-closed: `docs/plans/<id>.md` must carry `validated: yes`. Then invoke the Agent tool:
- subagent_type: implementer
- description: Implement story <id>
- working directory: the absolute worktree verified in Phase 1.
- prompt: Implement story <id> from docs/plans/<id>.md. Your agent definition is your
  contract — this prompt carries only what is specific to this run. This is a `flow` plan:
  its "Verified facts" section is the research, read it first. The worktree and branch are
  prepared and verified: do not create a worktree, switch branches, checkout, or stash.
- On a FIX run, add: This story was blocked in review. docs/reviews/<id>.md is your fix list.

Wait for it to finish. Capture its summary.

## Phase 4 — Review (delegated, fresh context)

Invoke the Agent tool:
- subagent_type: reviewer
- description: Anti-hallucination review of story <id>
- working directory: the same absolute worktree.
- prompt: Review story <id>. Your agent definition and the preloaded `review-antihallu` skill
  are your contract. Judge `git diff <default-branch>...feature/<id>`, and only that diff.
  This is a `flow` plan: its "Verified facts" section is the research, and a diff
  contradicting one is a finding. Fill the checklist from templates/review-checklist.md and
  end with the exact `Max severity:` and `Ship allowed:` lines.

Write the full report to `docs/reviews/<id>.md`. A missing or malformed verdict is itself a
blocked review: write that failure with `Max severity: critical` and `Ship allowed: no`, and
do not infer a severity.

**Gate.** `Ship allowed: no` → back to Phase 3 in fix mode, per AGENTS.md, "Gate": only a
critical, or a review that could not complete, reopens a loop, and never more than two. Still
blocked after two → stop, report every open finding, and say plainly that a story needing more
than two loops on this track was mis-tracked.

## Phase 5 — Ship

CHECKPOINT — per `Ship confirmation`. `human`: show the verdict and ask via AskUserQuestion:
"Ship now?" — options: Ship / Not now; only an explicit Ship proceeds. `automatic`: proceed.

Then run `/ks-ship`'s flow unchanged: the mechanical gate
(`grep -q '^Ship allowed: yes' docs/reviews/<id>.md`), then its exit gate — the cycle's only
end-to-end and production-build run, per `E2E stage` and `Build stage` — then `Merge mode`,
squash, and cleanup only on a proven merge.

End with: "Story <id> shipped (flow). Cycle complete." when the merge is proven, "PR opened —
merging is yours." when it stops at the PR, or the exact blocking state if stopped: which
phase, what is missing, which command comes next.
