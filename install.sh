#!/usr/bin/env bash
set -euo pipefail

# killer-saas installer
#
# Usage :
#   ./install.sh              Scope projet (défaut) : ./.claude + ./templates + AGENTS.md/CLAUDE.md
#   ./install.sh --global     Scope global : tooling dans ~/.claude, payload caché dans ~/.claude/killer-saas
#   ./install.sh init         Pose templates + rules dans le projet courant (pour les installs globales)
#   ./install.sh update       Met à jour le tooling + templates du projet courant (préserve tes modifs)
#   --force                    En complément d'un mode : écrase aussi les templates modifiés localement
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

# --- Arguments : mode + --force ---
FORCE=0
MODE=""
for a in "$@"; do
  case "$a" in
    -f|--force) FORCE=1 ;;
    *) MODE="$a" ;;
  esac
done

# Supprime les fichiers posés par une install précédente (listés dans .ks-manifest) — jamais rien d'autre.
clean_tooling() {
  local dest="$1" line
  [ -f "$dest/.ks-manifest" ] || return 0
  while IFS= read -r line; do
    case "$line" in
      commands/*|skills/*|agents/*) rm -rf "$dest/$line" ;;
    esac
  done < "$dest/.ks-manifest"
}

copy_tooling() {
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

# Copie un template seulement s'il est absent ou non modifié localement (référence : .claude/.ks-templates.orig).
sync_templates() {
  local payload="$1" orig="./.claude/.ks-templates.orig" f name
  mkdir -p ./templates "$orig"
  for f in "$payload/templates/"*; do
    name="$(basename "$f")"
    if [ ! -f "./templates/$name" ]; then
      cp "$f" "./templates/$name"; cp "$f" "$orig/$name"
    elif [ -f "$orig/$name" ] && cmp -s "./templates/$name" "$orig/$name"; then
      cp "$f" "./templates/$name"; cp "$f" "$orig/$name"
    elif cmp -s "./templates/$name" "$f"; then
      cp "$f" "$orig/$name"
    elif [ "$FORCE" = 1 ]; then
      cp "$f" "./templates/$name"; cp "$f" "$orig/$name"
      echo "↻  templates/$name écrasé (--force)."
    else
      echo "⚠  templates/$name modifié localement — non écrasé (relance avec --force pour l'écraser)."
    fi
  done
}

drop_project_payload() {
  local payload="$1"   # dossier contenant templates/ + AGENTS.md
  sync_templates "$payload"
  if [ -f ./AGENTS.md ]; then
    echo "⚠  ./AGENTS.md existe déjà — non écrasé. Fusionne les rules killer-saas à la main si besoin."
  else
    cp "$payload/AGENTS.md" ./AGENTS.md
  fi
  # CLAUDE.md doit importer AGENTS.md (pour que Claude Code charge les rules)
  if [ -f ./CLAUDE.md ]; then
    grep -qxF '@AGENTS.md' ./CLAUDE.md || printf '\n@AGENTS.md\n' >> ./CLAUDE.md
  else
    printf '@AGENTS.md\n' > ./CLAUDE.md
  fi
}

case "$MODE" in
  ""|--project)
    copy_tooling "./.claude"
    drop_project_payload "$SRC"
    echo "✅ killer-saas installé (scope projet, version $VERSION). Commandes : /ks-prd … /ks-ship"
    ;;

  -g|--global)
    copy_tooling "$HOME/.claude"
    mkdir -p "$CACHE"
    cp -R "$SRC/templates" "$CACHE/"
    cp "$SRC/AGENTS.md" "$CACHE/"
    cp "$PAYLOAD_ROOT/install.sh" "$CACHE/install.sh" 2>/dev/null \
      || cp "${BASH_SOURCE[0]:-$0}" "$CACHE/install.sh" 2>/dev/null || true
    echo "✅ Tooling killer-saas installé (global, version $VERSION). Commandes dispo dans tous tes repos."
    echo "→ Dans chaque projet : ~/.claude/killer-saas/install.sh init"
    ;;

  init)
    if [ -d "$SRC/templates" ]; then
      drop_project_payload "$SRC"
    else
      drop_project_payload "$CACHE"
    fi
    echo "✅ templates + rules ajoutés à $(pwd)"
    ;;

  update)
    copy_tooling "./.claude"
    if [ -d "$SRC/templates" ]; then
      sync_templates "$SRC"
    else
      sync_templates "$CACHE"
    fi
    echo "✅ killer-saas mis à jour (version $VERSION). AGENTS.md jamais touché — fusionne à la main si les rules ont évolué."
    ;;

  *)
    echo "Option inconnue : $MODE" >&2
    echo "Usage : ./install.sh [--global | init | update] [--force]" >&2
    exit 1
    ;;
esac
