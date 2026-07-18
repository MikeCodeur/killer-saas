---
description: Explore a story's real context before planning — current code, APIs, traps
argument-hint: <story id or name>
---
You are exploring a story's context before it gets planned. Target story: $ARGUMENTS

Resolve $ARGUMENTS to the story id (`s<number>-<slug>`) against docs/stories.md. If there is no unambiguous match, list the available stories and stop.

Read: docs/stories.md (the target story), docs/architecture.md, AGENTS.md
Output structure: @templates/research.md

Apply the codebase-analysis skill to the story's scope: the CURRENT state of the code, not what the docs claim — the code may have drifted since previous stories.

Proceed as follows:
1. Isolate the target story and its acceptance criteria.
2. Locate the files actually involved in the story and their current state.
3. Verify that the APIs, functions and patterns the plan will rely on actually exist: exact name, signature, location. Open the files — never assert from memory.
4. Spot the traps: existing tests, dependencies between modules, code touched by previous stories.
5. Note what you could NOT settle in the "Open questions" section — an honest unknown beats a plausible guess.
6. Write the result to `docs/research/<id>.md`.

Write no code. Plan nothing: this command produces verified context, not a plan.

End with: "Research ready in docs/research/<id>.md. Next step: /ks-design <id> (UI story) or /ks-plan <id>"
