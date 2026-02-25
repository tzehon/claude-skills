# Claude Skills

A collection of reusable skills (system prompts) for Claude that provide deep domain expertise. Each skill can be used across all Claude surfaces: Claude.ai (web/mobile), Claude Code (CLI), and the Claude API — directly from this repo without copying files.

## Available Skills

| Skill | Description |
|-------|-------------|
| [mongodb-data-modelling](skills/mongodb-data-modelling/) | MongoDB schema design expert — applies official best practices, 15+ design patterns, anti-pattern avoidance, and the 3-phase schema design process |

---

## Using Skills

### Claude.ai (Web / Mobile)

**Option A — Upload to a Project (recommended for repeated use)**:
1. Open a [Claude Project](https://claude.ai)
2. Go to **Project Knowledge**
3. Upload the skill's `.md` file (e.g., `skills/mongodb-data-modelling/mongodb-data-modelling.md`)
4. Start chatting — Claude now has the skill's expertise

**Option B — Copy to clipboard and paste into Project instructions**:
```bash
./scripts/load-skill.sh mongodb-data-modelling | pbcopy   # macOS
./scripts/load-skill.sh mongodb-data-modelling | xclip     # Linux
```
Then paste into the Project instructions or the system prompt field.

### Claude Code (CLI)

**Option A — Symlink from this repo (recommended, stays in sync)**:
```bash
./scripts/install-skill.sh mongodb-data-modelling /path/to/your/project --symlink
```
This creates a symlink in your project's `.claude/commands/` pointing back to this repo. When the skill is updated in this repo, your project gets the updates automatically.

Then use in Claude Code:
```
/mongodb-data Design a schema for an e-commerce platform
```

**Option B — Copy into a project (standalone, no dependency on this repo)**:
```bash
./scripts/install-skill.sh mongodb-data-modelling /path/to/your/project
```

**Option C — Manual setup**:
```bash
mkdir -p /path/to/your/project/.claude/commands
cp skills/mongodb-data-modelling/mongodb-data-modelling.md \
   /path/to/your/project/.claude/commands/mongodb-data.md
```

### Claude API / SDKs

**Option A — Load directly from repo in your script**:
```python
import anthropic
import subprocess

# Load skill content directly from the repo
result = subprocess.run(
    ["./scripts/load-skill.sh", "mongodb-data-modelling"],
    capture_output=True, text=True, cwd="/path/to/claude-skills"
)
system_prompt = result.stdout

client = anthropic.Anthropic()
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=8192,
    system=system_prompt,
    messages=[{"role": "user", "content": "Design a data model for ..."}]
)
```

**Option B — Read the file directly**:
```python
import anthropic
from pathlib import Path

system_prompt = Path("/path/to/claude-skills/skills/mongodb-data-modelling/mongodb-data-modelling.md").read_text()

client = anthropic.Anthropic()
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=8192,
    system=system_prompt,
    messages=[{"role": "user", "content": "Design a data model for ..."}]
)
```

Works the same way with **Amazon Bedrock** and **Google Vertex AI** — pass the skill content as the system prompt.

---

## Scripts Reference

All scripts are in the `scripts/` directory and are self-documented (`--help` or run with no args).

### `load-skill.sh` — Output a skill's content to stdout

The primary way to use skills without copying. Outputs raw skill content for piping.

```bash
# Print skill content
./scripts/load-skill.sh mongodb-data-modelling

# Copy to clipboard (for pasting into Claude.ai)
./scripts/load-skill.sh mongodb-data-modelling | pbcopy

# Use as a variable in scripts
PROMPT=$(./scripts/load-skill.sh mongodb-data-modelling)

# Pipe into claude CLI
echo "Design a schema for e-commerce" | claude --system "$(./scripts/load-skill.sh mongodb-data-modelling)"
```

### `install-skill.sh` — Install a skill as a Claude Code slash command

Copies or symlinks a skill into a project's `.claude/commands/` directory.

```bash
# Copy into a project
./scripts/install-skill.sh mongodb-data-modelling /path/to/project

# Symlink into a project (stays in sync with this repo)
./scripts/install-skill.sh mongodb-data-modelling /path/to/project --symlink

# Install to current directory
./scripts/install-skill.sh mongodb-data-modelling .
```

**Options**:
- `--symlink` — Create a symlink instead of copying. The skill stays in sync with this repo — any updates here are immediately available in your project.

### `package-skill.sh` — Package a skill into a distributable zip

Creates a zip file in `dist/` for sharing or uploading.

```bash
./scripts/package-skill.sh mongodb-data-modelling
# Output: dist/mongodb-data-modelling.zip
```

### `package-all.sh` — Package all skills at once

Runs `package-skill.sh` for every skill in the `skills/` directory.

```bash
./scripts/package-all.sh
# Output: dist/<skill-name>.zip for each skill
```

---

## Project Structure

```
claude-skills/
├── README.md                           # This file
├── .gitignore
├── scripts/
│   ├── load-skill.sh                   # Output skill content to stdout
│   ├── install-skill.sh                # Install skill into a Claude Code project
│   ├── package-skill.sh                # Package one skill into a zip
│   └── package-all.sh                  # Package all skills into zips
├── skills/
│   └── mongodb-data-modelling/
│       ├── README.md                   # Skill-specific docs and sources
│       └── mongodb-data-modelling.md   # The skill prompt
└── dist/                               # Generated zip files (gitignored)
```

---

## Creating a New Skill

1. Create a directory under `skills/`:
   ```bash
   mkdir -p skills/my-new-skill
   ```

2. Create the skill prompt file `skills/my-new-skill/my-new-skill.md` containing:
   - Role definition and expertise area
   - Structured interaction flow (what to ask, how to respond)
   - Domain knowledge, rules, and best practices
   - Output format specification
   - Examples

3. Create a `skills/my-new-skill/README.md` with usage instructions and sources

4. Test across surfaces:
   - Upload to a Claude.ai project
   - Install as a Claude Code slash command
   - Use as a system prompt via the API

5. Package for distribution:
   ```bash
   ./scripts/package-skill.sh my-new-skill
   ```

## Design Principles for Skills

- **Self-contained**: Each skill prompt works standalone without external dependencies
- **Surface-agnostic**: Skills are plain Markdown files usable in any Claude surface
- **Interactive**: Skills guide Claude to ask clarifying questions before producing output
- **Structured output**: Define clear output formats so responses are consistent and actionable
- **Grounded**: Base domain knowledge on official documentation and established best practices
