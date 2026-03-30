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

get_skill_dirs() {
  find "$1" -mindepth 1 -maxdepth 1 -type d -exec test -f '{}/SKILL.md' ';' -print
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
mkdir -p "$SKILLS_ROOT"
LEGACY_TARGET_DIR="$SKILLS_ROOT/product-workflow"
rm -rf "$LEGACY_TARGET_DIR"

mapfile -t SKILL_DIRS < <(get_skill_dirs "$SOURCE_DIR")

if [[ "${#SKILL_DIRS[@]}" -eq 0 ]]; then
  echo "No installable skills found in $SOURCE_DIR." >&2
  exit 1
fi

for skill_dir in "${SKILL_DIRS[@]}"; do
  skill_name="$(basename "$skill_dir")"
  target_dir="$SKILLS_ROOT/$skill_name"
  rm -rf "$target_dir"
  cp -R "$skill_dir" "$target_dir"
done

echo
echo "Rebuilt and synced product-workflow skills to:"
for skill_dir in "${SKILL_DIRS[@]}"; do
  echo "$SKILLS_ROOT/$(basename "$skill_dir")"
done
