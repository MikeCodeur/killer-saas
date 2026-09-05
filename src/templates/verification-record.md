# Verification — Story <id>

> Written by the implementer as its **last action before the story commit**, and committed
> with it. The reviewer checks `Tree:` against the commit; when they match, it takes these
> results as proven instead of re-running them. Every command is the project's own, quoted
> verbatim from `AGENTS.local.md` — never a substitute, never a paraphrase.

How `Tree:` is produced, in this exact order: stage everything (`git add -A`), run
`git write-tree`, copy its output here. The tree is therefore the code that was actually
tested. This file and the plan's ticked checkboxes are written afterwards; they live under
`docs/`, which the check excludes.

Tree: <40-hex output of `git write-tree`>

| Run | Command | Result | When |
| --- | --- | --- | --- |
| Test (full suite) | `<Test>` | exit 0 · <N> passed · <M> skipped | <ISO-8601 UTC> |
| Typecheck | `<Typecheck>` | exit 0 | <ISO-8601 UTC> |
| E2E | — | not run — runs at ship (`E2E` setting) | — |
| Build | — | not run — runs at ship (`Build` setting) | — |

A command whose setting is `—` in `AGENTS.local.md` does not exist in this project: write
`—` and say so. Never record a command you did not run, and never record a substitute for
one that is unavailable.

## Not proven here
<What this record does NOT cover, and who covers it. Typically: the end-to-end suite and
 the production build, which run once at ship; the linter and formatter, which run on the
 staged files at commit. An empty section is a claim that everything was checked.>

Verification status: complete
