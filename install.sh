#!/usr/bin/env bash
set -euo pipefail

# killer-saas installer
#
# Usage :
#   ./install.sh                       Projet (défaut), cible Claude Code
#   ./install.sh --target codex        Projet, cible Codex (.codex/skills + AGENTS.md)
#   ./install.sh --target all          Projet, Claude + Codex
#   ./install.sh --global              Global Claude (~/.claude) — commandes dans tous les repos
#   ./install.sh --global --target codex   Global Codex (~/.codex/skills)
#   ./install.sh --global --target all      Global Claude + Codex
#   ./install.sh init [--target …]     Pose templates + rules dans le projet (après un global)
#   ./install.sh update [--target …]   Met à jour le tooling + templates (préserve tes modifs)
#   ./install.sh --check               Liste les fichiers installés modifiés localement (rien n'est écrit)
#   --hooks                            Pose les git hooks d'enforcement (opt-in, réversible)
#   --force                            Écrase aussi les templates modifiés localement
#
# Deux portées, pour chaque cible : projet (dans le repo courant) ou global (--global).
#
# curl -fsSL https://raw.githubusercontent.com/MikeCodeur/killer-saas/main/install.sh | bash

REPO="https://github.com/MikeCodeur/killer-saas.git"

# --- Résolution du payload (src/) : fichiers locaux, sinon clone (cas curl|bash) ---
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [ -n "${SELF_DIR:-}" ] && [ -f "$SELF_DIR/src/commands/ks-prd.md" ]; then
  SRC="$SELF_DIR/src"
  PAYLOAD_ROOT="$SELF_DIR"
else
  TMP="$(mktemp -d)"
  echo "→ Récupération de killer-saas…"
  git clone --depth 1 "$REPO" "$TMP" >/dev/null 2>&1
  SRC="$TMP/src"
  PAYLOAD_ROOT="$TMP"
fi

VERSION="$(git -C "$PAYLOAD_ROOT" rev-parse --short HEAD 2>/dev/null || date +%Y-%m-%d)"
CACHE="$HOME/.claude/killer-saas"
ORIG="./.killer-saas/templates.orig"   # baseline templates (tool-neutral), for local-edit detection

# --- Arguments : mode + --target + --hooks + --force ---
FORCE=0; HOOKS=0; TARGET="claude"; MODE=""
while [ $# -gt 0 ]; do
  case "$1" in
    -f|--force)   FORCE=1 ;;
    --hooks)      HOOKS=1 ;;
    --check)      MODE="check" ;;
    --target)     TARGET="${2:-}"; shift ;;
    --target=*)   TARGET="${1#--target=}" ;;
    *)            MODE="$1" ;;
  esac
  shift
done

# Supprime les fichiers posés par une install précédente (listés dans .ks-manifest) — jamais rien d'autre.
clean_tooling() {
  local dest="$1" line
  [ -f "$dest/.ks-manifest" ] || return 0
  while IFS= read -r line; do
    case "$line" in
      commands/*|skills/*|agents/*|prompts/*) rm -rf "$dest/$line" ;;
    esac
  done < "$dest/.ks-manifest"
}

# Claude : copie verbatim (pas de build, pas de Node — chemin quotidien).
copy_tooling_claude() {
  local dest="$1" f
  clean_tooling "$dest"
  mkdir -p "$dest/commands" "$dest/skills" "$dest/agents"
  cp -R "$SRC/commands/." "$dest/commands/"
  cp -R "$SRC/skills/."   "$dest/skills/"
  cp -R "$SRC/agents/."   "$dest/agents/"
  : > "$dest/.ks-manifest"
  for f in "$SRC/commands/"*.md; do echo "commands/$(basename "$f")" >> "$dest/.ks-manifest"; done
  for f in "$SRC/skills/"*/;     do echo "skills/$(basename "$f")"   >> "$dest/.ks-manifest"; done
  for f in "$SRC/agents/"*.md;   do echo "agents/$(basename "$f")"   >> "$dest/.ks-manifest"; done
  echo "$VERSION" > "$dest/.ks-version"
}

# Codex : transforme via le build Node → .codex/skills.
copy_tooling_codex() {
  local dest="$1" stg d
  command -v node >/dev/null 2>&1 || { echo "✗ Node requis pour la cible codex (build md→skills)." >&2; return 1; }
  stg="$(mktemp -d)"
  node "$PAYLOAD_ROOT/bin/ks-build.mjs" --target codex --src "$SRC" --out "$stg" >/dev/null
  clean_tooling "$dest"
  mkdir -p "$dest"
  cp -R "$stg/." "$dest/"
  : > "$dest/.ks-manifest"
  for d in "$dest/skills/"*/; do echo "skills/$(basename "$d")" >> "$dest/.ks-manifest"; done
  echo "$VERSION" > "$dest/.ks-version"
  rm -rf "$stg"
}

# Copie un template seulement s'il est absent ou non modifié localement (baseline : $ORIG).
sync_templates() {
  local payload="$1" f name
  mkdir -p ./templates "$ORIG"
  for f in "$payload/templates/"*; do
    name="$(basename "$f")"
    if [ ! -f "./templates/$name" ]; then
      cp "$f" "./templates/$name"; cp "$f" "$ORIG/$name"
    elif [ -f "$ORIG/$name" ] && cmp -s "./templates/$name" "$ORIG/$name"; then
      cp "$f" "./templates/$name"; cp "$f" "$ORIG/$name"
    elif cmp -s "./templates/$name" "$f"; then
      cp "$f" "$ORIG/$name"
    elif [ "$FORCE" = 1 ]; then
      cp "$f" "./templates/$name"; cp "$f" "$ORIG/$name"
      echo "↻  templates/$name écrasé (--force)."
    else
      echo "⚠  templates/$name modifié localement — non écrasé (relance avec --force pour l'écraser)."
    fi
  done
}

# Le dépôt killer-saas lui-même n'est pas un projet : son AGENTS.md racine porte les règles de
# maintenance de la méthode, pas celles du pipeline. Ne jamais l'écraser en s'auto-installant.
is_method_repo() { [ -f ./src/commands/ks-prd.md ] && [ -f ./install.sh ]; }

# AGENTS.local.md appartient au projet : posé une fois s'il est absent, jamais réécrit.
seed_agents_local() {
  local payload="$1"
  is_method_repo && return 0
  [ -f ./AGENTS.local.md ] && return 0
  cp "$payload/templates/agents-local.md" ./AGENTS.local.md
  echo "→ ./AGENTS.local.md créé (réglages par défaut). Ajuste-le, ou lance /ks-setup."
}

# AGENTS.md appartient à la méthode : réécrit à chaque install, avec AGENTS.local.md concaténé.
# Concaténation et pas import : Codex ne résout pas `@fichier` (openai/codex#17401), il empile
# un AGENTS.md par répertoire. Un seul mécanisme pour les deux cibles.
assemble_agents_md() {
  local payload="$1"
  if is_method_repo; then
    echo "· dépôt méthode : AGENTS.md racine laissé intact (règles de maintenance, pas d'install)."
    return 0
  fi
  cat "$payload/AGENTS.md" > ./AGENTS.md
  if [ -f ./AGENTS.local.md ]; then
    printf '\n---\n\n' >> ./AGENTS.md
    cat ./AGENTS.local.md >> ./AGENTS.md
  fi
}
wire_claude_md() {
  if [ -f ./CLAUDE.md ]; then
    grep -qxF '@AGENTS.md' ./CLAUDE.md || printf '\n@AGENTS.md\n' >> ./CLAUDE.md
  else
    printf '@AGENTS.md\n' > ./CLAUDE.md
  fi
}

# Enforcement repo-level : hooks git (opt-in, réversible). Indépendant de l'outil.
install_hooks() {
  command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1 || {
    echo "⚠  Pas un repo git — hooks non posés. (git init puis ./install.sh --hooks)"; return 0; }
  mkdir -p ./.ks-hooks
  cp "$SRC/hooks/ks-gate.sh" "$SRC/hooks/pre-commit" ./.ks-hooks/
  chmod +x ./.ks-hooks/ks-gate.sh ./.ks-hooks/pre-commit
  git config core.hooksPath .ks-hooks
  echo "✅ Git hooks posés (core.hooksPath=.ks-hooks). Gate : pas de code sans plan validé."
  echo "   Le gate de ship (ks-gate ship-allowed <id>) se pose en CI / branch protection."
  echo "   Désactiver : git config --unset core.hooksPath"
}

# --check : compare l'installé au payload, via .ks-manifest. N'écrit rien.
# Une commande éditée localement est perdue au prochain install — autant le savoir avant.
check_drift() {
  local dest="$1" payload="$2" label="$3" line drifted=0 src_path
  [ -d "$dest" ] || return 0
  if [ ! -f "$dest/.ks-manifest" ]; then
    echo "· $label : pas de manifeste (installé par une version antérieure)."; return 0
  fi
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    src_path="$payload/$line"
    if [ ! -e "$src_path" ]; then
      echo "  + $line — n'existe plus dans la méthode (retiré au prochain install)"; drifted=1
    elif [ ! -e "$dest/$line" ]; then
      echo "  ✗ $line — supprimé localement"; drifted=1
    elif ! diff -rq "$src_path" "$dest/$line" >/dev/null 2>&1; then
      echo "  ✎ $line — modifié localement (sera écrasé au prochain install)"; drifted=1
    fi
  done < "$dest/.ks-manifest"
  if [ "$drifted" = 0 ]; then
    echo "✅ $label : conforme à la méthode."
  else
    echo "⚠  $label : remonte ces changements dans src/ de killer-saas, ou tu les perdras."
  fi
}

install_target() {
  case "$1" in
    claude)
      copy_tooling_claude "./.claude"
      sync_templates "$SRC"; seed_agents_local "$SRC"; assemble_agents_md "$SRC"; wire_claude_md
      echo "✅ killer-saas installé (Claude, projet, version $VERSION). Commandes : /ks-prd … /ks-ship" ;;
    codex)
      copy_tooling_codex "./.codex"
      sync_templates "$SRC"; seed_agents_local "$SRC"; assemble_agents_md "$SRC"   # AGENTS.md natif Codex, pas de CLAUDE.md
      echo "✅ killer-saas installé (Codex, projet, version $VERSION). Skills : ks-prd … ks-ship dans .codex/skills." ;;
    all)
      install_target claude
      install_target codex ;;
    *)
      echo "Cible inconnue : $1 (claude|codex|all)" >&2; exit 1 ;;
  esac
}

case "$MODE" in
  ""|--project)
    install_target "$TARGET"
    if [ "$HOOKS" = 1 ]; then install_hooks; fi
    ;;

  -g|--global)
    # Cache partagé (templates + AGENTS.md + installeur) pour `init` par projet.
    seed_cache() {
      mkdir -p "$CACHE"
      cp -R "$SRC/templates" "$CACHE/"
      cp "$SRC/AGENTS.md" "$CACHE/"
      cp "$PAYLOAD_ROOT/install.sh" "$CACHE/install.sh" 2>/dev/null \
        || cp "${BASH_SOURCE[0]:-$0}" "$CACHE/install.sh" 2>/dev/null || true
    }
    case "$TARGET" in
      claude)
        copy_tooling_claude "$HOME/.claude"; seed_cache
        echo "✅ Tooling installé (global Claude, version $VERSION). Commandes dans tous tes repos." ;;
      codex)
        copy_tooling_codex "$HOME/.codex"; seed_cache
        echo "✅ Tooling installé (global Codex, version $VERSION). Skills dans ~/.codex/skills." ;;
      all)
        copy_tooling_claude "$HOME/.claude"; copy_tooling_codex "$HOME/.codex"; seed_cache
        echo "✅ Tooling installé (global Claude + Codex, version $VERSION)." ;;
      *) echo "Cible inconnue : $TARGET (claude|codex|all)" >&2; exit 1 ;;
    esac
    echo "→ Dans chaque projet : ~/.claude/killer-saas/install.sh init [--target codex] [--hooks]"
    ;;

  init)
    # Après un --global : pose les fichiers PROJET (templates + rules), sans retoucher au tooling
    # déjà installé globalement. C'est la seule différence avec le mode projet.
    local_src="$SRC"; [ -d "$local_src/templates" ] || local_src="$CACHE"
    sync_templates "$local_src"; seed_agents_local "$local_src"; assemble_agents_md "$local_src"
    case "$TARGET" in claude|all) wire_claude_md ;; esac   # CLAUDE.md seulement si Claude est cible
    echo "✅ templates + rules ajoutés à $(pwd) (cible $TARGET)"
    if [ "$HOOKS" = 1 ]; then install_hooks; fi
    ;;

  update)
    install_target "$TARGET"
    echo "✅ killer-saas mis à jour ($TARGET, version $VERSION). AGENTS.md jamais touché — fusionne à la main si les rules ont évolué."
    if [ "$HOOKS" = 1 ]; then install_hooks; fi
    ;;

  check)
    check_drift "./.claude" "$SRC" "Claude (.claude)"
    # Codex : l'installé est transformé au build, donc incomparable au payload brut.
    # On régénère la sortie attendue et on compare à ça.
    if [ -d ./.codex ]; then
      if command -v node >/dev/null 2>&1 && [ -f "$PAYLOAD_ROOT/bin/ks-build.mjs" ]; then
        stg="$(mktemp -d)"
        node "$PAYLOAD_ROOT/bin/ks-build.mjs" --target codex --src "$SRC" --out "$stg" >/dev/null
        check_drift "./.codex" "$stg" "Codex (.codex)"
        rm -rf "$stg"
      else
        echo "· Codex (.codex) : non vérifiable ici (node ou bin/ks-build.mjs absent)."
      fi
    fi
    ;;

  *)
    echo "Option inconnue : $MODE" >&2
    echo "Usage : ./install.sh [--target claude|codex|all] [--hooks] [--global | init | update] [--force]" >&2
    exit 1
    ;;
esac
