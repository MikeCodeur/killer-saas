#!/usr/bin/env bash
# ks-gate — killer-saas repo-level guardrails, enforced by git (tool-independent).
# Works the same whether the harness is Claude Code, Codex or Gemini CLI:
# the gates live in the repo, not in a tool's per-command permissions.
#
# Subcommands:
#   ks-gate plan-validated <id>     exit 0 if docs/plans/<id>.md has `validated: yes`
#   ks-gate ship-allowed  <id>      exit 0 if docs/reviews/<id>.md has `Ship allowed: yes`
#   ks-gate pre-commit              block a code commit on feature/<id> without a validated plan
#   ks-gate pre-push                block pushing to the default branch a merged story without a passed review
set -euo pipefail

repo_root() { git rev-parse --show-toplevel 2>/dev/null || pwd; }

# Extract the story id from a `feature/<id>` branch name; empty otherwise.
story_id_from_branch() {
  local branch="$1"
  case "$branch" in
    feature/*) printf '%s' "${branch#feature/}" ;;
    *) printf '' ;;
  esac
}

plan_validated() {
  local id="$1" root; root="$(repo_root)"
  local f="$root/docs/plans/$id.md"
  [ -f "$f" ] || { echo "ks-gate: no plan for '$id' (docs/plans/$id.md missing). Run /ks-plan $id." >&2; return 1; }
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

# Default branch name (from origin/HEAD, else main). Client-side MERGE_HEAD/MERGE_MSG
# are unreliable at merge-hook time, so the ship gate runs at push time and reads the
# already-written merge-commit messages instead — those are reliable committed history.
default_branch() {
  git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' \
    || true
}

pre_push() {
  local def; def="$(default_branch)"; [ -n "$def" ] || def="main"
  local local_ref local_sha remote_ref remote_sha rc=0 zero="0000000000000000000000000000000000000000"
  while read -r local_ref local_sha remote_ref remote_sha; do
    [ "$remote_ref" = "refs/heads/$def" ] || continue        # only gate the default branch
    [ "$local_sha" != "$zero" ] || continue                  # branch deletion
    local range
    if printf '%s' "$remote_sha" | grep -qE '^0+$'; then
      range="$local_sha"                                     # new remote branch
    else
      range="$remote_sha..$local_sha"                        # only the newly pushed commits
    fi
    local id
    while IFS= read -r id; do
      [ -n "$id" ] || continue
      if ! ship_allowed "$id"; then
        echo "ks-gate: refusing to push $remote_ref — story '$id' was merged without a passed review." >&2
        rc=1
      fi
    done < <(git log --merges --format='%s' "$range" 2>/dev/null \
              | sed -n "s/.*Merge branch '\\(feature\\/[^']*\\)'.*/\\1/p" \
              | sed 's#^feature/##' | sort -u)
  done
  return "$rc"
}

cmd="${1:-}"
case "$cmd" in
  plan-validated)  plan_validated "${2:?story id required}" ;;
  ship-allowed)    ship_allowed   "${2:?story id required}" ;;
  pre-commit)      pre_commit ;;
  pre-push)        pre_push ;;
  *)
    echo "usage: ks-gate {plan-validated <id>|ship-allowed <id>|pre-commit|pre-push}" >&2
    exit 2
    ;;
esac
