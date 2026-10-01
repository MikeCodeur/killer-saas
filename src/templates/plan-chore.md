---
validated: no
track: chore
---
# Plan — Chore <id>

Branch: `chore/<id>`

**Cap this file at ~80 lines.** A chore changes no product behavior; its plan says what is
delivered, what is touched, and how it is checked — nothing more.

## Goal
<One sentence: the request, as the human made it.>

## Done when
<The measurable end of the work, checked before landing. Not "the docs are written" but
 "each of the 38 guides covers <journey> with <a worked example>"; not "the suite is
 cleaner" but "<before> → <after> tests, every delete citing its covering test".>

## Files
<The closed list of files and directories this chore may touch. Anything outside it is a
 deviation, reported, never done silently.>

## Escalation check
<Each answered: product code that changes behavior · schema migration · authorization ·
 API contract · business rule · runtime dependency added or upgraded. One yes → this is a
 story, not a chore.>

## Verification
<Exactly what runs, once, and why it is enough for what changes — e.g. compile the touched
 content files and check their links; lint the touched config. Never the full suite or the
 end-to-end run unless this chore is about them.>

## Tasks (ordered)
1. [ ] <verifiable task>
