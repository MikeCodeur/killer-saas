# killer-saas — Method documentation

A complete agentic pipeline to kill a SaaS with Claude Code or Codex: pick a target, cut the 20% that matters, rebuild it on your boilerplate, ship it to production.
One method = a suite of commands. One principle = no direct coding.

> **Where the rules live.** This document explains the method. It does not restate its rules — the last version of this file drifted from `src/` on twelve points precisely because it paraphrased them. The rules are in `src/AGENTS.md` and in each command's own file; the doctrine is in the skills. When this page and `src/` disagree, `src/` wins.

## Philosophy

Three rules define the normal feature pipeline, enforced by the tooling — not by discipline:

1. **No direct coding.** No code is written outside the pipeline. `/ks-execute` doesn't have the Write/Edit/Bash tools: the main context *cannot* code, it delegates to the `implementer` subagent. The rule lives in the tooling, not in good intentions.
2. **The context that writes never reviews itself.** An agent is blind to its own hallucinations and to its own gaps. Reviews run in fresh-context, read-only subagents — `reviewer` for the code, `stories-reviewer` for the breakdown.
3. **Fail-closed.** No plan → no execution. A critical issue in review → no ship. Every gate blocks by default; nothing gets forced through.

A fourth rule joined them once the pipeline had been measured: **each check runs once, and once only.** A deterministic command re-run on unchanged code returns the same answer and costs the same minutes. Re-running the suite in Execute, again in Review, again per mutation and again at Ship bought nothing and cost four times the wall clock.

### Quick Fix mode

`Quick Fix` is the explicit, user-requested exception for a small, local, well-understood, easily reversible adjustment with no architectural or business impact — a color, a spacing, short UI copy, a responsive nudge. The primary agent announces the exact scope, edits directly in the repository base directory on `dev`, keeps the diff minimal, and verifies proportionately. It may use a subagent to investigate or review, never to implement.

It is not a shortcut for features or uncertain work. A new feature, a shared-component redesign, a data model or migration, an API or contract change, authorization, security, business rules, persistence, a cross-cutting refactor or a dependency change goes back to the pipeline before coding continues.

**Between Quick Fix and the full pipeline there is now a third lane** — `/ks-flow`, for a story that is genuinely small but is still a feature. See "The short track" below.

### Editing the workflow rules

`src/AGENTS.md` is the sole tracked source of truth for the rules that ship to a project. Maintainers edit that file, never the `AGENTS.md` a local test installation produced. Rules must not be copied into `CLAUDE.md`: Claude's project file stays a one-line `@AGENTS.md` import so Claude and Codex read the same rules.

**This repository's own root `AGENTS.md` is a different document.** It holds the maintenance rules — "edit in `src/`" — and `install.sh` deliberately leaves it intact here (`is_method_repo`). It is not `src/AGENTS.md` and never becomes it.

After changing the workflow, build both targets with `bin/ks-build.mjs` and test the relevant installer path. New installs receive `src/AGENTS.md`; a project's `AGENTS.md` is rebuilt on every install, so evolved rules reach existing projects the moment they update.

## Settings — `AGENTS.local.md`

**A rule that applies everywhere lives in `AGENTS.md`. A value that varies lives in `AGENTS.local.md`**, in the project, created once by `/ks-setup` and never overwritten by the installer. Every pipeline command reads its settings there; none of them defaults a missing one — a value of `—` means the project does not have that thing, and the agent says so rather than substituting one.

Format: one setting per line, `Name: value`, no trailing comment. The value is everything after the colon, trimmed.

| Setting | What it decides |
| --- | --- |
| `Merge mode` | `pr` (a pull request against the target branch) · `local` (squash-merged locally, no review platform) |
| `Target branch` | where a story lands |
| `Plan validation` | `human` (a checkpoint blocks until you validate) · `autonomous` (the agent validates its own plan) |
| `Ship confirmation` | `human` (asked before any merge) · `automatic` |
| `Story track` | `auto` (complexity picks the lane) · `full` · `flow` |
| `Flow threshold` | complexity at or below which `auto` picks `/ks-flow` |
| `Design source` | `internal` (the agent draws, via `Design skill`) · `external` (a brief goes to `Design tool`) |
| `Design skill` / `Design tool` | which one, when there is one. `—` is valid: the agent draws it itself |
| `Test budget` | tests per story; a plan wanting more says why |
| `Verification mode` | `record` (the implementer records what it ran, the reviewer checks the record) · `rerun` (the reviewer runs everything itself) |
| `Full suite` | when the whole unit suite runs: `execute-end` · `ship` · `both` |
| `E2E stage` | when the end-to-end suite runs: `execute-end` · `ship` · `ci` · `—` |
| `E2E scope` | how far it goes; `nominal` is one happy path |
| `E2E browsers` | browsers for the story cycle; ship always runs them all |
| `Build stage` | when the production build runs: `ship-if-route` · `ship` · `review` · `ci` · `—` |
| `Issue tracker` · `Worktree root` | where defects go, where worktrees live |

Below the settings, `AGENTS.local.md` carries the **project commands** — `Package manager`, `Test`, `Typecheck`, `E2E`, `Build` — and the **project conventions**, filled by `/ks-architect`. The commands are quoted verbatim by every agent that runs anything; none is ever invented.

**After editing this file by hand, rerun `install.sh`.** Settings are read straight from it and take effect at once, but the conventions only reach an agent through the assembled `AGENTS.md`.

## The pipeline

One setup step and five framing steps, once per product. Then one cycle per story — one story = one branch (`feature/<id>`) = one PR. Every story has an id (`s<number>-<short-slug>`, e.g. `s01-submit-testimonial`) that names every pipeline file and the branch.

    Setup → PRD → User Stories → Stories Review → Architecture → Design System
    then, per story:
    Research → Design → Plan → Execute → Review → Ship

| Step | Command | Role | Output |
| --- | --- | --- | --- |
| Setup | `/ks-setup` | The project's settings and commands, once, before anything else | `AGENTS.local.md` |
| PRD | `/ks-prd <target>` | The kill frame: target SaaS, kill mode, perimeter — the WHAT and the WHY | `docs/prd.md` |
| Stories | `/ks-stories` | Breakdown into shippable, agentic-ready slices | `docs/stories.md` |
| Stories Review | `/ks-stories-review` | Fresh-context review of the breakdown vs the PRD perimeter | `docs/reviews/stories.md` |
| Architecture | `/ks-architect` | The HOW: stack, conventions, patterns | `docs/architecture.md` + conventions in `AGENTS.local.md` |
| Design System | `/ks-design-system` | Captures tokens, components, UI patterns — and measures the contrasts, once | `docs/design-system.md` |
| Research | `/ks-research <story>` | The real state of the code within the story's scope | `docs/research/<id>.md` |
| Design | `/ks-design <story>` | The story's screen, anchored to the design system | `docs/designs/<id>/design.md` (+ one visual artifact for a new screen) |
| Plan | `/ks-plan <story>` | Sequenced, small, verifiable tasks | `docs/plans/<id>.md` |
| Execute | `/ks-execute <story>` | Implementation by the `implementer` subagent | code + tests + one commit + `docs/verif/<id>.md` |
| Review | `/ks-review <story>` | Anti-hallucination review by the `reviewer` subagent | `docs/reviews/<id>.md` |
| Ship | `/ks-ship <story>` | The exit gate, then merge per `Merge mode` / `Ship confirmation` | PR opened / feature in production |

### Framing (once per product)

**/ks-setup** — asks four questions and writes `AGENTS.local.md`: where a story lands, who validates a plan, who draws the screens, and the project's own commands (pre-filled from the lockfile and the package manifest — never invented). Everything else has a default you can change later. It runs once, before the PRD, and it is the only creator of that file.

**/ks-prd** — frames the kill by interviewing the user: which target SaaS, kill mode (internal replacement vs competing product), why kill it, and the perimeter — the 20% core loop that delivers the value, each replicated feature scored for complexity (1-5, heavy features default to the graveyard), the graveyard of explicitly dropped features, and the angle beyond parity. Then the classic frame: need, users, constraints, success criteria. Nothing is filled without validation. The WHAT and the WHY, never the HOW.

**/ks-stories** — breaks the PRD into agentic-ready user stories (`agentic-stories` skill): each an end-to-end shippable slice, with acceptance criteria that can become tests, agentic notes (files involved, traps), and a complexity score (1-5, PRD scale): a 4 flags its risk, a 5 is split before planning.

**/ks-stories-review** — reviews the breakdown in a fresh context (`stories-reviewer` subagent, read-only, no shell) against the PRD it came from. It walks the PRD perimeter table first — a core-loop feature covered by no story is the most expensive defect in the pipeline, invisible until ship — then hunts graveyard leaks, technical layers disguised as stories, criteria that can't become tests, broken dependency order, unsplit complexity-5 stories, malformed ids and overlaps. Report ends with `Max severity:` and `Stories ready: yes|no`. This is a **soft gate**: it doesn't block mechanically, it is surfaced by `/ks-status` and warned about by `/ks-research`. A bad split costs a markdown edit here, and cycles later.

**/ks-architect** — asks whether the project stands on a boilerplate; if none, it proposes one the user already owns, or ship-saas.now as one option for a modern fullstack stack, or a scaffolded default (Next.js + Tailwind + shadcn/ui) recorded as an ADR. Then analyzes the starting code (`codebase-analysis` skill): actual structure, conventions and patterns. Fills the architecture doc and writes the concrete conventions into `AGENTS.local.md`. The boilerplate is imposed: conform to it, don't rewrite it.

**/ks-design-system** — captures the global design system into `docs/design-system.md`: tokens, available components (inventoried from the boilerplate), imposed UI patterns, do/don't. It records and structures — it never invents visuals. **And it is the only phase that measures anything**: every text/surface pair the system can produce, light and dark, contrast measured rather than judged by eye. Done once on a system that does not move between stories, that measurement holds for every screen it can build — which is why no later phase repeats it.

### Cycle (per story)

**/ks-research** — explores the story's real scope before any planning: files involved in their current state, verified APIs and functions (exact name, signature, location), traps and dependencies. It checks the story's PREMISE, not just that the things it names exist — a function that exists and throws on the story's case invalidates it — and re-scores the story's complexity now that the code has been read, with a split proposal when the verdict is 5. Framing docs go stale as soon as story 2 ships; research anchors the plan in today's code. It is anti-hallucination applied upstream: the review detects, the research prevents. Capped at ~200 lines — three agents read it afterwards and pay for its length.

**/ks-design** — derives the story's screen from the design system. Fail-closed: no `docs/design-system.md`, no design. The path is a project setting (`Design source`), never a per-story choice.

The phase starts with one question: **is this a new screen, or a derived one?**
- **Derived** — the story composes, extends or restates something the product already ships. It produces `design.md` listing the deltas, and **no mockup**: drawing an existing screen draws the product twice, and the real screen gets opened in a browser at the end of Execute, which is where the defects that stop a feature working are actually found.
- **New** — it produces `design.md` plus **exactly one** visual artifact, never both: `mockup.html` on the internal path, or `brief.md` on the external one, with the mockup the tool returns dropped back into the folder (dropping it there *is* the validation).

A mockup is rendered and looked at — browser, both themes, both widths — and that step sends you back rather than ticking a box. **Nothing is measured**: contrast, font sizes, positions and `Δx` are design-system values, settled once upstream. Downstream, look for what is BROKEN. Needs the system doesn't cover become "design system gaps" — recorded, never invented. Stories without UI skip this step.

**/ks-plan** — breaks the story into ordered tasks, each small and verifiable, based on the research. Anticipates touched files and the test strategy, and carries the run's interdicts — what must not change, verifiable by the reviewer. Capped at ~250 lines. Never produces code. The plan is validated before execution, and `validated: yes` in its frontmatter is what execute checks.

**/ks-execute** — delegates to the `implementer` subagent on the story's worktree. Task by task: the task written as a whole block, its **focused** suite run on that task's own test files, its checkbox ticked. No red-first ceremony, no invariant mutations, a test budget of `Test budget`. After the last task: the full suite once, the type check once. **Not the end-to-end suite, not the production build** — those run at ship. Any task that ships a screen gets opened in a browser. Then, before the single story commit, it writes `docs/verif/<id>.md`. Fail-closed: no plan, or a plan without `validated: yes`, no execution. The main context has neither Write, nor Edit, nor Bash. If a previous review blocked the story, it runs in **fix mode**: the findings come first.

**/ks-review** — delegates to the `reviewer` subagent: fresh context, read-only. It starts at the verification record and checks it mechanically (`ks-gate verif-current <id>`): a record whose tree matches the commit proves the suite and the type check for this exact code, and they are not re-run. Missing, stale, or a non-zero exit code and the reviewer runs them itself. It then judges the story diff (`git diff <default-branch>...feature/<id>`), verifies every API and import in it actually exists, and proves the tests bite by neutralizing the line the story turns on — **running only the test files that name that invariant** — and counting the reds. A guard nothing turns red on is untested, whatever the suite total says. The mutation is temporary and restored before the report is written; it is the single exception to read-only. Each issue classified critical / major / minor. The report ends with `Max severity:` and `Ship allowed:`.

**/ks-ship** — starts with the mechanical gate: `grep '^Ship allowed: yes' docs/reviews/<id>.md` — no file or a `no` verdict stops everything. Then it runs the **exit gate, the one place in the whole cycle where the expensive checks happen**: the end-to-end suite once, and the production build when a route or a manifest moved — per `E2E stage` and `Build stage`. Any red sends the story back to fix mode. Then it follows `Merge mode` and `Ship confirmation`:

- `pr` + `human` — pushes, opens a clean PR with the review verdict in its body, and stops there: merging is a human decision. Rerun `/ks-ship <id>` after the merge to confirm the deployment and clean up.
- `pr` + `automatic` — squash-merges, deploys, confirms it's live.
- `local` — no PR at all: squash-merges into the target branch locally, for a solo flow with no review platform. `human` still asks before merging.

**Whatever the mode, the merge is a squash**: one story, one commit on the target branch. Cleanup — removing the worktree, deleting the branch — happens only on a PROVEN merge (`gh pr view … --json state` returning exactly `MERGED`, never a promise, and never `git merge-base --is-ancestor`, which a squash merge always defeats).

### The short track — `/ks-flow`

A story of complexity 1 does not need six cold contexts to read the same four documents. `/ks-flow` runs the same cycle in three: **research and plan fused into one pass**, then the same `implementer`, then the same fresh-context `reviewer`, then ship.

**Nothing is relaxed.** Dedicated worktree, validated plan, fresh-context review with its neutralization proof, browser pass, `Ship allowed` gate, test budget — all identical. What disappears is repetition, not verification. The research does not vanish either: its verified facts, with their `path:line`, become the "Verified facts" section at the top of `docs/plans/<id>.md` (`track: flow`, capped at ~150 lines) — one file fewer to write, and one fewer for three downstream agents to read.

`Story track` decides: `full`, `flow`, or `auto` (`flow` at or below `Flow threshold`, `full` above it). And whatever the score, **five signals send a story back to the full pipeline**: a schema migration, a genuinely new screen, a change to authorization or tenant scope, a change to an API contract, an added dependency. The check runs twice — once before starting, once again after the code has been read, because reading it is what reveals a migration hiding behind a nullable column. Escalating mid-flight loses nothing: the research was needed either way.

### Where work happens

Two modes, and a complexity score never chooses the directory — it only chooses the track:

| Mode | Working directory | Branch |
| --- | --- | --- |
| Explicit Quick Fix | Repository base directory | `dev`; another branch checked out → stop and ask |
| Feature / story | Dedicated `.worktrees/<story-id>/` worktree | Exact `feature/<story-id>` |

A feature stays in its worktree from the first phase to the last. **The method says where the work happens, not how the workspace is built**: the entry command — `/ks-research` or `/ks-flow` — creates or verifies it, through a `worktree-manager` subagent when the environment provides one, otherwise with plain `git worktree add`. Either way it imports the untracked `.env*` files and installs dependencies there, and never runs a baseline test suite: the default branch's state is not this story's problem.

Every later phase resolves the absolute path and verifies the exact branch. Missing worktree, wrong branch, detached HEAD or a second branch name is a hard stop — never `git switch`, `checkout`, `stash`, or an `-isolated` suffix. One agent, one working directory.

### Utilities

**/ks-orchestrator <story>** — the conductor. It chains one story's full cycle in a single command, picking the track from `Story track` and handing over to `/ks-flow` when the story qualifies. What it does NOT do: replace the method. Each phase follows the exact contract of its standalone command, code and review stay delegated to the same subagents, and it stops on two blocking questions (real AskUserQuestion calls, not sentences): **validate the plan** and **confirm the ship**. Use it when the cycle is routine; use the individual commands when you want to inspect or steer a phase. It is fail-closed on framing: no PRD, stories or architecture → it stops and points at the missing step.

**/ks-help** — prints the pipeline map: the phases in order, the single rule, the per-story cycle, the short track. Written in French — it's the user-facing cheat sheet. User-invoked only.

**/ks-status** — derives the project's state from the files: settings, framing docs, and per story — complexity, research, design, plan (draft or validated, `flow` or `full`), checkbox progress, verification record, review verdict, PR/merge state, dependency blocks — then prints the next useful command per story and for the project. Nothing is stored: the files are the state.

## Data & storage

Everything the pipeline produces is markdown under `docs/`, versioned by git. No database, no state file, no external tracker.

| Data | Lives in |
| --- | --- |
| PRD, stories, architecture, design system | `docs/prd.md`, `docs/stories.md`, `docs/architecture.md`, `docs/design-system.md` |
| Research, plan, verification, review (per story) | `docs/research/<id>.md`, `docs/plans/<id>.md`, `docs/verif/<id>.md`, `docs/reviews/<id>.md` |
| Tasks + progress | checkboxes inside `docs/plans/<id>.md`, ticked as each task lands |
| Decisions | `docs/decisions/NNN-<slug>.md` — MADR-style ADRs: context, options rejected and why, consequences. Immutable, superseded not edited |
| Design | `docs/design-system.md` (global) ; `docs/designs/<id>/` per story — the mockup is a reference, never production code |
| Pipeline state | derived — file existence + `Ship allowed:` verdict + git. Never stored, so never stale |

Lifecycle: framing docs are committed on the default branch at the end of their phase. Story docs travel with the story on `feature/<id>`. **One commit per story, not one per task** — the implementer's single commit carries the research, the design, the plan with its ticked checkboxes, the verification record and the code of every task; `/ks-ship` commits the review. The plan file is the live progress tracker, never a commit trigger. Branch commits are squashed at merge, so the default branch gets one commit per story. Every PR therefore carries its own research, design, plan, verification and review: the audit trail is the PR itself.

**A defect is not a story.** A bug, a stale assertion, a screen that renders wrong — it goes to the issue tracker, never into `docs/stories.md`, which holds the product perimeter. A review finding stays in its review report unless a human decides otherwise.

## Tooling anatomy

Five building blocks:

| Block | Location | Role |
| --- | --- | --- |
| Commands | `.claude/commands/ks-*.md` · `.codex/skills/ks-*` | The process — each pipeline step is a command |
| Skills | `.claude/skills/` · `.codex/skills/` | The know-how — reusable, auto-invocable |
| Agents | `.claude/agents/` | Isolated execution — separate contexts, restricted tools |
| Templates | `templates/` | The deliverables' structure — every doc has an imposed skeleton |
| Rules | `AGENTS.md` (method) + `AGENTS.local.md` (project), assembled at install | The law of the repo |

### The subagents

- **implementer** (`opus`, `testing-doctrine` preloaded) — implements the plan task by task under `Test budget`. Touches neither the architecture nor the rules, adds nothing out of scope, and records what it ran before committing.
- **reviewer** (`review-antihallu` + `testing-doctrine` preloaded, read-only apart from the restored mutation of the bite proof) — fresh eyes on code it didn't write. Judges, doesn't fix. Ends by naming what it could NOT verify. A single critical = ship refused.
- **stories-reviewer** (`stories-review` preloaded, read-only, no shell) — reads the breakdown against the PRD perimeter. Reports, never rewrites the stories.

Workspace creation is deliberately **not** a subagent of the method: the method says the work happens in `.worktrees/<id>` on `feature/<id>` and lets the environment's own tooling build it.

Model policy: the reviewers use `model: inherit` — the review runs with whatever model your session runs. Nothing silently downgrades, and the method doesn't assume you have a specific tier. The implementer is pinned to `opus`: implementing a full story is the longest, most demanding run of the cycle, and a cheaper tier costs more in round-trips than it saves per token. Change either in `src/agents/*.md`.

### The skills

- `agentic-stories` — breakdown into agent-executable stories (Stories phase)
- `codebase-analysis` — code archaeology: structure, conventions, patterns (Architecture, Research, Flow)
- `review-antihallu` — hallucination detection in generated code (preloaded in `reviewer`)
- `stories-review` — breakdown defects: perimeter coverage, graveyard leaks, dependency order (preloaded in `stories-reviewer`)
- `testing-doctrine` — what to test, where, how much, when to run it (preloaded in `implementer` and `reviewer`)
- `design-doctrine` — how a screen is derived from the design system (loaded by the design commands)

The last two exist for a structural reason: `AGENTS.md` is loaded automatically in **every** agent context, and a project's `AGENTS.local.md` is concatenated onto it. Doctrine that only two agents act on does not belong in the file everyone pays for.

## The gates

Three mechanical, file-based gates. None of them is a judgment call — each is a grep or a diff, which is why they port to every tool and to CI.

| Gate | Check | Blocks |
| --- | --- | --- |
| Plan validated | `docs/plans/<id>.md` frontmatter has `validated: yes` | any code commit on `feature/<id>`, and `/ks-execute` |
| Verification current | `docs/verif/<id>.md` records a `Tree:` matching the commit outside `docs/` | nothing by itself — it decides whether the reviewer trusts the run or repeats it |
| Ship allowed | `docs/reviews/<id>.md` ends with `Ship allowed: yes` | `/ks-ship`, entirely |

`src/hooks/ks-gate.sh` implements all three (`plan-validated`, `verif-current`, `ship-allowed`, plus `pre-commit`).

**Only a critical blocks the ship.** A `major` is a real defect — traced in the report, fixed in a next cycle. A `minor` is style. Neither reopens a fix loop: a loop is a full implementation pass plus a full review pass, and spending one on naming costs half a story and closes no defect. Two loops at most, and only for a critical or a review that could not complete.

A plan file that merely exists is not a validated plan. An absent verification record is never a pass.

## Testing, in one page

The full doctrine is the `testing-doctrine` skill. What it comes down to:

**Volume is not a net.** The suite grows by dozens of tests per story while the central invariant ships with no net at all — found by mutation during review, never by the count. `Test budget` (25 by default) caps it; a plan wanting more says why. **The criterion that replaces the count: a test that stays green when the rule it names is deleted is worse than no test.**

**Where a rule is tested is where it lives.** The permission matrix once, in the policy test. No enum exhaustiveness. Never the same rule at two layers. No adapter re-asserting a 403 the policy already owns.

**When to run what**, each thing once and once only:

| Run | When |
| --- | --- |
| Focused suite | after each task, on that task's own test files |
| Full suite | once, after the last task |
| Type check | once, after the last edit — a type error in a test file passes lint, passes the runner, and fails CI |
| End-to-end | once at ship, just before the merge |
| Production build | at ship, and only when a route or a manifest moved |
| Format | never repo-wide — the staged files at commit |

**No red-first ceremony and no invariant mutations during implementation.** The author who just wrote the test already knows it passes; mutating to watch it fail verifies the tests, not the code, and has produced zero findings. **The same technique in review earns its place**: run in fresh context on someone else's net, it has found a critical, six majors, and repeatedly an invariant with no test at all.

## Definition of Done (per feature)

- Single PR, structured description, readable diff
- Passing tests on business logic
- No regression on existing code
- Review passed (no open critical issue)
- Deployed to production

## Install

The installer always targets the directory you run it from — your project's root, not this repo. Get it either via the one-liner (it fetches the repo by itself) or by cloning this repo somewhere and calling its `install.sh` from your project.

| Mode | From your project's root | Effect |
| --- | --- | --- |
| Project (default) | `curl -fsSL https://raw.githubusercontent.com/MikeCodeur/killer-saas/main/install.sh \| bash` — or `<clone>/install.sh` | `.claude/` + `templates/` + `AGENTS.md`/`CLAUDE.md` in the current project |
| Global | `<clone>/install.sh --global` | Tooling in `~/.claude` (commands everywhere), payload in `~/.claude/killer-saas` |
| Per project, after global | `~/.claude/killer-saas/install.sh init` | Drops templates + rules in the current project |
| Update | `<clone>/install.sh update` — or the one-liner with `-s -- update` | Cleanly replaces the method's tooling (manifest-tracked, no ghosts, your own commands untouched), refreshes unmodified templates (modified ones are warned about, never overwritten — add `--force` to overwrite them too), stamps `.claude/.ks-version` |

`AGENTS.md` is rebuilt on every run from `src/AGENTS.md` plus the project's `AGENTS.local.md`, which the installer never touches. `CLAUDE.md` is not shipped: the installer creates it (or appends to it) with `@AGENTS.md`, so Claude Code loads the rules. `install.sh --check` lists what has drifted in an install — run it before updating a project, or the update eats the work silently.

The first thing to run in a fresh project is `/ks-setup`: without `AGENTS.local.md`, every pipeline command stops and asks for it.

## Multi-tool support (Claude Code / Codex)

One canonical source (`src/`, Claude-shaped, the richest target), one installer, per-tool emission — no forked copies. `./install.sh --target claude|codex|all`, project or global scope, drives a per-tool adapter; the Codex transform runs through a zero-dependency Node build (`bin/ks-build.mjs`). What ports and what degrades:

| Building block | Claude Code | Codex |
| --- | --- | --- |
| Rules (`AGENTS.md`) | native (+`CLAUDE.md` import) | **native** |
| Skills (`SKILL.md`) | native | **native** (same open standard) |
| Templates | copied | copied |
| Commands (`ks-*`) | `.claude/commands/*.md` | emitted as `.codex/skills/*` |
| File/grep gates (`validated:`, `Ship allowed:`, `Tree:`) | ✅ | ✅ |
| "No direct coding" via tool permissions | ✅ mechanical | ~ agent sandbox (coarser) |
| Subagent model routing | ✅ | note only |
| `AskUserQuestion` checkpoints | ✅ structured | prose |

**The honest line:** the file-based gates port to every tool because they are shell-on-markdown, not tool permissions. The permission and isolation guarantees are Claude-mechanical and degrade elsewhere. Rather than pretend otherwise, killer-saas moves enforcement into the **repo**.

### Repo-level enforcement (`--hooks`)

Opt-in git hooks (installed via `core.hooksPath`, reversible with `git config --unset core.hooksPath`) enforce the gates in git, identically for every tool:

- **pre-commit** — no code on `feature/<id>` without `docs/plans/<id>.md` → `validated: yes` (docs-only commits pass).

So "no code without a validated plan" holds whatever the harness — enforcement lives in the repo, not the tool. There is no push-time hook: `/ks-ship` squash-merges, so a merged story leaves no merge commit to detect client-side. The ship gate belongs server-side — `ks-gate ship-allowed <id>` in CI or branch protection.
