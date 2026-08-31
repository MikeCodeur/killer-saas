---
description: Create the project's AGENTS.local.md — the settings and commands the pipeline reads. Runs once, before /ks-prd.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Bash
  - AskUserQuestion
---
# ks-setup — The project's settings, once

This command writes `AGENTS.local.md`: the file that belongs to the project and that
`install.sh` never overwrites. Every pipeline command reads its settings there.

## Execution contract (non-negotiable)
You are FORBIDDEN from:
- Writing anything into `AGENTS.md`. It belongs to the method and is rebuilt on every install.
- Asking more than the four questions below. Everything else has a default the user can change later.
- Inventing a project command you have not seen in the repository.

This command is the **only** creator of `AGENTS.local.md` — `install.sh` never writes it, so
finding it absent is the normal case, not an error.

If `AGENTS.local.md` already exists → do NOT overwrite it. Show its current settings and stop:
"Settings already in AGENTS.local.md. Edit that file directly, or delete it and rerun /ks-setup."

## Workflow

### Step 1 — Read what the repository already answers
Never ask what the code states. Look for the package manager (which lockfile is present),
and the scripts the project actually declares (its package manifest, task runner or Makefile).
Note the default branch (`git symbolic-ref refs/remotes/origin/HEAD`, else the current branch).
Anything you find becomes the pre-filled answer, not a question.

### Step 2 — Ask the four questions (AskUserQuestion)
Only these four. Each one changes what the pipeline does; the rest is pre-filled.

1. **Where a story lands** — `Merge mode`: `pr` (a pull request against the target branch) or
   `local` (squash-merged locally, no review platform). Confirm `Target branch` with it.
2. **Who validates a plan** — `Plan validation`: `human` (a checkpoint blocks until the user
   validates) or `autonomous` (the agent validates its own plan and executes).
3. **Who draws the screens** — `Design source`: `internal` (the agent produces the mockup, with
   the skill named in `Design skill`) or `external` (the agent writes a brief and an external
   tool named in `Design tool` produces it).
4. **The project's commands** — test, typecheck, e2e, build, pre-filled from Step 1. A command
   the project does not have stays `—`; never invent one.

`Ship confirmation` follows `Plan validation` unless the user says otherwise: a project that
validates plans by hand confirms its ships by hand.

### Step 3 — Write it
Write `AGENTS.local.md` from @templates/agents-local.md, filled with the answers and the
defaults. Keep its shape exactly: one setting per line, `Name: value`, **no trailing comment** —
the commands read the value as everything after the colon, so a comment on the line becomes part
of the value. The accepted values stay in the table below the block. Leave "Project conventions"
as its placeholder — `/ks-architect` fills it from the boilerplate.

Commit it on the default branch (`chore: project settings`). It is a project file, not a story file.

### Step 4 — Rebuild AGENTS.md
Run `./install.sh --target <the targets this project uses>` so the rules and the settings are
assembled into `AGENTS.md`. If `install.sh` is not in the project, say so: the settings are
written, the assembled file is one install away.

End with: "Settings written to AGENTS.local.md. Next step: /ks-prd <target SaaS>"
