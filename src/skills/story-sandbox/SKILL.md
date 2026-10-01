---
name: story-sandbox
description: The isolated runtime of a story worktree — its own port, its database, its environment files, and the end-to-end run against them. Loaded by the commands that bootstrap a worktree, preloaded in the implementer and the reviewer.
---
# Story sandbox

A story lives in its worktree. It must also live on **its** port and in **its** database:
otherwise two stories step on each other, and the symptoms never look like their cause — a
login that works then a `Failed to fetch`, a test reading data another agent wrote, a server
still serving a stale build.

The project-specific values come from `AGENTS.local.md`: `Sandbox port base`,
`Sandbox URL vars`, `Sandbox schema`, `Sandbox reset`. A setting at `—` is one this project
does not have: say so, never guess one.

## The convention

| Element | Rule | `s179-use-admin`, port base 3000 |
| --- | --- | --- |
| Branch | `feature/<id>` | `feature/s179-use-admin` |
| Worktree | `.worktrees/<id>` | `.worktrees/s179-use-admin` |
| Port | `Sandbox port base` + story number | `3179` (`s04` → `3004`) |
| Database | `<repo>_dev` by default, `<repo>_<id_snake>` when the story needs its own | `myapp_s179_use_admin` |

The port derives from the story number, so two stories never share one and nobody asks
"which port is free?". **Never pick another port because this one was taken** — free it
instead (step 6): every URL variable points at the derived port, and a server elsewhere makes
them lie.

## 1. Environment files

A new worktree has no `.env*`: they are gitignored. Copy them from the repository base before
anything else — including `.env.production` when it exists, since a production build reads it
even locally. Report the names, never the values.

**Never symlink `node_modules`** to the base directory: some bundlers refuse to start on a path
outside their root, and neither the dev server nor the build can run. Install for real, from the
lockfile.

## 2. Database: reuse before creating

The name always carries the repository as prefix: one local Postgres serves several projects,
and a database called `dev` is a collision waiting to happen.

**Default: the shared `<repo>_dev`.** One database per story is ten databases to seed, migrate
and forget, for work that mostly never touches the schema. Create a dedicated one in two cases
only:

1. **The story changes the schema** — a path under `Sandbox schema` appears in
   `git diff <default-branch>...HEAD --name-only`. A migration applied to the shared database
   breaks every other branch. Check it, don't guess it.
2. **Another agent is already using the shared one** — two concurrent resets on the same
   database and both sessions test data they did not write.

A dedicated database is created locally, with the extensions the project's migrations expect
installed before the first migration.

## 3. Point the environment — in the worktree's own files

In the worktree's environment files, never in a shared one:

- the database URL, on the database chosen in step 2;
- **every variable listed in `Sandbox URL vars`, on the story's port.** They go together: an
  auth or app URL on another port breaks client calls without a clear message, and a list of
  trusted origins inherited from another worktree's file silently excludes the current port.

**Check `.env.test` too.** It is copied with the others and often forgotten: it may point at a
remote database, or carry another story's settings that switch on tests unrelated to this one.

## 4. Before any destructive command

Reset, clear, migrate or seed — first read the database URL the command will use and prove:

- the host is local (`localhost`, `127.0.0.1`, or a verified local socket);
- the database name is exactly the one chosen in step 2.

Remote, production, preview, ambiguous, or the base checkout's own development database →
refuse. On the shared database a reset is visible to every worktree using it: announce it,
never run it in the middle of another agent's test.

Then `Sandbox reset`. Test accounts come from the seed, never from invention — read them from
the project's conventions or from the database. Never a real account.

## 5. Run

Start the server on the story's port, then tell the human the five facts together: **URL, port,
worktree, branch, database**. The URL alone does not reveal that the wrong story is being tested.

## 6. End-to-end

End-to-end tests run against a **production build**, served on the story's port: values baked
in at build time point at the port the build was made for, and a build served elsewhere holds on
screen and vanishes on reload, without an error.

Before running: nothing else listening on the port. A server that fails on `EADDRINUSE` fails
silently while the old process keeps serving a stale build — kill the listener on the story's
port first. `.env.test` pointing at a remote database → do not run.

Specs that sign up create rows on every run; `Sandbox reset` puts the database back.

## 7. Clean up

At the end of a test session, stop the listener on the story's port. A dedicated database is
dropped with its branch, when the story ships; **never drop `<repo>_dev`**, other worktrees use
it. Never stop the Postgres service itself: it is shared, only the databases are isolated.

## Never

- Two worktrees on the same port.
- A destructive command without reading the database URL right before.
- A shared environment file edited to rescue one story.
- A port picked "because the other one was taken".
