# killer-saas

A complete agentic pipeline to build and ship a SaaS, from need to production.
One method = a suite of commands. One principle = no direct coding.

## Pipeline
PRD → User Stories → Architecture → then, per story: Research → Plan → Execute → Review → Ship

Full method documentation: [DOC.md](DOC.md)

## Install

In a project:

    ./install.sh

Global (commands in all your repos):

    ./install.sh --global
    # then, per project:
    ~/.claude/killer-saas/install.sh init

One-liner (read the script before running it):

    curl -fsSL https://raw.githubusercontent.com/MikeCodeur/killer-saas/main/install.sh | bash

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
