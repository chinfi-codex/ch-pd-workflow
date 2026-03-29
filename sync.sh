#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skills/product-workflow"
BUILD_SCRIPT="$SOURCE_DIR/scripts/build-all.sh"

get_codex_skills_root() {
  if [[ -n "${CODEX_HOME:-}" ]]; then
    printf '%s\n' "$CODEX_HOME/skills"
    return
  fi

  if [[ -z "${HOME:-}" ]]; then
    echo "Cannot resolve HOME. Set CODEX_HOME or HOME and try again." >&2
    exit 1
  fi

  printf '%s\n' "$HOME/.codex/skills"
}

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Cannot find skills/product-workflow in this repository." >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is required to regenerate SKILL.md. Install Node.js and try again." >&2
  exit 1
fi

bash "$BUILD_SCRIPT"

SKILLS_ROOT="$(get_codex_skills_root)"
TARGET_DIR="$SKILLS_ROOT/product-workflow"
mkdir -p "$SKILLS_ROOT"
rm -rf "$TARGET_DIR"
cp -R "$SOURCE_DIR" "$TARGET_DIR"

echo
echo "Rebuilt and synced product-workflow to:"
echo "$TARGET_DIR"
