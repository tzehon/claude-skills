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

Every skill follows the official SKILL.md convention:

```
skills/<skill-name>/
├── SKILL.md           # The skill prompt with YAML frontmatter (required)
└── references/        # Supporting materials (optional)
    └── sources.md     # Source URLs and attributions
```

Scripts locate the prompt file via `$SKILLS_DIR/$SKILL_NAME/SKILL.md`, so this naming is enforced.

## Adding a New Skill

1. Create `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description` with trigger phrases, `metadata`) followed by the skill body — structure the body as: role definition, interaction flow, core principles, decision frameworks, pattern reference with examples, anti-patterns, output format
2. Optionally create `skills/<name>/references/` for source URLs or supporting materials
3. Update the Available Skills table in the top-level `README.md`
4. Test: `./scripts/load-skill.sh <name>` to verify content renders correctly

## Architecture Notes

- Skills use the official SKILL.md format with YAML frontmatter — compatible with Claude.ai skill upload, Claude Code, and the Claude API
- `install-skill.sh` places skills into `.claude/commands/` in target projects; with `--symlink` it creates absolute-path symlinks so the skill stays in sync with this repo
- `package-skill.sh` creates zips excluding `.DS_Store`, `__pycache__/`, and `.git/`
