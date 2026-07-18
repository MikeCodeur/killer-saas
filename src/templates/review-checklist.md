# Review — Story <id>

> Fresh-context review. Each issue classified: critical / major / minor.
> Diff reviewed: `git diff <default-branch>...feature/<id>`

## Plan compliance
- [ ] The code does what the plan specifies, nothing more

## Anti-hallucination
- [ ] No invented API/function/import (each one opened and verified)
- [ ] No plausible-but-wrong value or logic
- [ ] The code matches what it claims to do

## Rules compliance
- [ ] Repo conventions followed (AGENTS.md)

## Tests
- [ ] Test suite run by the reviewer, passing
- [ ] Assertions pin the acceptance criteria (no assertion-free tests)

## Regressions
- [ ] No impact on existing code paths

## Findings
<one line per issue: severity — file — what's wrong>

## Verdict
Max severity: <critical | major | minor | none>
Ship allowed: <yes | no>

<< IP Mike: hallucination detection heuristics, false positive/negative examples. >>
