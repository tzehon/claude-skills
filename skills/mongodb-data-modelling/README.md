# MongoDB Data Modelling Skill

A comprehensive MongoDB schema design skill for Claude that applies official best practices, design patterns, and anti-pattern avoidance from MongoDB's documentation.

## What This Skill Does

When activated, Claude becomes a MongoDB data modelling expert that:

1. **Gathers requirements** — Asks clarifying questions about entities, relationships, workload profiles, query patterns, and data volumes
2. **Designs schemas** — Applies the 3-phase schema design process (identify workload, map relationships, apply patterns)
3. **Presents complete designs** — Provides collection structures, example documents, indexes, schema validation rules, and trade-off analysis

## Patterns Covered

| Category | Patterns |
|----------|----------|
| Computed Values | Computed, Approximation |
| Grouping Data | Bucket, Outlier, Attribute, Subset |
| Polymorphic Data | Polymorphic, Inheritance |
| Data Versioning | Document Versioning, Schema Versioning, Slowly Changing Dimensions |
| Data Lifecycle | Archive |
| Access Optimization | Extended Reference, Single Collection, Preallocation |
| Tree Structures | Parent References, Child References, Array of Ancestors, Materialized Paths, Nested Sets |

Also covers: anti-patterns (unbounded arrays, excessive collections, unnecessary indexes, bloated documents, $lookup over-reliance), embedding vs. referencing decision framework, schema validation (JSON Schema, query expressions, polymorphic validation, validation levels/actions), transactions, atomic operations, monetary data (Decimal128), IoT/time-series, data consistency approaches, and relationship modelling (1:1, 1:Few, 1:Many, 1:Squillions, N:N).

## Usage

### Claude.ai (Web / Mobile)

Upload `mongodb-data-modelling.md` to a Claude Project's Knowledge, or paste its contents into the project instructions:

```bash
# Copy to clipboard
../../scripts/load-skill.sh mongodb-data-modelling | pbcopy
```

Then start a conversation:
- "Design a data model for an e-commerce platform with products, orders, and reviews"
- "I need a schema for a multi-tenant SaaS application with hierarchical organizations"

### Claude Code (CLI)

```bash
# Symlink (recommended — stays in sync with repo)
../../scripts/install-skill.sh mongodb-data-modelling /path/to/project --symlink

# Or copy
../../scripts/install-skill.sh mongodb-data-modelling /path/to/project
```

Then use: `/mongodb-data <your requirements>`

### Claude API

```python
from pathlib import Path
import anthropic

system_prompt = Path("skills/mongodb-data-modelling/mongodb-data-modelling.md").read_text()
client = anthropic.Anthropic()
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=8192,
    system=system_prompt,
    messages=[{"role": "user", "content": "Design a data model for a blogging platform"}]
)
```

### Amazon Bedrock / Google Vertex AI

Same approach — pass the skill content as the system prompt.

## Sources

This skill synthesizes guidance from:

- [Building with Patterns blog series](https://www.mongodb.com/company/blog/building-with-patterns-a-summary) (Approximation, Attribute, Computed, Document Versioning, Extended Reference, Outlier, Preallocation, Schema Versioning, Subset, Tree)
- [MongoDB Data Modeling documentation](https://www.mongodb.com/docs/manual/data-modeling/) (best practices, embedding, referencing, duplicate data handling, data consistency)
- [Schema Design Process](https://www.mongodb.com/docs/manual/data-modeling/schema-design-process/) (identify workload, map relationships, apply patterns)
- [Design Patterns](https://www.mongodb.com/docs/manual/data-modeling/design-patterns/) (computed values, group data, polymorphic data, data versioning, archive, single collection)
- [Design Anti-Patterns](https://www.mongodb.com/docs/manual/data-modeling/design-antipatterns/) (unbounded arrays, excessive collections, unnecessary indexes, bloated documents, $lookup over-reliance)
- [Relationship Models](https://www.mongodb.com/docs/manual/applications/data-models-relationships/) (1:1, 1:N embedded, 1:N referenced, N:N)
- [Tree Structure Models](https://www.mongodb.com/docs/manual/applications/data-models-tree-structures/) (parent refs, child refs, ancestors array, materialized paths, nested sets)
- [Schema Validation](https://www.mongodb.com/docs/manual/core/schema-validation/) (JSON Schema, query expressions, validation levels, polymorphic validation, bypass, tips)
- [Application Data Models](https://www.mongodb.com/docs/manual/applications/data-models-applications/) (atomic operations, IoT data, monetary data)
