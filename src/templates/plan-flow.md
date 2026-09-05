---
validated: no
track: flow
---
# Plan — Story <id> (flow)

Branch: `feature/<id>`

There is no separate research file on this track: the verified facts are in this document,
and they were read in the code, not remembered. **Cap this file at ~150 lines.** Two agents
read it afterwards and pay for its length.

## Target story
<recap + acceptance criteria>

## Verified facts
<The story's PREMISE first. A story asserts things — this guard reads that key, this
 function resolves that limit, this screen shows that state. Each assertion opened and
 checked: exact name, signature, location, AND behaviour on the story's own case. A
 function that exists and throws on that case invalidates the premise — say it here, at
 the top: a false premise is the most valuable thing this section can hold, and it gets
 repaired in the story, not patched in a task.

 Then the rest, one line each: the files really involved and their current state, the APIs
 with their exact signatures, the existing tests that will run, the name collisions, the
 traps left by previous stories.

 **Every fact carries its `path:line`.** A fact without one is a guess wearing a fact's
 clothes, and it is exactly what the review exists to catch.>

## Open questions
<What could not be settled, honestly. An honest unknown beats a plausible guess.>

## Escalation check
<The five signals that send this story back to the full pipeline, each answered:
 schema migration · new screen · authorization or tenant-scope change · API contract change
 · dependency added. One yes → stop and say so; this track does not carry it.>

## Tasks (ordered)
1. [ ] <verifiable task>
2. [ ] <verifiable task>

## Run interdicts
<What must NOT change, and what the implementer must not do. One line each, each verifiable
 by the reviewer — an interdict nobody can check is a wish.>

## The point everything turns on
<The one decision this plan stands on, and the two or three places it could be wrong, with
 what each should be compared against. It starts the reviewer's attention; it never bounds it.>

## Files touched
<anticipated list>

## Test strategy
<What to test, at what level. `Test budget` from AGENTS.local.md. Each behaviour, business
 rule or data contract names the test that can fail; a presentational task names its visual
 check instead — never a manufactured component test.>

## Definition of Done
<repo DoD, specialized to the story>
