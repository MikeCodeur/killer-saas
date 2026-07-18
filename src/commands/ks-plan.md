---
description: Break a story into sequenced tasks, ready to execute
argument-hint: <story id or name>
---
You are planning a story's implementation. Target story: $ARGUMENTS

Resolve $ARGUMENTS to the story id (`s<number>-<slug>`) against docs/stories.md. If there is no unambiguous match, list the available stories and stop.

Read: docs/stories.md (the target story), docs/research/<id>.md (if it exists), docs/architecture.md, AGENTS.md
Output structure: @templates/plan.md

If docs/research/<id>.md doesn't exist, point out that /ks-research <id> is recommended before planning — without research, the plan relies on possibly stale docs. Continue only if I confirm.

Proceed as follows:
1. Isolate the target story and its acceptance criteria.
2. Break it into ordered tasks, each one small and verifiable. Lean on the research: real files, verified APIs, known traps. A task that can't fail a test isn't a task — merge it into one that can.
3. Anticipate the touched files and the test strategy. If the plan grows past roughly ten tasks, the story is too big: say so and suggest a split instead of a bloated plan.
4. Write the plan to `docs/plans/<id>.md`.

Write no code. This command produces a plan, not code.

End with: "Plan ready. Validate it, then: /ks-execute <id>"
