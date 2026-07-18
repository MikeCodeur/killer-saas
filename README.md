# killer-saas

A complete agentic pipeline to build and ship a SaaS, from need to production.
One method = a suite of commands. One principle = no direct coding.

## Pipeline
PRD → User Stories → Architecture → then, per story: Research → Plan → Execute → Review → Ship

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

## Usage

    /ks-prd <idea>
    /ks-stories
    /ks-architect
    # then, per story:
    /ks-research <story>
    /ks-plan <story>
    /ks-execute <story>
    /ks-review <story>
    /ks-ship <story>

    # or run a story's full cycle (with human checkpoints):
    /ks-orchestrator <story>

    # lost? pipeline map (français) :
    /ks-help
