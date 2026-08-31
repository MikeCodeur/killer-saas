# killer-saas — Repo rules

**This file belongs to the method and is rebuilt on every `install.sh` run — anything written
here is lost.** Everything specific to this project — settings, project commands, conventions —
lives in `AGENTS.local.md`, which the installer never overwrites and appends below these rules.
`/ks-setup` creates it.

**A rule that follows applies to every project. A value that varies is read from
`AGENTS.local.md`.** Where a rule below names a setting (`Merge mode`, `Design source`,
`Test budget`…), that setting is read there — never decided by the agent, and never defaulted
when it is missing.

**How to read one:** in `AGENTS.local.md`, never in `AGENTS.md` — the rules quote the setting
names in prose, so grepping the assembled file returns the prose too. One setting per line,
`Name: value`, the value being everything after the colon, trimmed. A value of `—` means the
project does not have that thing; say so rather than substituting one.

## Absolute rule
No direct coding. Every feature goes through the killer-saas pipeline, in order:

Setup → PRD → User Stories → Architecture (+ Design System) → then, per story: Research → Design → Plan → Execute → Review → Ship

`/ks-setup` is not a phase of the cycle: it writes the project's settings once, and every command below reads them.

No code is written before the story has a validated plan (`/ks-plan`). No feature ships before a passed review (`/ks-review`).

### Quick Fix mode — exception to the pipeline

`Quick Fix` is the explicit exception for a small, local, well-understood, and
easily reversible adjustment. It applies only when the user explicitly requests
a Quick Fix. The primary agent implements it directly, without the full
killer-saas pipeline. It must not delegate
implementation to a subagent; a subagent may be used only for read-only
investigation or optional review.

Typical Quick Fixes include:

- changing a color, spacing, radius, font size, or button style;
- correcting short UI copy or a translation;
- making a small layout alignment or responsive adjustment;
- restoring or adjusting an already-existing presentation affordance;
- another similarly narrow change with no architectural or business impact.

Quick Fix mode does **not** apply to a new feature, shared-component redesign,
data model or migration, API or contract change, authorization, security,
business rules, persistence, cross-cutting refactor, dependency change, or any
change whose impact is uncertain. If the requested Quick Fix is too large or
investigation reveals one of these, the primary agent must stop Quick Fix mode,
recommend using the normal pipeline, and must not continue coding until the work
has passed the appropriate pipeline stages.

The primary agent must announce Quick Fix mode and its exact scope before
editing, keep the diff minimal, preserve existing abstractions, and perform a
proportionate verification (at minimum a focused lint, typecheck, existing test,
or visual browser check when applicable). Subagent review is optional,
not forbidden.

Quick Fix work happens only in the repository's base directory on branch
`dev`. It never gets a feature branch or a worktree. Before editing, check the
current branch. If it is not `dev`, stop and ask the user whether they really
want to continue on that non-`dev` branch; never switch branches automatically.
Before editing, verify that no other agent owns the base directory. If another
agent is working there, coordinate ownership or stop; never overlap edits.

## Pipeline (commands)
- `/ks-setup`      writes the project's settings and commands into AGENTS.local.md (once, first)
- `/ks-prd`        frames the kill: target SaaS, kill mode, perimeter (WHAT + WHY)
- `/ks-stories`    breaks it down into shippable user stories
- `/ks-stories-review`  reviews the breakdown against the PRD perimeter (stories-reviewer subagent)
- `/ks-architect`  sets the technical HOW + the conventions
- `/ks-design-system`  captures the global design system (docs/design-system.md)
- `/ks-research`   explores the story's real context (current code, APIs, traps)
- `/ks-design`     derives a story's screen from the design system (UI stories)
- `/ks-plan`       breaks a story into sequenced tasks
- `/ks-execute`    implements the story (implementer subagent)
- `/ks-review`     anti-hallucination review + gate (reviewer subagent)
- `/ks-ship`       ships the story per `Merge mode` / `Ship confirmation` (AGENTS.local.md)

Utilities:
- `/ks-orchestrator`  runs a story's full cycle with human checkpoints (plan validation, ship confirmation)
- `/ks-help`          prints the pipeline map (French, user-facing cheat sheet)
- `/ks-status`        derives the project's pipeline state from the files (framing, per-story progress, next command)

**Run the commands. Never hand-roll the agent call.** `/ks-execute <id>` and `/ks-review <id>`
carry what the pipeline has learned — the fix mode that spawns a fresh implementer, the subagent
definitions, the gate. A briefing written by hand replaces all of it with an opinion, and the agent
definitions it restates are denser and more current than any prompt. Parallel stories are several
commands, never several hand-written prompts.

One feature = one Research → Design → Plan → Execute → Review → Ship cycle = one branch = one PR (Design only when the story has UI).

## Where work happens

There are exactly two modes. A complexity score never chooses the directory:

| Mode | Working directory | Branch |
| --- | --- | --- |
| Explicit Quick Fix | Repository base directory | `dev`; if another branch is checked out, stop and ask before continuing |
| Feature / story | Dedicated `.worktrees/<story-id>/` worktree | Exact `feature/<story-id>` branch |

Every change that is not explicitly announced and eligible as a Quick Fix is a
feature. A feature uses its dedicated worktree from Research through Design,
Plan, Execute, Review and Ship, regardless of its complexity score. Never
create or check out a feature branch in the repository base directory.

The `worktree-manager` subagent creates or verifies the worktree before
Research begins. It imports untracked `.env*` files and installs dependencies
inside the worktree. Before every later story phase, resolve and state the
absolute worktree path and verify the exact branch. Missing worktree, wrong
branch, detached HEAD or a second branch name is a hard stop. Never improvise
with `git switch`, `git checkout`, `git stash` or an `-isolated` suffix.

One agent, one working directory. While an agent owns a directory, no second
agent and no main context may edit, checkout or stash in it.

## What is a story, and what is not

`docs/stories.md` holds the **product perimeter** — the breakdown `/ks-stories` produced and
`/ks-stories-review` validated against the PRD. A story is a new capability.

**A defect is not a story.** A bug, a stale assertion, a screen that renders wrong, a footgun — it
goes to the issue tracker, never into `docs/stories.md`. Putting it there inflates the perimeter
with work nobody scoped, and `/ks-status` then counts it as product left to build.

**A review finding stays in its review report** unless a human decides otherwise. It is already
traced there, with its `file:line` and how it was found.

## Story ids and branches
- Every story has an id: `s<number>-<short-slug>` (e.g. `s01-submit-testimonial`). It is assigned in docs/stories.md and reused verbatim everywhere: `docs/research/<id>.md`, `docs/plans/<id>.md`, `docs/reviews/<id>.md`, branch `feature/<id>`.
- All work on a story happens on `feature/<id>`, branched from the default branch. Never commit story work to the default branch.
- The story diff = `git diff <default-branch>...feature/<id>`. That is what the review judges.
- A command that receives a fuzzy story name resolves it against docs/stories.md; if there is no unambiguous match, it lists the available stories and stops.

## Gate (mechanical)
- The review report `docs/reviews/<id>.md` must end with the exact lines `Max severity: <critical|major|minor|none>` and `Ship allowed: <yes|no>`. A single critical = no.
- `/ks-ship` refuses to run unless that file exists and contains the line `Ship allowed: yes`. No file, no line, or `no` → ship blocked. No exceptions.
- After a blocked review, `/ks-execute` runs in fix mode: the review findings are fed to the implementer and fixed before anything else.
- A plan executes only if its frontmatter says `validated: yes` — set by the human validation checkpoint (/ks-plan or the orchestrator), never by the file merely existing. /ks-execute is fail-closed on it.

## Ship strategy
Read `Merge mode`, `Target branch` and `Ship confirmation` from `AGENTS.local.md`.

- `Merge mode: pr` — /ks-ship opens a PR against the target branch. With `Ship confirmation: human` it stops there and merging is a human decision (review on GitHub, protected branch, CI); rerun /ks-ship after the merge to confirm the deployment and clean up. With `automatic` it squash-merges and deploys right after the gate.
- `Merge mode: local` — no PR: /ks-ship squash-merges the story into the target branch locally, for a solo flow with no review platform. `Ship confirmation: human` still asks before merging.

Whatever the mode, the merge is a **squash**: one story, one commit on the target branch.

## Design

Read `Design source` from `AGENTS.local.md` — a project decision, never a per-story one.

- `internal`: the agent produces the mockup, directly or through the skill named by `Design skill`.
- `external`: the agent writes a brief, the tool named by `Design tool` produces the screens, and
  the mockup is dropped back into `docs/designs/<id>/`. Dropping it **is** the validation.

The global design system lives in `docs/design-system.md` (components + tokens, anchored to the boilerplate). Each story's design lives in its own folder, `docs/designs/<id>/` — `design.md`, `mockup.html`, `brief.md` when an external tool produced it, and any extra frames beside them.
- A story's design can be produced by the agent itself, by an internal design skill, or by an external tool that holds the design system and whose result is brought back. Either way it builds on the design system, and the pipeline prescribes neither the tool nor the skill.
- **The repository is authoritative.** An external design tool — including one an agent can write to — is a working surface, never the source of truth. Anything reworked there is brought back into `docs/designs/<id>/` before implementation, or the code and the design diverge unnoticed.
- A mockup is never handed over unrendered: it is opened in a browser, checked in both themes and
  at both widths, and **its contrasts are measured** — a pair at 4.2:1 and one at 4.8:1 look
  identical, and an external tool has no guarantee of having honoured the real tokens. "Could not
  verify" is an acceptable report; skipping in silence is not.
- **That measurement belongs to the mockup, and stops there.** Implementation and review do not
  redo it: the tokens carry those decisions, the mockup already validated them, and re-measuring
  each story re-litigates the design system instead of using it. Downstream, look for what is
  BROKEN — horizontal overflow, unreadable text, a control that disappeared, a missing state, a
  layout that collapses.
- **Every UI story produces its `mockup.html`, and the phase ends only when it exists.** Even when
  the screen composes one that already ships, `design.md` lists the deltas **and** the mockup shows
  them: it is the only artifact that exists before the code, and the one thing someone can look at
  in thirty seconds. Validating a mockup costs minutes; correcting a shipped screen costs a story.
- Inventing a component or token outside the design system is forbidden. Compose with what exists.
- The HTML mockup is a reference, not code: the implementation uses the boilerplate's real components.
- A need the system doesn't cover = a "design system gap" to report, never to fill freestyle.
- Stories without UI skip `/ks-design`.

## Data & docs lifecycle
All pipeline data lives in markdown files under docs/, versioned by git. No database, no state file: the pipeline state is derived from the files (a story is planned if docs/plans/<id>.md exists, shipped if its review says `Ship allowed: yes` and the branch is merged) — a derived state can't go stale.

- Framing docs — docs/prd.md, docs/stories.md, docs/reviews/stories.md, docs/architecture.md, docs/design-system.md: committed on the default branch at the end of their phase. (docs/reviews/stories.md reviews the breakdown, not a story: it is a framing doc, unlike docs/reviews/<id>.md which travels with its branch.)
- Story docs — docs/research/<id>.md, docs/designs/<id>/ (brief.md, design.md, mockup.html), docs/plans/<id>.md, docs/reviews/<id>.md: committed on feature/<id>. The implementer's single story commit brings the research, the design and the plan; /ks-ship commits the review. Every PR carries its own research, design, plan and review.
- Document size — research ~200 lines, plan ~250, review ~150. Every downstream agent reads these files and pays for their length. Cap the prose, never the decision tables: what carries decisions stays whole.
- Task progress — the checkboxes in docs/plans/<id>.md: the implementer ticks each task as it lands, and they travel in the story's commit. The plan file is the live progress tracker, never a commit trigger.
- Commits — **one commit per story**, not one per plan task. A second commit only for something you would want to revert on its own (typically a migration). The branch's commits are squashed at merge, so the default branch gets one commit per story.
- Decisions — docs/decisions/NNN-<slug>.md (MADR format, @templates/adr.md): one file per structural decision, with the considered options and why they were rejected. Immutable: a change means a new ADR superseding the old one. Framing decisions commit on the default branch; story decisions travel with feature/<id>.

## Testing

**Budget: `Test budget` from `AGENTS.local.md` (25 by default), and a story that needs more says why in its plan.**

Measured on a batch of eleven stories run through this pipeline: the suite grew by 614
tests, about 56 per story — and in the same batch **seven of those eleven shipped their
central invariant with no net at all**, every one found by mutation during review and none
by the volume. The number does not measure the net. It buys false confidence, and it is
slow: a suite that takes half an hour to run is a suite nobody runs.

**Where the tests go**

| Layer | What to test |
| --- | --- |
| Business/service layer and its authorization | Everything that matters. The **role or permission matrix belongs to the policy test, written once** — a service command invents no access rule, it calls the policy. The service test then covers the **business rule**: one nominal case, one refusal per rule it owns. |
| Persistence | Only what no reading catches: the idempotency ordering of a retryable mutation, and the tenant/ownership clause of each query. Call the repository **directly** — the service refuses upstream, so an applicative call never reaches the guard. |
| Adapter (HTTP route, server action, controller) | Only what the service does not do: payload parsing, field clearing, status mapping. **An adapter never re-tests a 403** — it verifies once that a refusal becomes a 403, never per role and never per rule. |
| Component / view | Almost none. Only genuine conditional logic of its own; rendering a list is not a rule. |
| End-to-end | One scenario, for what unit tests structurally cannot see — typically a side effect written inside a transaction, which mocked repositories hide. |

**Four cuts, each measured on that batch**

1. **The matrix once, in the policy test.** Replayed per command, it took a single service test file to 57 tests.
2. **No enum exhaustiveness.** One story tested the 25 ordered pairs of a transition table for one rule; the legal transitions plus one representative refusal say the same thing.
3. **Never the same rule at two layers.** Pick the layer where the rule lives.
4. **No adapter re-asserting a 403.**

**No red-first ceremony, and no invariant mutations in implementation.** Do not write a
failing test to watch it fail, and do not neutralize a guard to confirm a test goes red.
Write the code as whole blocks, write the tests that belong to it, run them. Measured:
thirteen such mutations across one story and its fix pass, each costing a full suite run
plus a restore plus another run, and **zero findings** — the author who just wrote the test
already knows it passes. It verifies the tests, not the code.

**The same technique stays in review, and there it earns its place.** Run in fresh context
on someone else's net, it found a critical, six majors, and — repeatedly — an invariant with
no test at all. The safety moves downstream to where it works; it is not dropped.

**The failure mode this pipeline keeps producing: a test that names an invariant without
exercising it.** Seven stories out of eleven shipped one. Six shapes seen, worth citing
verbatim in a prompt because they are hard to spot by reading:

1. a hand-written query in the test instead of a call to the code under test — it tests the database, not the repository;
2. a payload the real interface never produces;
3. a `catch` that swallows the failure, so the assertion passes when nothing throws;
4. an end-to-end test that stays green while rendering zero rows;
5. a **fixture** whose identifier lets a downstream guard answer for the guard under test — invisible when reading assertions;
6. a **mock double that replays** the clause instead of evaluating it.

**The criterion that replaces the count: a test that stays green when the rule it names is
deleted is worse than no test** — it hides the hole it claims to cover.

**When to run what**

| Run | When |
| --- | --- |
| Focused suite | after each task — the working loop |
| Full suite | once at the end, plus once more when a task touched a shared file |
| End-to-end | once at the end, never in the loop: a run costs a cold server start, a migration, a seed and a browser driver |
| Type check | **once at the very end, after the last edit, and not optional** — most runners transpile without checking types and most linters do not type, so a type error in a test file passes lint, passes the suite, and fails CI |
| Format | never as a repo-wide sweep — format the staged files at commit; a story is one commit |

## Technical conventions
In `AGENTS.local.md`, under "Project conventions" — filled by `/ks-architect` from the boilerplate.

## Never edit an installed file
A command, an agent or a skill under `.claude/` or `.codex/` is **replaced without warning** on
the next `install.sh`. Anything edited there is lost, silently. What is specific to this project
becomes a setting read from `AGENTS.local.md`; what is a genuine improvement goes upstream into
the method's `src/`. Run `install.sh --check` to list what has drifted before updating.

## Definition of Done (per feature)
- Single PR, structured description, readable diff
- Passing tests on business logic
- No regression on existing code
- Review passed (no open critical issue)
- Deployed to production
