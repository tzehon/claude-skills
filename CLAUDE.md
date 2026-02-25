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
├── SKILL.md           # Required - main skill file with YAML frontmatter
├── scripts/           # Optional - executable code (Python, Bash, etc.)
├── references/        # Optional - documentation loaded as needed
│   └── sources.md     # Source URLs and attributions
└── assets/            # Optional - templates, fonts, icons used in output
```

Scripts locate the prompt file via `$SKILLS_DIR/$SKILL_NAME/SKILL.md`, so this naming is enforced. Do not add a README.md inside the skill folder — all documentation goes in SKILL.md or references/.

## Adding a New Skill

1. Create `skills/<name>/SKILL.md` with YAML frontmatter followed by the skill body
2. Optionally create `skills/<name>/references/` for supporting materials, and link to them from SKILL.md
3. Update the Available Skills table in the top-level `README.md`
4. Test: `./scripts/load-skill.sh <name>` to verify content renders correctly

### Frontmatter requirements

- **`name`** (required): kebab-case only, no spaces or capitals, must match the folder name. No "claude" or "anthropic" in the name (reserved)
- **`description`** (required): must include WHAT it does + WHEN to use it (trigger phrases). Under 1024 characters. No XML angle brackets (`<` or `>`). Include specific tasks users might say. Add negative triggers ("Not for: ...") to prevent false activation
- **`metadata`** (optional): custom key-value pairs — suggested: `version`, `author`
- **`license`** (optional): MIT, Apache-2.0, etc.
- **`compatibility`** (optional, 1-500 chars): environment requirements (e.g. intended product, required packages)

### Body structure

Structure the body as: role definition, interaction flow, core principles, decision frameworks, pattern reference with examples, anti-patterns, example scenarios (user says X → actions → result), troubleshooting/error handling, output format

## Skill Authoring Best Practices

Based on [The Complete Guide to Building Skills for Claude](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf):

### Length and progressive disclosure

- **Keep SKILL.md body under 5,000 words** — excluding frontmatter. Move reference material to `references/` if nearing the limit
- **3-level progressive disclosure**: (1) YAML frontmatter — always loaded, tells Claude when to activate without loading everything; (2) SKILL.md body — loaded when Claude thinks the skill is relevant; (3) Linked files in `references/`, `scripts/`, `assets/` — discovered and navigated as needed
- **Link to reference files from SKILL.md** — don't just place files in `references/`, tell Claude they exist (e.g. "Consult `references/api-patterns.md` for rate limiting guidance")

### Description and triggers

- **Include trigger phrases** in the frontmatter `description` — specific tasks users would actually say
- **Include negative triggers** ("Not for: ...") to prevent false activation
- **Description under 1024 characters** — no XML angle brackets

### Instructions

- **Be specific and actionable** — "Run `python scripts/validate.py --input {filename}`" not "Validate the data before proceeding"
- **Put critical instructions at the top** — use `## Important` or `## Critical` headers
- **Use concrete examples** over abstract rules — show don't tell
- **Include error handling / troubleshooting** — common errors with cause and solution
- **Include example scenarios** — user request → actions → result
- **One domain per skill** — don't combine unrelated expertise into a single skill

### Testing

- **Test the skill prompt in isolation** — it should work as a standalone system prompt with no external dependencies
- **Test triggering** — verify skill activates on obvious tasks and paraphrased requests, and does NOT activate on unrelated topics
- **Test functional output** — run the same request 3-5 times and compare for structural consistency

## Architecture Notes

- Skills use the official SKILL.md format with YAML frontmatter — compatible with Claude.ai skill upload, Claude Code, and the Claude API
- **Claude.ai**: upload skill folder or zip via Settings > Capabilities > Skills (auto-triggers based on description), or add SKILL.md to a project's knowledge for project-scoped use
- **Claude Code**: install as a slash command via `install-skill.sh` into `.claude/commands/`, or place in Claude Code skills directory
- **API distribution**: use the `/v1/skills` endpoint for managing skills and the `container.skills` parameter in Messages API requests. Works with the Claude Agent SDK for building custom agents
- `install-skill.sh` places skills into `.claude/commands/` in target projects; with `--symlink` it creates absolute-path symlinks so the skill stays in sync with this repo
- `package-skill.sh` creates zips excluding `.DS_Store`, `__pycache__/`, and `.git/`
