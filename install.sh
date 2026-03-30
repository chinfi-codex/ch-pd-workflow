#!/usr/bin/env bash
set -euo pipefail

FORCE=0
TARGET="codex"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    --target)
      TARGET="${2:-}"
      shift 2
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SOURCE="$SCRIPT_DIR/skills/product-workflow"
TEMP_ROOT=""
REPO_ROOT=""

if [[ -d "$LOCAL_SOURCE" ]]; then
  SOURCE_DIR="$LOCAL_SOURCE"
  REPO_ROOT="$SCRIPT_DIR"
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

mapfile -t SKILL_DIRS < <(get_skill_dirs "$SOURCE_DIR")

if [[ "${#SKILL_DIRS[@]}" -eq 0 ]]; then
  echo "No installable skills found in $SOURCE_DIR." >&2
  exit 1
fi

if [[ "$TARGET" == "opencode" || "$TARGET" == "both" ]] && [[ -z "$REPO_ROOT" ]]; then
  echo "OpenCode target requires running install.sh from a local repository checkout." >&2
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
  opencode_root="$(get_opencode_skills_root "$REPO_ROOT")"
  INSTALL_ROOTS+=("$opencode_root")
  LEGACY_TARGETS+=("")
fi

EXISTING_TARGETS=()
for idx in "${!INSTALL_ROOTS[@]}"; do
  install_root="${INSTALL_ROOTS[$idx]}"
  legacy_target="${LEGACY_TARGETS[$idx]}"
  mkdir -p "$install_root"

  if [[ -n "$legacy_target" && -e "$legacy_target" ]]; then
    EXISTING_TARGETS+=("$legacy_target")
  fi

  for skill_dir in "${SKILL_DIRS[@]}"; do
    skill_name="$(basename "$skill_dir")"
    target_dir="$install_root/$skill_name"
    if [[ -e "$target_dir" ]]; then
      EXISTING_TARGETS+=("$target_dir")
    fi
  done
done

if [[ "${#EXISTING_TARGETS[@]}" -gt 0 ]]; then
  if [[ "$FORCE" -ne 1 ]]; then
    echo "Install target already exists:" >&2
    for target_dir in "${EXISTING_TARGETS[@]}"; do
      echo " - $target_dir" >&2
    done
    echo "Re-run with --force to overwrite the installed version." >&2
    exit 1
  fi
fi

for idx in "${!INSTALL_ROOTS[@]}"; do
  install_root="${INSTALL_ROOTS[$idx]}"
  legacy_target="${LEGACY_TARGETS[$idx]}"

  if [[ -n "$legacy_target" && -e "$legacy_target" ]]; then
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
echo "Installed product-workflow skills to:"
for install_root in "${INSTALL_ROOTS[@]}"; do
  for skill_dir in "${SKILL_DIRS[@]}"; do
    echo "$install_root/$(basename "$skill_dir")"
  done
done
echo
echo "Next steps:"
echo "1. Open Codex and use /ceo, /feature-br, /prd, or /pd-review."
echo "2. If you later modify template files in this repo, run ./sync.sh from the repo root."

if [[ -n "$TEMP_ROOT" && -d "$TEMP_ROOT" ]]; then
  rm -rf "$TEMP_ROOT"
fi
