#!/usr/bin/env bash
# Package a single skill into a distributable zip file.
#
# Usage:
#   ./scripts/package-skill.sh <skill-name>
#
# Example:
#   ./scripts/package-skill.sh mongodb-data-modelling
#
# Output:
#   dist/<skill-name>.zip

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
DIST_DIR="$REPO_ROOT/dist"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <skill-name>"
  echo ""
  echo "Available skills:"
  ls -1 "$SKILLS_DIR" 2>/dev/null || echo "  (none)"
  exit 1
fi

SKILL_NAME="$1"
SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"

if [ ! -d "$SKILL_DIR" ]; then
  echo "Error: Skill '$SKILL_NAME' not found at $SKILL_DIR"
  exit 1
fi

mkdir -p "$DIST_DIR"

ZIP_FILE="$DIST_DIR/$SKILL_NAME.zip"
rm -f "$ZIP_FILE"

cd "$SKILLS_DIR"
zip -r "$ZIP_FILE" "$SKILL_NAME/" -x "*/.DS_Store" "*/__pycache__/*" "*/.git/*"

echo "Packaged: $ZIP_FILE"
echo "Contents:"
unzip -l "$ZIP_FILE"
