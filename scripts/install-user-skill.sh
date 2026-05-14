#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
DRY_RUN=0
FORCE=0
SELECTED=0
INSTALL_CODEX=0
INSTALL_CLAUDE=0
INSTALL_CURSOR=0

usage() {
  cat <<'USAGE'
Usage: scripts/install-user-skill.sh [--all] [--codex] [--claude] [--cursor] [--dry-run] [--force]

Installs the current use-scop checkout into user-level Agent Skills directories:
  Codex:       ${CODEX_HOME:-$HOME/.codex}/skills/use-scop
  Claude Code: $HOME/.claude/skills/use-scop
  Cursor:      $HOME/.cursor/skills/use-scop

By default, installs to all three targets. Existing targets are skipped unless --force is used.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --all)
      SELECTED=1
      INSTALL_CODEX=1
      INSTALL_CLAUDE=1
      INSTALL_CURSOR=1
      ;;
    --codex)
      SELECTED=1
      INSTALL_CODEX=1
      ;;
    --claude)
      SELECTED=1
      INSTALL_CLAUDE=1
      ;;
    --cursor)
      SELECTED=1
      INSTALL_CURSOR=1
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    --force)
      FORCE=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$SELECTED" -eq 0 ]]; then
  INSTALL_CODEX=1
  INSTALL_CLAUDE=1
  INSTALL_CURSOR=1
fi

abs_path() {
  realpath -m "$1"
}

copy_skill() {
  local target="$1"
  local source_abs
  local target_abs
  local target_parent
  local entries

  source_abs="$(abs_path "$SOURCE_DIR")"
  target_abs="$(abs_path "$target")"
  target_parent="$(dirname "$target_abs")"

  if [[ "$target_abs" == "$source_abs" ]]; then
    echo "SKIP same directory: $target_abs"
    return 0
  fi

  if [[ -e "$target_abs" && "$FORCE" -eq 0 ]]; then
    echo "SKIP existing target: $target_abs"
    echo "     Re-run with --force to replace it."
    return 0
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ -e "$target_abs" ]]; then
      echo "DRY-RUN replace: $target_abs"
    else
      echo "DRY-RUN install: $target_abs"
    fi
    return 0
  fi

  mkdir -p "$target_parent"

  if [[ -e "$target_abs" ]]; then
    rm -rf "$target_abs"
  fi

  mkdir -p "$target_abs"

  entries=(
    "SKILL.md"
    "task_router.yaml"
    "README.md"
    "README.zh-CN.md"
    "TESTING.md"
    "agents"
    "scripts"
  )

  for entry in "${entries[@]}"; do
    if [[ -e "$SOURCE_DIR/$entry" ]]; then
      cp -a "$SOURCE_DIR/$entry" "$target_abs/"
    fi
  done

  echo "Installed: $target_abs"
}

if [[ "$INSTALL_CODEX" -eq 1 ]]; then
  copy_skill "${CODEX_HOME:-$HOME/.codex}/skills/use-scop"
fi

if [[ "$INSTALL_CLAUDE" -eq 1 ]]; then
  copy_skill "$HOME/.claude/skills/use-scop"
fi

if [[ "$INSTALL_CURSOR" -eq 1 ]]; then
  copy_skill "$HOME/.cursor/skills/use-scop"
fi
