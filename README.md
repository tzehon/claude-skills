# Claude Skills

Reusable domain-expert skills (system prompts) for Claude — usable across Claude.ai, Claude Code, and the Claude API, directly from this repo.

## Available Skills

| Skill | Description |
|-------|-------------|
| [mongodb-data-modelling](skills/mongodb-data-modelling/) | MongoDB schema design expert — 15 design patterns, 5 tree structures, anti-pattern avoidance, schema validation, and the 3-phase design process. [Sources](skills/mongodb-data-modelling/references/sources.md) |

---

## Using Skills

### Claude.ai (Web / Mobile)

1. Open a [Claude Project](https://claude.ai)
2. Go to **Project Knowledge**
3. Upload the skill's `SKILL.md` file, upload the packaged zip, or copy its content to the clipboard and paste into project instructions:
   ```bash
   ./scripts/load-skill.sh mongodb-data-modelling | pbcopy   # macOS
   ./scripts/load-skill.sh mongodb-data-modelling | xclip    # Linux
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

This creates `.claude/commands/mongodb-data-modelling.md` in your project. Then use it in Claude Code:

```
/mongodb-data-modelling Design a schema for an e-commerce platform with products, orders, and reviews
```

Everything after the command name is passed as context to Claude. You can also invoke `/mongodb-data-modelling` with no arguments and Claude will ask you clarifying questions.

### Claude API / SDKs

Load the skill as a system prompt:

```python
import anthropic
from pathlib import Path

system_prompt = Path("skills/mongodb-data-modelling/SKILL.md").read_text()

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
        ├── SKILL.md             # The skill prompt with YAML frontmatter
        └── references/
            └── sources.md       # Source URLs and attributions
```

---

## Creating a New Skill

1. Create `skills/my-skill/SKILL.md` with YAML frontmatter and the skill prompt:
   ```yaml
   ---
   name: My Skill
   description: |
     What the skill does.
     Trigger: "phrases that activate this skill"
     Not for: things outside scope
   metadata:
     version: "1.0"
     author: your-name
     tags: [topic1, topic2]
   ---
   ```
   Follow with the skill body: role definition, interaction flow, domain knowledge, output format.

2. Optionally create `skills/my-skill/references/` for source URLs or supporting materials

3. Update the Available Skills table above

4. Test across surfaces — upload to Claude.ai, install in Claude Code, use as API system prompt

5. Package: `./scripts/package-skill.sh my-skill`
