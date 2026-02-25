#!/usr/bin/env bash
# Output a skill's prompt content to stdout for piping into other tools.
#
# Usage:
#   ./scripts/load-skill.sh <skill-name>
#
# Examples:
#   # Print skill content
#   ./scripts/load-skill.sh mongodb-data-modelling
#
#   # Pipe into clipboard (macOS)
#   ./scripts/load-skill.sh mongodb-data-modelling | pbcopy
#
#   # Use in a script / API call
#   PROMPT=$(./scripts/load-skill.sh mongodb-data-modelling)
#
#   # Pipe directly into claude CLI
#   echo "Design a schema for e-commerce" | claude --system "$(./scripts/load-skill.sh mongodb-data-modelling)"

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <skill-name>" >&2
  echo "" >&2
  echo "Available skills:" >&2
  for dir in "$SKILLS_DIR"/*/; do
    [ -d "$dir" ] && echo "  $(basename "$dir")" >&2
  done
  exit 1
fi

SKILL_NAME="$1"
SKILL_FILE="$SKILLS_DIR/$SKILL_NAME/$SKILL_NAME.md"

if [ ! -f "$SKILL_FILE" ]; then
  echo "Error: Skill '$SKILL_NAME' not found at $SKILL_FILE" >&2
  exit 1
fi

cat "$SKILL_FILE"
