# killer-saas — Repo rules

## Absolute rule
No direct coding. Every feature goes through the killer-saas pipeline, in order:

PRD → User Stories → Architecture → then, per story: Research → Plan → Execute → Review → Ship

No code is written before the story has a validated plan (`/ks-plan`). No feature ships before a passed review (`/ks-review`).

## Pipeline (commands)
- `/ks-prd`        frames the product (WHAT + WHY)
- `/ks-stories`    breaks it down into shippable user stories
- `/ks-architect`  sets the technical HOW + the conventions
- `/ks-research`   explores the story's real context (current code, APIs, traps)
- `/ks-plan`       breaks a story into sequenced tasks
- `/ks-execute`    implements the story in TDD (implementer subagent)
- `/ks-review`     anti-hallucination review + gate (reviewer subagent)
- `/ks-ship`       PR, merge, deploy

Utilities:
- `/ks-orchestrator`  runs a story's full cycle with human checkpoints (plan validation, ship confirmation)
- `/ks-help`          prints the pipeline map (French, user-facing cheat sheet)

One feature = one Research → Plan → Execute → Review → Ship cycle = one branch = one PR.

## Story ids and branches
- Every story has an id: `s<number>-<short-slug>` (e.g. `s01-submit-testimonial`). It is assigned in docs/stories.md and reused verbatim everywhere: `docs/research/<id>.md`, `docs/plans/<id>.md`, `docs/reviews/<id>.md`, branch `feature/<id>`.
- All work on a story happens on `feature/<id>`, branched from the default branch. Never commit story work to the default branch.
- The story diff = `git diff <default-branch>...feature/<id>`. That is what the review judges.
- A command that receives a fuzzy story name resolves it against docs/stories.md; if there is no unambiguous match, it lists the available stories and stops.

## Gate (mechanical)
- The review report `docs/reviews/<id>.md` must end with the exact lines `Max severity: <critical|major|minor|none>` and `Ship allowed: <yes|no>`. A single critical = no.
- `/ks-ship` refuses to run unless that file exists and contains the line `Ship allowed: yes`. No file, no line, or `no` → ship blocked. No exceptions.
- After a blocked review, `/ks-execute` runs in fix mode: the review findings are fed to the implementer and fixed before anything else.

## Technical conventions
<< IP Mike: boilerplate structure, stack, patterns, naming, commit rules. >>

## Definition of Done (per feature)
- Single PR, structured description, readable diff
- Passing tests on business logic
- No regression on existing code
- Review passed (no open critical issue)
- Deployed to production
