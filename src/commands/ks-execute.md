---
description: Get a story implemented in an isolated subagent. Never codes in the main context.
argument-hint: <story id or name>
allowed-tools:
  - Read
  - Glob
  - Agent
  - Bash
---
# ks-execute — Delegated implementation

Target story: $ARGUMENTS

## Execution contract (non-negotiable)
You MUST complete this command by delegating to the `implementer` subagent. You are FORBIDDEN from:
- Writing or modifying code yourself — you don't have the Write/Edit/Bash tools, on purpose.
- Starting the implementation without a validated plan in docs/plans/<id>.md.
- Running a story from the repository base directory, whatever its complexity.
- Creating or checking out the story branch in the repository base directory.
- Summarizing work the agent didn't actually do.

If you can't invoke the Agent tool, stop and report the error. Don't improvise.

## Workflow

### Step 1 — Prerequisites (fail-closed)
1. Resolve $ARGUMENTS to the story id (`s<number>-<slug>`) against docs/stories.md. No unambiguous match → list the available stories, STOP.
2. Resolve `<repository-base>/.worktrees/<id>` and verify its branch is exactly `feature/<id>`. Missing worktree, wrong branch, detached HEAD or the repository base directory itself → STOP and run `/ks-research <id>` to bootstrap the feature workspace. Never improvise another branch or path.
3. From that worktree, read docs/plans/<id>.md. If it doesn't exist, STOP: ask for /ks-plan <id> first. Go no further.
4. Check the plan's frontmatter: it must contain `validated: yes`. Otherwise STOP: "Plan not validated. Review it, then rerun /ks-plan <id> to validate."
5. Read docs/reviews/<id>.md from the worktree if it exists. If it contains `Ship allowed: no`, this is a FIX run: the review findings come first.
6. Read AGENTS.local.md: the project commands (`Test`, `Typecheck`, `E2E`, `Build`), `Test budget`, and the stages (`Full suite`, `E2E stage`, `Build stage`). Missing file → STOP: "No project settings. Run /ks-setup." A command left at `—` is one the implementer must not invent: pass it along as unavailable.

### Step 2 — Delegate
Invoke the Agent tool:
- subagent_type: implementer
- description: Implement story <id>
- working directory: the absolute dedicated worktree path verified in Step 1.
- prompt: Implement story <id> from docs/plans/<id>.md. Your agent definition is your contract — this prompt carries only what is specific to this run. The worktree and branch are prepared and verified: do not create a worktree, switch branches, checkout, or stash. The project commands, `Test budget` and the stages live in AGENTS.local.md — quote them verbatim, and one left at `—` does not exist in this project.
- On a FIX run, add: This story was blocked in review. docs/reviews/<id>.md is your fix list; your definition says how to work it.
Wait for the agent to finish. Capture its summary.

### Step 3 — Report
Summarize: tasks done, files touched, tests added, what the verification record says (commands, exit codes, tree), and any blocker the agent reported. No line-by-line detail.

End with: "Implementation done. Next step: /ks-review <id>"
