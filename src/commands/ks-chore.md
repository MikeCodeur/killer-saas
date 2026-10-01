---
description: Work that is not a product feature — documentation, content, test cleanup, tooling — with a short validated plan, the implementer, and a verification sized to what changes
argument-hint: <what to do>
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
  - Agent
  - AskUserQuestion
---
# ks-chore — Work that is not a feature

Request: $ARGUMENTS

Between a Quick Fix (a local tweak, coded directly) and a story (a product capability, full
gates) sits the work that changes no product behavior but is too large to tweak: guides,
content, a test suite to clean, tooling, configuration. Run as stories, it pays for research,
review, full suites and end-to-end runs that verify nothing it touches. Run as a Quick Fix,
it is coded by the main context with no written scope.

**One request = one chore.** Never one chore per section, per page or per module: the split
multiplies plans, worktrees and checks for a single deliverable.

## Phase 1 — Is it a chore? (fail-closed)

1. `AGENTS.local.md` exists? Missing → STOP: "This project has no settings. Run /ks-setup."
2. Read the request against the escalation check of @templates/plan-chore.md: product code
   that changes behavior, a schema migration, authorization, an API contract, a business rule,
   a runtime dependency added or upgraded. Content files are not product code, even when they
   live in the source tree; adding a stable test identifier is not a behavior change. One yes →
   STOP: "This changes product behavior — it is a story. Add it to docs/stories.md, then
   /ks-flow or /ks-orchestrator." A small local tweak the user asked for as such → it is a
   Quick Fix, say so.
3. Id: a short slug of the request (`docs-product-guides`, `e2e-prune`). Create or verify
   `.worktrees/<id>` on `chore/<id>` exactly as AGENTS.md, "Where work happens", specifies —
   with its sandbox only if the verification has to run the product. Report the absolute path,
   the branch and the environment files copied (names only). Every read and write below
   happens there.

## Phase 2 — Mini-plan

Read what the work touches — enough to list the files and set a measurable end, no more.
Write `docs/plans/<id>.md` from @templates/plan-chore.md, frontmatter `validated: no`.

**"Done when" is the part that matters.** A chore that lands thin content or a half-cleaned
suite passes every mechanical check; only a measurable end catches it.

## Phase 3 — CHECKPOINT (always human)

Present goal, done-when, files and verification, then ask via AskUserQuestion: "Run this
chore?" — Validate / Modify / Stop. Modify → apply the changes and ask again. Only Validate
writes `validated: yes`. A chore has no review: this validation is its gate, whatever
`Plan validation` says.

## Phase 4 — Execute (delegated)

Invoke the Agent tool:
- subagent_type: implementer
- description: Run chore <id>
- working directory: the absolute worktree verified in Phase 1.
- prompt: Run chore <id> from docs/plans/<id>.md (`track: chore`). Your agent definition is
  your contract, chore mode. The worktree and branch are prepared and verified: do not create
  a worktree, switch branches, checkout, or stash.

Wait for it. A deviation it reports (a file outside the list, a behavior change) → STOP and
bring it to the human: it may be a story.

## Phase 5 — Land

Check "Done when" against the result — count, read, open — and say what it shows. Not met →
back to Phase 4 once with the gap; still not met → report it and let the human decide.

Then land per `Merge mode` and `Ship confirmation`, as /ks-ship does from its Step 3 —
squash, PR or local merge, then its cleanup on a proven merge only, with `chore/<id>` in place
of `feature/<id>`. No review gate, no end-to-end or build stage unless the plan's
verification named them.

**The human redirects mid-way** ("stop, merge what is done") → update the plan's "Done when"
to the scope actually delivered, say what is left out, and land that. Never copy unfinished
files to the target branch by hand.

End with: what was delivered against "Done when", the verification and its result, the PR or
merge, and anything left out.
