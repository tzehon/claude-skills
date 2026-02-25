# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A library of reusable domain-expert skills (system prompts) for Claude, deployable across Claude.ai, Claude Code, and the Claude API without modification.

## Scripts

All scripts use `set -euo pipefail`, auto-detect the repo root, and print help with available skills when run without arguments.

```bash
./scripts/load-skill.sh <skill-name>                          # Output skill content to stdout
./scripts/install-skill.sh <skill-name> [dir] [--symlink]     # Install as Claude Code slash command
./scripts/package-skill.sh <skill-name>                        # Package to dist/<skill-name>.zip
./scripts/package-all.sh                                       # Package all skills
```

## Skill Structure

Every skill follows this exact convention — the directory name, main file name, and slash command name must all match:

```
skills/<skill-name>/
├── <skill-name>.md    # The skill prompt (required, name must match directory)
└── README.md          # Documentation and sources
```

Scripts locate the prompt file via `$SKILLS_DIR/$SKILL_NAME/$SKILL_NAME.md`, so this naming is enforced.

## Adding a New Skill

1. Create `skills/<name>/<name>.md` — structure it as: role definition, interaction flow, core principles, decision frameworks, pattern reference with examples, anti-patterns, output format
2. Create `skills/<name>/README.md` with usage instructions and source references
3. Update the Available Skills table in the top-level `README.md`
4. Test: `./scripts/load-skill.sh <name>` to verify content renders correctly

## Architecture Notes

- Skills are plain Markdown with no frontmatter or Claude-Code-specific syntax — this is what makes them work across all surfaces
- `install-skill.sh` places skills into `.claude/commands/` in target projects; with `--symlink` it creates absolute-path symlinks so the skill stays in sync with this repo
- `package-skill.sh` creates zips excluding `.DS_Store`, `__pycache__/`, and `.git/`
