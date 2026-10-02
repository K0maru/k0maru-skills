#!/usr/bin/env bash
set -e -u -o pipefail

# ==============================================================================
# k0maru-skills Sync Script
# Links all skills in this repository to agent configuration directories.
# Supports:
#   - Universal Agent Skills: ~/.agents/skills/
#   - Antigravity / Gemini CLI: ~/.gemini/config/skills/
#   - Claude Code: ~/.claude/skills/
# ==============================================================================

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

TARGETS=(
  "$HOME/.agents/skills"
  "$HOME/.gemini/config/skills"
  "$HOME/.claude/skills"
)

DRY_RUN=false
LIST_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --list)
      LIST_ONLY=true
      shift
      ;;
    -h|--help)
      echo "Usage: $(basename "$0") [options]"
      echo ""
      echo "Options:"
      echo "  --dry-run  Preview symlink actions without modifying disk"
      echo "  --list     List all skills found in this repository"
      echo "  -h, --help Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Find all directories containing SKILL.md (ignoring hidden dirs, .git, etc.)
find_skills() {
  find "$REPO_ROOT/core" "$REPO_ROOT/vendor" "$REPO_ROOT/external" \
    -type f -name "SKILL.md" 2>/dev/null | while read -r skill_file; do
    dirname "$skill_file"
  done | sort -u
}

if [[ "$LIST_ONLY" == true ]]; then
  echo "Found skills in $REPO_ROOT:"
  echo "----------------------------------------------------"
  find_skills | while read -r skill_dir; do
    rel_path="${skill_dir#$REPO_ROOT/}"
    skill_name="$(basename "$skill_dir")"
    printf "  %-30s (%s)\n" "$skill_name" "$rel_path"
  done
  exit 0
fi

echo "===================================================="
echo " Syncing skills from: $REPO_ROOT"
echo "===================================================="

# Ensure target directories exist
for target in "${TARGETS[@]}"; do
  if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$target"
  fi
done

total_skills=0
find_skills | while read -r skill_dir; do
  skill_name="$(basename "$skill_dir")"
  rel_path="${skill_dir#$REPO_ROOT/}"
  total_skills=$((total_skills + 1))

  for target in "${TARGETS[@]}"; do
    dest="$target/$skill_name"
    if [[ "$DRY_RUN" == true ]]; then
      echo "[DRY-RUN] ln -sfn \"$skill_dir\" \"$dest\""
    else
      ln -sfn "$skill_dir" "$dest"
    fi
  done
  echo "✓ Linked $skill_name ($rel_path)"
done

echo ""
echo "Done! All skills linked to:"
for target in "${TARGETS[@]}"; do
  echo "  - $target"
done
