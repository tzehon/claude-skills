# Claude Skills

Reusable domain-expert skills (system prompts) for Claude — usable across Claude.ai, Claude Code, and the Claude API, directly from this repo.

## Available Skills

| Skill | Description |
|-------|-------------|
| [mongodb-data-modelling](skills/mongodb-data-modelling/) | MongoDB schema design expert — 15+ design patterns, anti-pattern avoidance, and the 3-phase schema design process |

---

## Using Skills

### Claude.ai (Web / Mobile)

1. Open a [Claude Project](https://claude.ai)
2. Go to **Project Knowledge**
3. Upload the skill's `.md` file, or copy its content to the clipboard and paste into project instructions:
   ```bash
   ./scripts/load-skill.sh mongodb-data-modelling | pbcopy   # macOS
   ./scripts/load-skill.sh mongodb-data-modelling | xclip     # Linux
   ```
4. Start chatting — Claude now has the skill's expertise

### Claude Code (CLI)

Install a skill as a custom slash command in your project:

```bash
# Symlink (recommended — stays in sync when you pull this repo)
./scripts/install-skill.sh mongodb-data-modelling /path/to/your/project --symlink

# Or copy (standalone, no dependency on this repo)
./scripts/install-skill.sh mongodb-data-modelling /path/to/your/project
```

This creates `.claude/commands/mongodb-data.md` in your project. Then use it in Claude Code:

```
/mongodb-data Design a schema for an e-commerce platform with products, orders, and reviews
```

Everything after the command name is passed as context to Claude. You can also invoke `/mongodb-data` with no arguments and Claude will ask you clarifying questions.

### Claude API / SDKs

Load the skill as a system prompt:

```python
import anthropic
from pathlib import Path

system_prompt = Path("skills/mongodb-data-modelling/mongodb-data-modelling.md").read_text()

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

## Scripts

| Script | Purpose |
|--------|---------|
| `load-skill.sh <name>` | Output skill content to stdout — pipe to clipboard, scripts, or other tools |
| `install-skill.sh <name> [dir] [--symlink]` | Install a skill as a Claude Code slash command (copy or symlink) |
| `package-skill.sh <name>` | Package a skill into `dist/<name>.zip` for distribution |
| `package-all.sh` | Package all skills into individual zips |

All scripts list available skills when run with no arguments.

---

## Project Structure

```
claude-skills/
├── README.md
├── scripts/
│   ├── load-skill.sh           # Output skill content to stdout
│   ├── install-skill.sh        # Install as Claude Code slash command
│   ├── package-skill.sh        # Package one skill into a zip
│   └── package-all.sh          # Package all skills
└── skills/
    └── mongodb-data-modelling/
        ├── README.md            # Skill docs and sources
        └── mongodb-data-modelling.md  # The skill prompt
```

---

## Creating a New Skill

1. Create `skills/my-skill/my-skill.md` — the skill prompt containing:
   - Role definition and expertise area
   - Interaction flow (what to ask, how to respond)
   - Domain knowledge, rules, and best practices
   - Output format specification

2. Create `skills/my-skill/README.md` with usage instructions and sources

3. Test across surfaces — upload to Claude.ai, install in Claude Code, use as API system prompt

4. Package: `./scripts/package-skill.sh my-skill`
