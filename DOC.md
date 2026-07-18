# killer-saas — Method documentation

A complete agentic pipeline to build and ship a SaaS with Claude Code, from need to production.
One method = a suite of commands. One principle = no direct coding.

## Philosophy

Three rules, enforced by the tooling — not by discipline:

1. **No direct coding.** No code is written outside the pipeline. `/ks-execute` doesn't have the Write/Edit/Bash tools: the main context *cannot* code, it delegates to the `implementer` subagent. The rule lives in the tooling, not in good intentions.
2. **The context that writes never reviews itself.** An agent is blind to its own hallucinations. The review runs in a fresh-context, read-only subagent (`reviewer`).
3. **Fail-closed.** No plan → no execution. A critical issue in review → no ship. Every gate blocks by default; nothing gets forced through.

## The pipeline

Three framing steps, once per product. Then one cycle per story — one story = one branch (`feature/<id>`) = one PR. Every story has an id (`s<number>-<short-slug>`, e.g. `s01-submit-testimonial`) that names every pipeline file and the branch.

    PRD → User Stories → Architecture
    then, per story:
    Research → Plan → Execute → Review → Ship

| Step | Command | Role | Output |
| --- | --- | --- | --- |
| PRD | `/ks-prd <idea>` | The WHAT and the WHY: need, users, scope | `docs/prd.md` |
| Stories | `/ks-stories` | Breakdown into shippable, agentic-ready slices | `docs/stories.md` |
| Architecture | `/ks-architect` | The HOW: stack, conventions, patterns | `docs/architecture.md` + `AGENTS.md` |
| Research | `/ks-research <story>` | The real state of the code within the story's scope | `docs/research/<story>.md` |
| Plan | `/ks-plan <story>` | Sequenced, small, verifiable tasks | `docs/plans/<story>.md` |
| Execute | `/ks-execute <story>` | TDD implementation by the `implementer` subagent | code + tests + commits |
| Review | `/ks-review <story>` | Anti-hallucination review by the `reviewer` subagent | `docs/reviews/<story>.md` |
| Ship | `/ks-ship <story>` | PR, merge, deploy | feature in production |

### Framing (once per product)

**/ks-prd** — frames the product by interviewing the user: need, target users, in/out scope, constraints, success criteria. Nothing is filled without validation. The WHAT and the WHY, never the HOW.

**/ks-stories** — breaks the PRD into agentic-ready user stories (`agentic-stories-skill`): each story is an end-to-end shippable slice, with acceptance criteria that can become tests and agentic notes (files involved, traps) — the context a human would infer but an agent must read.

**/ks-architect** — analyzes the starting code (`codebase-analysis-skill`): actual structure, conventions and patterns of the boilerplate. Fills the architecture doc and injects the concrete conventions into `AGENTS.md`. The boilerplate is imposed: conform to it, don't rewrite it.

### Cycle (per story)

**/ks-research** — explores the story's real scope before any planning: files involved in their current state, verified APIs and functions (exact name, signature, location), traps and dependencies. Framing docs go stale as soon as story 2 ships; research anchors the plan in today's code, not day one's. It is anti-hallucination applied upstream: the review detects, the research prevents.

**/ks-plan** — breaks the story into ordered tasks, each one small and verifiable, based on the research. Anticipates touched files and the test strategy. Never produces code. The plan is validated by the user before execution.

**/ks-execute** — delegates the implementation to the `implementer` subagent, which works on the story branch `feature/<id>` (strict TDD: failing test → minimal code → refactor, one commit per task). Fail-closed: no plan in `docs/plans/<id>.md`, no execution. The main context has neither Write, nor Edit, nor Bash — it can't code even if it "wanted" to. If a previous review blocked the story, it runs in **fix mode**: the review findings are fed to the implementer and fixed first.

**/ks-review** — delegates the review to the `reviewer` subagent: fresh context, read-only, opus model. The reviewer judges the story diff (`git diff <default-branch>...feature/<id>`), runs the test suite itself, and verifies every API/import in the diff actually exists. Each issue classified critical / major / minor. The report ends with two machine-parsable lines: `Max severity: ...` and `Ship allowed: yes|no`.

**/ks-ship** — starts with the mechanical gate: `grep '^Ship allowed: yes' docs/reviews/<id>.md` — no file or a `no` verdict stops everything. Then verifies tests on the branch, pushes, opens a clean PR, merges, deploys, confirms it's live.

## Tooling anatomy

Five building blocks:

| Block | Location | Role |
| --- | --- | --- |
| Commands | `.claude/commands/ks-*.md` | The process — each pipeline step is a command |
| Skills | `.claude/skills/*-skill/` | The know-how — reusable, auto-invocable |
| Agents | `.claude/agents/` | Isolated execution — separate contexts, restricted tools |
| Templates | `templates/` | The deliverables' structure — every doc has an imposed skeleton |
| Rules | `AGENTS.md` (+ `CLAUDE.md` → `@AGENTS.md`) | The law of the repo — pipeline, conventions, DoD, gate |

### The subagents

- **implementer** (sonnet model, `tdd-skill` preloaded) — implements the plan, task by task, in TDD. Touches neither the architecture nor the rules, adds nothing out of scope.
- **reviewer** (opus model, `review-antihallu-skill` preloaded, read-only) — fresh eyes on code it didn't write. Judges, doesn't fix. A single critical = ship refused.

The model asymmetry is deliberate: implementation is framed by a validated plan (sonnet is enough); the review is the last safety net (opus).

### The skills

- `agentic-stories-skill` — breakdown into agent-executable stories (Stories phase)
- `codebase-analysis-skill` — code archaeology: structure, conventions, patterns (Architecture and Research phases)
- `tdd-skill` — test-first discipline (preloaded in `implementer`)
- `review-antihallu-skill` — hallucination detection in generated code (preloaded in `reviewer`)

## The gate

The review returns a verdict written to `docs/reviews/<id>.md`, ending with the exact lines `Max severity: ...` and `Ship allowed: yes|no`. The gate is mechanical, not declarative: `/ks-ship` greps that line and refuses to run without a `yes` — the verdict file is the key, not anyone's judgment call.

- **Critical** → `Ship allowed: no` → ship blocked. Fix via `/ks-execute` (fix mode: the findings are fixed first), then a new `/ks-review`. No exceptions.
- Major / minor → ship allowed, issues to address in a next cycle.

## Definition of Done (per feature)

- Single PR, structured description, readable diff
- Passing tests on business logic
- No regression on existing code
- Review passed (no open critical issue)
- Deployed to production

## Install

| Mode | Command | Effect |
| --- | --- | --- |
| Project (default) | `./install.sh` | `.claude/` + `templates/` + `AGENTS.md`/`CLAUDE.md` in the current project |
| Global | `./install.sh --global` | Tooling in `~/.claude` (commands everywhere), payload in `~/.claude/killer-saas` |
| Per project, after global | `~/.claude/killer-saas/install.sh init` | Drops templates + rules in the current project |

`CLAUDE.md` is not shipped: the installer creates it (or appends to it) with `@AGENTS.md`, so Claude Code loads the rules.

## v0 status

The structure is public, the valuable content is private. The `<< IP Mike >>` zones (boilerplate conventions, story granularity, anti-hallucination heuristics, severity thresholds) are intentionally empty in this version: they receive the proprietary content outside this repo.
