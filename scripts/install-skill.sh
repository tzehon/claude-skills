#!/usr/bin/env bash
# Install a skill as a Claude Code slash command in a target project.
#
# Usage:
#   ./scripts/install-claude-code.sh <skill-name> [target-project-dir] [--symlink]
#
# Options:
#   --symlink   Create a symlink instead of copying (keeps skill updated with repo)
#
# Examples:
#   ./scripts/install-claude-code.sh mongodb-data-modelling /path/to/my-project
#   ./scripts/install-claude-code.sh mongodb-data-modelling /path/to/my-project --symlink
#   ./scripts/install-claude-code.sh mongodb-data-modelling  # uses current directory

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
USE_SYMLINK=false

# Parse arguments
POSITIONAL_ARGS=()
for arg in "$@"; do
  case $arg in
    --symlink) USE_SYMLINK=true ;;
    *) POSITIONAL_ARGS+=("$arg") ;;
  esac
done

if [ ${#POSITIONAL_ARGS[@]} -lt 1 ]; then
  echo "Usage: $0 <skill-name> [target-project-dir] [--symlink]"
  echo ""
  echo "Available skills:"
  for dir in "$SKILLS_DIR"/*/; do
    [ -d "$dir" ] && echo "  $(basename "$dir")"
  done
  exit 1
fi

SKILL_NAME="${POSITIONAL_ARGS[0]}"
TARGET_DIR="${POSITIONAL_ARGS[1]:-.}"
SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"

if [ ! -d "$SKILL_DIR" ]; then
  echo "Error: Skill '$SKILL_NAME' not found at $SKILL_DIR"
  exit 1
fi

# Find the main skill prompt file
SKILL_FILE="$SKILL_DIR/$SKILL_NAME.md"
if [ ! -f "$SKILL_FILE" ]; then
  echo "Error: Skill prompt file not found at $SKILL_FILE"
  exit 1
fi

# Create .claude/commands in the target project
COMMANDS_DIR="$TARGET_DIR/.claude/commands"
mkdir -p "$COMMANDS_DIR"

# Derive a short command name (strip common suffixes)
COMMAND_NAME="$(echo "$SKILL_NAME" | sed 's/-modelling$//' | sed 's/-pattern$//' | sed 's/-skill$//')"
DEST_FILE="$COMMANDS_DIR/$COMMAND_NAME.md"

if [ "$USE_SYMLINK" = true ]; then
  # Resolve to absolute path for symlink
  SKILL_FILE_ABS="$(cd "$(dirname "$SKILL_FILE")" && pwd)/$(basename "$SKILL_FILE")"
  rm -f "$DEST_FILE"
  ln -s "$SKILL_FILE_ABS" "$DEST_FILE"
  echo "Linked skill as Claude Code command: /$COMMAND_NAME"
  echo "  Symlink: $DEST_FILE -> $SKILL_FILE_ABS"
else
  cp "$SKILL_FILE" "$DEST_FILE"
  echo "Installed skill as Claude Code command: /$COMMAND_NAME"
  echo "  Source: $SKILL_FILE"
  echo "  Target: $DEST_FILE"
fi

echo ""
echo "Usage in Claude Code:"
echo "  /$COMMAND_NAME Design a schema for an e-commerce platform"
