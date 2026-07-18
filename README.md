# killer-saas

A complete agentic pipeline to kill a SaaS: pick a target, cut the 20% that matters, rebuild it on your boilerplate, ship it to production.
One method = a suite of commands. One principle = no direct coding.

## Pipeline
PRD → User Stories → Architecture + Design System → then, per story: Research → Design → Plan → Execute → Review → Ship

Full method documentation: [DOC.md](DOC.md)

## Install

You don't clone this repo into your project: the installer drops its files into whatever directory you run it from.

Quickest — one-liner, from your project's root (the script fetches the repo itself):

    cd your-project
    curl -fsSL https://raw.githubusercontent.com/MikeCodeur/killer-saas/main/install.sh | bash

Prefer to read before you run? Clone the repo somewhere, then run the script from your project's root:

    git clone https://github.com/MikeCodeur/killer-saas.git ~/tools/killer-saas
    cd your-project
    ~/tools/killer-saas/install.sh

Global (ks-* commands available in all your repos):

    ~/tools/killer-saas/install.sh --global
    # then, in each project:
    ~/.claude/killer-saas/install.sh init

## Update

From your project's root:

    ~/tools/killer-saas/install.sh update
    # or, without a clone:
    curl -fsSL https://raw.githubusercontent.com/MikeCodeur/killer-saas/main/install.sh | bash -s -- update

What it does — and doesn't:
- Cleanly replaces the method's commands, skills and agents (tracked in `.claude/.ks-manifest` — your own commands/skills are never touched, renamed or removed files leave no ghosts).
- Refreshes the templates you haven't modified; a locally modified template is never overwritten (you get a warning instead).
- Stamps the installed version in `.claude/.ks-version`.
- Never touches `AGENTS.md`: if the method's rules evolved, merge by hand.

## Usage

    /ks-prd <target-saas>
    /ks-stories
    /ks-architect
    /ks-design-system
    # then, per story:
    /ks-research <story>
    /ks-design <story>
    /ks-plan <story>
    /ks-execute <story>
    /ks-review <story>
    /ks-ship <story>

    # or run a story's full cycle (with human checkpoints):
    /ks-orchestrator <story>

    # where does the project stand?
    /ks-status

    # lost? pipeline map (français) :
    /ks-help
