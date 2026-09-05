# killer-saas

A complete agentic pipeline to kill a SaaS: pick a target, cut the 20% that matters, rebuild it on your boilerplate, ship it to production.
One method = a suite of commands. One principle = no direct coding.

Small presentation or copy adjustments can use the explicit **Quick Fix**
exception when the user requests it. The primary agent edits directly, keeps the
scope narrow, and verifies the result. If the impact is architectural, business,
cross-cutting, or uncertain, the normal pipeline remains mandatory. See
[DOC.md](DOC.md#quick-fix-mode) for the complete boundary.

## Pipeline
Setup → PRD → User Stories → Stories Review → Architecture + Design System → then, per story: Research → Design → Plan → Execute → Review → Ship

A small story takes the short track instead: **`/ks-flow`** runs that same cycle in three contexts rather than six — research and plan fused in one pass, then the same implementer, the same fresh-context reviewer, the same gates.

![killer-saas pipeline overview](docs/images/pipeline-overview-dark.png)

Full method documentation: [DOC.md](DOC.md)

### Framing — once per product
![Framing phase](docs/images/framing-dark.png)

### Per story — the cycle
![Per-story cycle](docs/images/story-cycle-dark.png)

## Install

You don't clone this repo into your project: the installer drops its files into whatever directory you run it from.

Quickest — choose your tool and run the matching one-liner from your project's
root (the script fetches the repo itself).

**Claude Code:**

    cd your-project
    curl -fsSL https://raw.githubusercontent.com/MikeCodeur/killer-saas/main/install.sh | bash

**Codex:**

    cd your-project
    curl -fsSL https://raw.githubusercontent.com/MikeCodeur/killer-saas/main/install.sh | bash -s -- --target codex

To install the Codex skills globally instead:

    curl -fsSL https://raw.githubusercontent.com/MikeCodeur/killer-saas/main/install.sh | bash -s -- --global --target codex

The Codex target requires Node.js and installs the skills in `.codex/skills`
for a project install or `~/.codex/skills` for a global install.

Prefer to read before you run? Clone the repo somewhere, then run the script from your project's root:

    git clone https://github.com/MikeCodeur/killer-saas.git ~/tools/killer-saas
    cd your-project
    ~/tools/killer-saas/install.sh

### Targets and scopes

One source of truth, one installer, per-tool output. Pick a **target** with `--target`, in **project** (default) or **global** (`--global`) scope:

    ./install.sh                           # Claude Code, project (default)
    ./install.sh --target codex            # Codex, project → .codex/skills + AGENTS.md
    ./install.sh --target all              # Claude + Codex, project
    ./install.sh --global                  # Claude, global (commands in every repo)
    ./install.sh --global --target codex   # Codex, global → ~/.codex/skills
    ./install.sh --global --target all     # both, global

After a global install, drop the per-project files (templates + rules) in each project:

    ~/.claude/killer-saas/install.sh init                 # Claude
    ~/.claude/killer-saas/install.sh init --target codex  # Codex

`AGENTS.md` (the rules) is shared and read natively by both tools; on Claude a one-line `CLAUDE.md` imports it. The 6 skills are the open `SKILL.md` standard, so they carry over unchanged; the 16 `ks-*` commands are emitted as Codex skills. See the fidelity matrix in [DOC.md](DOC.md).

When maintaining killer-saas itself, edit only `src/AGENTS.md`. The root
`AGENTS.md` and `CLAUDE.md` are ignored local-install artifacts; `CLAUDE.md`
must remain a one-line `@AGENTS.md` import. See
[Editing the workflow rules](DOC.md#editing-the-workflow-rules).

### Repo-level enforcement (git hooks)

The method's guardrails don't have to depend on a specific tool's permissions. Opt in with `--hooks` to enforce them in **git**, identically for every tool:

    ./install.sh --hooks        # (add to any target)

- **pre-commit** — refuses code on a `feature/<id>` branch without a validated plan (`docs/plans/<id>.md` → `validated: yes`). Docs-only commits always pass.

The ship gate stays server-side: `/ks-ship` squash-merges, so a merged story leaves no merge commit a client-side hook could detect. Run `ks-gate ship-allowed <id>` in CI or branch protection instead.

Reversible: `git config --unset core.hooksPath`. On Claude the harness also enforces "no direct coding" via tool permissions; the hooks make the same guarantees hold on Codex (and, later, Gemini) — enforcement lives in the repo, not the tool.

## Update

From your project's root:

    ~/tools/killer-saas/install.sh update              # Claude
    ~/tools/killer-saas/install.sh update --target codex   # Codex
    # or, without a clone:
    curl -fsSL https://raw.githubusercontent.com/MikeCodeur/killer-saas/main/install.sh | bash -s -- update
    # overwrite locally modified templates too:
    curl -fsSL https://raw.githubusercontent.com/MikeCodeur/killer-saas/main/install.sh | bash -s -- update --force

What it does — and doesn't:
- Cleanly replaces the method's tooling, tracked per target in `.ks-manifest` (`.claude/` or `.codex/` — your own commands/skills are never touched, renamed or removed files leave no ghosts).
- Refreshes the templates you haven't modified; a locally modified template is never overwritten (you get a warning instead — add `--force` to overwrite).
- Stamps the installed version in `.ks-version`.
- Rebuilds `AGENTS.md` from the method's rules plus your `AGENTS.local.md`, which it never touches. Your settings and conventions survive; the method's rules come through updated.

## Usage

    /ks-setup                  # once: the project's settings and commands
    /ks-prd <target-saas>
    /ks-stories
    /ks-stories-review
    /ks-architect
    /ks-design-system
    # then, per story:
    /ks-research <story>
    /ks-design <story>
    /ks-plan <story>
    /ks-execute <story>
    /ks-review <story>
    /ks-ship <story>

    # a small story — the same cycle, short track:
    /ks-flow <story>

    # a story's full cycle, with the two human checkpoints:
    /ks-orchestrator <story>

    # where does the project stand?
    /ks-status

    # the pipeline map
    /ks-help

## Autonomous mode — `/goal`

`/goal` is a native Claude Code command (not a killer-saas one): you state an outcome, it figures out how to reach it — planning the work, spawning parallel agents, and finding the best sequence itself. Point it at the killer-saas commands and it drives the whole backlog for you.

    /goal All user stories planned, reviewed and executed.
    Start a dynamic workflow with multiple parallel agents to implement
    the user stories (find the best sequence).

It reads `docs/stories.md`, respects the dependency order, and fans out `/ks-research → … → /ks-review` across independent stories in parallel — while the method's gates still hold: no execution without a validated plan, no ship past an open critical. Use it to go wide once the framing (PRD, stories, architecture, design system) is done; use the individual `/ks-*` commands when you want to drive one story by hand.
