---
description: Break a story into sequenced tasks, ready to execute
argument-hint: <story id or name>
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - AskUserQuestion
  - Bash
---
You are planning a story's implementation. Target story: $ARGUMENTS

Resolve $ARGUMENTS to the story id (`s<number>-<slug>`) against docs/stories.md. If there is no unambiguous match, list the available stories and stop.

Locate the dedicated `.worktrees/<id>` worktree, verify that it is on exactly
`feature/<id>`, and perform every read and write there. Missing worktree, wrong
branch, detached HEAD or the repository base directory itself → STOP and run
`/ks-research <id>` first. Never create or switch branches here.

Read: docs/stories.md (the target story), docs/research/<id>.md (if it exists), docs/design-system.md and docs/designs/<id>/design.md (if they exist), docs/architecture.md, AGENTS.md
Output structure: @templates/plan.md

Apply the `testing-doctrine` skill when you write the test strategy.

If docs/research/<id>.md doesn't exist, point out that /ks-research <id> is recommended before planning — without research, the plan relies on possibly stale docs. Continue only if I confirm.

If the story has UI, the plan follows the screen defined in docs/designs/<id>/design.md: it references the design system's components and never invents new ones. The HTML mockup is a reference, not a source of code.

Proceed as follows:
1. Isolate the target story and its acceptance criteria.
2. Break it into ordered tasks, each one small and verifiable. Lean on the
   research: real files, verified APIs, known traps. A behavior, business rule,
   data contract or interaction must name the test that can fail. A purely
   presentational task may instead name a focused visual/browser check plus
   lint and typecheck; never manufacture a component test merely so every task
   owns one.
**Cap the plan at ~250 lines.** The decisions table stays whole — it is what stops the
implementer re-deciding — but the prose around it need not argue twice.

**Test budget: `Test budget` from AGENTS.local.md (25 by default).** A plan that wants more says why, in its test strategy.
The permission matrix is written ONCE, in the policy test; a service test covers the
business rule, not the access rule again. No enum exhaustiveness, never the same rule at
two layers, and no adapter re-asserting a 403. Full rationale in the `testing-doctrine` skill —
volume has repeatedly grown by dozens of tests per story while the central
invariant shipped with no net at all.

3. Anticipate the touched files and the test strategy. Test each invariant at
   the closest valuable layer and avoid proving the same behavior again in
   every caller. Explicitly separate automated behavior tests from visual
   verification. If the story is scored complexity 5, or the plan grows past
   roughly ten tasks, the story is too big: say so and suggest a split instead
   of a bloated plan.
4. If planning forces a structural choice (library, pattern, data model) with rejected alternatives, record it as an ADR in `docs/decisions/` (@templates/adr.md) — it will travel with the story branch.
5. Write the plan to `docs/plans/<id>.md`, frontmatter `validated: no`.
6. Validation, per `Plan validation` in AGENTS.local.md (missing file or setting → STOP: "No project settings. Run /ks-setup."):
   - `human` — checkpoint (AskUserQuestion): "Validate this plan?" — options: Validate / I'll review it first. On Validate, set `validated: yes` in the plan's frontmatter.
   - `autonomous` — no checkpoint: re-read the plan against the story's acceptance criteria, then set `validated: yes` yourself. State plainly that nobody else looked at it.
   /ks-execute refuses an unvalidated plan either way.

If the plan file already exists when the command runs, skip straight to the validation checkpoint: show the summary and ask.

Write no code. This command produces a plan, not code.

End with: "Plan validated. Next: /ks-execute <id>" — or "Plan awaiting validation. Rerun /ks-plan <id> to validate." if it wasn't validated.
