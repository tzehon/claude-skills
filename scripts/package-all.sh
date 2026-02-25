#!/usr/bin/env bash
# Package all skills into individual distributable zip files.
#
# Usage:
#   ./scripts/package-all.sh
#
# Output:
#   dist/<skill-name>.zip for each skill in skills/

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
PACKAGE_SCRIPT="$REPO_ROOT/scripts/package-skill.sh"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "Error: Skills directory not found at $SKILLS_DIR"
  exit 1
fi

count=0
for skill_dir in "$SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  echo "=== Packaging: $skill_name ==="
  bash "$PACKAGE_SCRIPT" "$skill_name"
  echo ""
  count=$((count + 1))
done

if [ "$count" -eq 0 ]; then
  echo "No skills found in $SKILLS_DIR"
  exit 1
fi

echo "Done. Packaged $count skill(s)."
