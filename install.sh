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
TARGET_DIR="$SKILLS_ROOT/product-workflow"
mkdir -p "$SKILLS_ROOT"

if [[ -e "$TARGET_DIR" ]]; then
  if [[ "$FORCE" -ne 1 ]]; then
    echo "Target already exists: $TARGET_DIR" >&2
    echo "Re-run with --force to overwrite the installed version." >&2
    exit 1
  fi
  rm -rf "$TARGET_DIR"
fi

cp -R "$SOURCE_DIR" "$TARGET_DIR"

echo
echo "Installed product-workflow to:"
echo "$TARGET_DIR"
echo
echo "Next steps:"
echo "1. Open Codex and use /ceo, /feature-br, /prd, or /pd-review."
echo "2. If you later modify template files in this repo, run ./sync.sh from the repo root."

if [[ -n "$TEMP_ROOT" && -d "$TEMP_ROOT" ]]; then
  rm -rf "$TEMP_ROOT"
fi
