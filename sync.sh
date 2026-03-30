#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skills/product-workflow"
BUILD_SCRIPT="$SOURCE_DIR/scripts/build-all.sh"
TARGET="codex"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    --force)
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

case "$TARGET" in
  codex|opencode|both) ;;
  *)
    echo "Invalid --target value: $TARGET" >&2
    exit 1
    ;;
esac

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

get_opencode_skills_root() {
  printf '%s\n' "$1/.opencode/skills"
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

mapfile -t SKILL_DIRS < <(get_skill_dirs "$SOURCE_DIR")

if [[ "${#SKILL_DIRS[@]}" -eq 0 ]]; then
  echo "No installable skills found in $SOURCE_DIR." >&2
  exit 1
fi

INSTALL_ROOTS=()
LEGACY_TARGETS=()

if [[ "$TARGET" == "codex" || "$TARGET" == "both" ]]; then
  codex_root="$(get_codex_skills_root)"
  INSTALL_ROOTS+=("$codex_root")
  LEGACY_TARGETS+=("$codex_root/product-workflow")
fi

if [[ "$TARGET" == "opencode" || "$TARGET" == "both" ]]; then
  opencode_root="$(get_opencode_skills_root "$SCRIPT_DIR")"
  INSTALL_ROOTS+=("$opencode_root")
  LEGACY_TARGETS+=("")
fi

for idx in "${!INSTALL_ROOTS[@]}"; do
  install_root="${INSTALL_ROOTS[$idx]}"
  legacy_target="${LEGACY_TARGETS[$idx]}"
  mkdir -p "$install_root"

  if [[ -n "$legacy_target" ]]; then
    rm -rf "$legacy_target"
  fi

  for skill_dir in "${SKILL_DIRS[@]}"; do
    skill_name="$(basename "$skill_dir")"
    target_dir="$install_root/$skill_name"
    rm -rf "$target_dir"
    cp -R "$skill_dir" "$target_dir"
  done
done

echo
echo "Rebuilt and synced product-workflow skills to:"
for install_root in "${INSTALL_ROOTS[@]}"; do
  for skill_dir in "${SKILL_DIRS[@]}"; do
    echo "$install_root/$(basename "$skill_dir")"
  done
done
