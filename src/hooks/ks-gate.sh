#!/usr/bin/env bash
# ks-gate — killer-saas repo-level guardrails, enforced by git (tool-independent).
# Works the same whether the harness is Claude Code, Codex or Gemini CLI:
# the gates live in the repo, not in a tool's per-command permissions.
#
# Subcommands:
#   ks-gate plan-validated <id>     exit 0 if docs/plans/<id>.md has `validated: yes`
#   ks-gate ship-allowed  <id>      exit 0 if docs/reviews/<id>.md has `Ship allowed: yes`
#   ks-gate verif-current <id>      exit 0 if docs/verif/<id>.md proves the CURRENT code was verified
#   ks-gate pre-commit              block a code commit on feature/<id> or chore/<id> without a validated plan
#
# There is no push-time gate: /ks-ship squash-merges, so a merged story leaves no merge
# commit to detect client-side. Enforce `ks-gate ship-allowed <id>` in CI / branch protection.
set -euo pipefail

repo_root() { git rev-parse --show-toplevel 2>/dev/null || pwd; }

# Extract the story or chore id from a `feature/<id>` or `chore/<id>` branch name; empty otherwise.
story_id_from_branch() {
  local branch="$1"
  case "$branch" in
    feature/*) printf '%s' "${branch#feature/}" ;;
    chore/*)   printf '%s' "${branch#chore/}" ;;
    *) printf '' ;;
  esac
}

plan_validated() {
  local id="$1" root; root="$(repo_root)"
  local f="$root/docs/plans/$id.md"
  [ -f "$f" ] || { echo "ks-gate: no plan for '$id' (docs/plans/$id.md missing). Run /ks-plan $id — or /ks-chore for a chore." >&2; return 1; }
  if grep -qE '^validated:[[:space:]]*yes[[:space:]]*$' "$f"; then
    return 0
  fi
  echo "ks-gate: plan '$id' not validated (docs/plans/$id.md lacks 'validated: yes'). Validate it via /ks-plan $id." >&2
  return 1
}

ship_allowed() {
  local id="$1" root; root="$(repo_root)"
  local f="$root/docs/reviews/$id.md"
  [ -f "$f" ] || { echo "ks-gate: no review for '$id' (docs/reviews/$id.md missing). Run /ks-review $id." >&2; return 1; }
  if grep -qE '^Ship allowed:[[:space:]]*yes[[:space:]]*$' "$f"; then
    return 0
  fi
  echo "ks-gate: ship blocked for '$id' (docs/reviews/$id.md is not 'Ship allowed: yes')." >&2
  return 1
}

# The implementer records what it ran in docs/verif/<id>.md, with the tree it ran against.
# This says whether that record still describes the committed code: same tree outside docs/.
# docs/ is excluded because the record itself and the plan's ticked checkboxes are written
# after the run — the same carve-out pre_commit() makes for docs-only commits.
verif_current() {
  local id="$1" root; root="$(repo_root)"
  local f="$root/docs/verif/$id.md"
  [ -f "$f" ] || { echo "ks-gate: no verification record for '$id' (docs/verif/$id.md missing). The implementer writes it before the story commit." >&2; return 1; }
  if ! grep -qE '^Verification status:[[:space:]]*complete[[:space:]]*$' "$f"; then
    echo "ks-gate: verification record for '$id' is not complete (docs/verif/$id.md lacks 'Verification status: complete')." >&2
    return 1
  fi
  local tree
  tree="$(sed -n 's/^Tree:[[:space:]]*\([0-9a-f]\{40\}\).*/\1/p' "$f" | head -1)"
  [ -n "$tree" ] || { echo "ks-gate: verification record for '$id' has no valid 'Tree:' line." >&2; return 1; }
  if ! git cat-file -e "$tree^{tree}" 2>/dev/null; then
    echo "ks-gate: tree $tree recorded for '$id' is not in this repository." >&2
    return 1
  fi
  if ! git diff --quiet "$tree" HEAD -- . ':(exclude)docs' 2>/dev/null; then
    echo "ks-gate: code changed after verification for '$id' — the record no longer describes HEAD. Rerun the checks." >&2
    return 1
  fi
  return 0
}

pre_commit() {
  local branch id; branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"
  id="$(story_id_from_branch "$branch")"
  # Not on a story branch → nothing to enforce here.
  [ -n "$id" ] || return 0
  # Any staged path outside docs/ counts as code/config work.
  local code_staged=0 path
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    case "$path" in
      docs/*) : ;;
      *) code_staged=1 ;;
    esac
  done < <(git diff --cached --name-only)
  [ "$code_staged" = 1 ] || return 0
  if ! plan_validated "$id"; then
    echo "ks-gate: refusing code commit on $branch — no validated plan. (docs-only commits are always allowed.)" >&2
    return 1
  fi
  return 0
}

cmd="${1:-}"
case "$cmd" in
  plan-validated)  plan_validated "${2:?story id required}" ;;
  ship-allowed)    ship_allowed   "${2:?story id required}" ;;
  verif-current)   verif_current  "${2:?story id required}" ;;
  pre-commit)      pre_commit ;;
  *)
    echo "usage: ks-gate {plan-validated <id>|ship-allowed <id>|verif-current <id>|pre-commit}" >&2
    exit 2
    ;;
esac
