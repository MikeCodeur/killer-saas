---
description: Get a story reviewed by a fresh-context subagent. Gate before Ship. Never reviews in the context that wrote the code.
argument-hint: <story id or name>
allowed-tools:
  - Read
  - Grep
  - Agent
  - Write
  - Bash
---
# ks-review — Delegated review + gate

Target story: $ARGUMENTS

## Execution contract (non-negotiable)
You MUST complete this command by delegating to the `reviewer` subagent (fresh context). You are FORBIDDEN from:
- Judging the code yourself: you are probably the context that produced it, hence blind to your own hallucinations.
- Modifying source code. Your only write right is the report docs/reviews/<id>.md, nothing else.
- Unblocking the Ship if a critical issue is reported.

If you can't invoke the Agent tool, stop and report the error. Don't improvise.

## Workflow

### Step 1 — Delegate
Resolve $ARGUMENTS to the story id (`s<number>-<slug>`) against docs/stories.md. Read AGENTS.local.md for the project commands and `Test budget` — missing file → STOP: "No project settings. Run /ks-setup."
Locate `.worktrees/<id>`, verify its branch is exactly `feature/<id>`, and use
that absolute worktree as the reviewer working directory and report location.
Missing worktree, wrong branch, detached HEAD or repository base → STOP; never
switch branches. Then invoke the Agent tool:
- subagent_type: reviewer
- description: Anti-hallucination review of story <id>
- working directory: the absolute dedicated worktree path verified above.
- prompt: Review story <id>. The story diff is `git diff <default-branch>...feature/<id>` — judge that diff, and only that diff, against docs/plans/<id>.md, docs/research/<id>.md when it exists, AGENTS.md and the accepted ADRs in docs/decisions/. When docs/design-system.md and docs/designs/<id>/design.md exist, also check conformity to the design system and to the screen's INTENT — not to the mockup HTML line by line; any component, token or color outside the system is drift to classify (major by default, critical if it breaks the product's visual coherence). Run yourself what can hide a defect — the suite, the type check, the production build, and your mutations, using the project's own commands quoted verbatim from AGENTS.local.md (test <Test>, typecheck <Typecheck>, e2e <E2E>, build <Build>); a command given as `—` does not exist here, report it as not run rather than substituting one. Take the linter and any dead-code scan as reported. Judge the test VOLUME too: <Test budget> per story, more only if the plan justified it. And look for a test that names an invariant without exercising it, checking fixtures and mock doubles rather than assertions alone. If Playwright remains unstable after one stabilization attempt and a browser MCP is available, verify the same local test flow there and record the result; local documented test accounts are pre-authorized, never real accounts or secrets. The review-antihallu skill is preloaded. Fill the checklist from templates/review-checklist.md, classify each issue (critical / major / minor), and end your report with the exact lines "Max severity: <critical|major|minor|none>" and "Ship allowed: <yes|no>". Report every finding in the same review; never omit an open finding for a later pass. If any prerequisite, command, tool, or evidence prevents completion, do not stop silently: return a blocked report with `Review status: blocked`, the concrete failure cause, exactly what was missing or unavailable, what the project agent must change or provide, and the next command/action. Use `Max severity: critical` and `Ship allowed: no` for an incomplete review unless the failure is clearly external and the report explicitly says why it cannot be classified; never claim a pass from missing evidence.

Wait for the verdict. If the Agent call fails, times out, returns no report, or returns a report without both exact verdict lines, write `docs/reviews/<id>.md` yourself with `Review status: blocked`, the concrete failure cause, missing information/evidence, and the exact adaptation required. End it with `Max severity: critical` and `Ship allowed: no` when review completeness is compromised. Do not replace the failure with a vague "review failed" message.

### Step 2 — Report
Write the full report to docs/reviews/<id>.md. It MUST include a `Review status: complete|blocked` line, and, when blocked, the sections `Failure cause`, `Missing`, and `Required adaptation` with concrete details. It MUST end with the exact lines `Max severity: ...` and `Ship allowed: yes` or `Ship allowed: no` — /ks-ship greps that line, and without it the ship stays blocked. A single critical = no. An incomplete review is never a pass.

### Step 3 — Gate (fail-closed)
- Verdict with a CRITICAL → Ship blocked. End with: "Ship blocked (critical). Fix via /ks-execute <id> (fix mode), then rerun /ks-review <id>."
- Otherwise → End with: "Review passed. Next step: /ks-ship <id>"
