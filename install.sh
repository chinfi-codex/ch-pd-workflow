#!/usr/bin/env bash
set -euo pipefail

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
fi

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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SOURCE="$SCRIPT_DIR/skills/product-workflow"
TEMP_ROOT=""

if [[ -d "$LOCAL_SOURCE" ]]; then
  SOURCE_DIR="$LOCAL_SOURCE"
else
  TEMP_ROOT="$(mktemp -d)"
  ARCHIVE_URL="https://github.com/chinfi-codex/ch-pd-workflow/archive/refs/heads/main.tar.gz"
  ARCHIVE_PATH="$TEMP_ROOT/repo.tar.gz"
  EXTRACT_DIR="$TEMP_ROOT/repo"

  mkdir -p "$EXTRACT_DIR"
  curl -fsSL "$ARCHIVE_URL" -o "$ARCHIVE_PATH"
  tar -xzf "$ARCHIVE_PATH" -C "$EXTRACT_DIR"
  SOURCE_DIR="$(find "$EXTRACT_DIR" -maxdepth 2 -type d -path '*/skills/product-workflow' | head -n 1)"

  if [[ -z "$SOURCE_DIR" || ! -d "$SOURCE_DIR" ]]; then
    echo "Downloaded repository archive, but could not find skills/product-workflow." >&2
    exit 1
  fi
fi

SKILLS_ROOT="$(get_codex_skills_root)"
mkdir -p "$SKILLS_ROOT"
LEGACY_TARGET_DIR="$SKILLS_ROOT/product-workflow"

mapfile -t SKILL_DIRS < <(get_skill_dirs "$SOURCE_DIR")

if [[ "${#SKILL_DIRS[@]}" -eq 0 ]]; then
  echo "No installable skills found in $SOURCE_DIR." >&2
  exit 1
fi

EXISTING_TARGETS=()
for skill_dir in "${SKILL_DIRS[@]}"; do
  skill_name="$(basename "$skill_dir")"
  target_dir="$SKILLS_ROOT/$skill_name"
  if [[ -e "$target_dir" ]]; then
    EXISTING_TARGETS+=("$target_dir")
  fi
done

if [[ -e "$LEGACY_TARGET_DIR" || "${#EXISTING_TARGETS[@]}" -gt 0 ]]; then
  if [[ "$FORCE" -ne 1 ]]; then
    echo "Install target already exists:" >&2
    if [[ -e "$LEGACY_TARGET_DIR" ]]; then
      echo " - $LEGACY_TARGET_DIR" >&2
    fi
    for target_dir in "${EXISTING_TARGETS[@]}"; do
      echo " - $target_dir" >&2
    done
    echo "Re-run with --force to overwrite the installed version." >&2
    exit 1
  fi
fi

if [[ -e "$LEGACY_TARGET_DIR" ]]; then
  rm -rf "$LEGACY_TARGET_DIR"
fi

for target_dir in "${EXISTING_TARGETS[@]}"; do
  rm -rf "$target_dir"
done

for skill_dir in "${SKILL_DIRS[@]}"; do
  skill_name="$(basename "$skill_dir")"
  target_dir="$SKILLS_ROOT/$skill_name"
  cp -R "$skill_dir" "$target_dir"
done

echo
echo "Installed product-workflow skills to:"
for skill_dir in "${SKILL_DIRS[@]}"; do
  echo "$SKILLS_ROOT/$(basename "$skill_dir")"
done
echo
echo "Next steps:"
echo "1. Open Codex and use /ceo, /feature-br, /prd, or /pd-review."
echo "2. If you later modify template files in this repo, run ./sync.sh from the repo root."

if [[ -n "$TEMP_ROOT" && -d "$TEMP_ROOT" ]]; then
  rm -rf "$TEMP_ROOT"
fi
