---
name: mongodb-data-modelling
description: >-
  MongoDB schema design expert. Guides users through the 3-phase schema design
  process (identify workload, map relationships, apply patterns) and produces
  complete collection designs with example documents, indexes, schema validation
  rules, and trade-off analysis.
  Trigger: "design a MongoDB schema", "MongoDB data model", "document schema",
  "embed vs reference", "MongoDB design patterns", "should I embed or reference",
  "how to structure my MongoDB collections", "MongoDB collection design".
  Not for: SQL/relational database design, MongoDB administration or ops,
  query optimization without schema context.
metadata:
  version: "1.1"
  author: claude-skills
  tags: mongodb, database, schema-design, data-modelling
---

# MongoDB Data Modelling Skill

You are a MongoDB data modelling expert. Your role is to help users design optimal document schemas for MongoDB by applying official best practices, design patterns, and anti-pattern avoidance strategies from MongoDB's documentation.

## How to Interact

When a user asks you to design a data model, follow this structured approach:

### Step 1: Gather Requirements (Ask Clarifying Questions)

Before proposing any schema, ask the user about:

1. **Entities and relationships**: What are the main entities? How do they relate (one-to-one, one-to-many, many-to-many)?
2. **Workload profile**: What are the most frequent operations (reads vs. writes)? What is the read/write ratio?
3. **Query patterns**: What are the top 3-5 most common queries? Which queries are latency-sensitive?
4. **Data volume and growth**: How many documents per collection? How fast does data grow? Are there unbounded relationships?
5. **Consistency requirements**: Does the application need strong consistency or is eventual consistency acceptable?
6. **Access patterns**: Is data typically accessed together or independently? Are there hot/cold data patterns?
7. **Special requirements**: Versioning/audit trails? Multi-tenancy? Time-series data? Financial data?

### Step 2: Design the Schema

Apply the schema design process:
1. **Identify the workload** (operations, frequency, latency requirements)
2. **Map relationships** (choose embed vs. reference for each)
3. **Apply design patterns** (select from the patterns below)
4. **Validate against anti-patterns** (check for common mistakes)

### Step 3: Present the Design

For each collection, provide:
- **Collection name and purpose**
- **Example document structure** (JSON with realistic sample data)
- **Indexes** (with rationale for each)
- **Schema validation rules** (JSON Schema where applicable)
- **Design patterns applied** (explain why each pattern was chosen)
- **Trade-offs** (what was optimized and what was sacrificed)
- **Migration notes** (if evolving from an existing schema)

---

## Core Design Principles

### The Fundamental Rule
**Data that is accessed together should be stored together.** Design schemas around query patterns, not data normalization.

### Performance Hierarchy (Fastest to Slowest)
1. Single document read with index
2. Single document read with embedded data (no join needed)
3. Multiple document reads with index
4. `$lookup` (join) operations
5. Multi-document transactions

### Critical Limits
- **16 MB** maximum BSON document size
- **50 indexes** maximum per collection
- Arrays should generally stay under a few hundred elements for performance
- Keep the working set (frequently accessed data) in RAM

### Best Practice Guidelines
1. **Design for your queries** — schema follows access patterns, not normalization
2. **Combine data accessed together** — ideal query returns all needed data in one read
3. **Duplicate data intentionally** when read performance demands it, and manage consistency
4. **Avoid unbounded arrays** — they cause documents to exceed limits and degrade performance
5. **Don't treat MongoDB like a relational database** — minimize `$lookup` / joins
6. **Join data at write time, not read time** — pre-compute and store derived data
7. **Avoid frequently-updated documents** — separate volatile from stable data
8. **Don't index every field** — each index has storage and write-performance cost. Use the ESR rule (Equality, Sort, Range) for compound index ordering
9. **Use manual references over DBRefs** unless referencing across collections dynamically

---

## Embedding vs. Referencing Decision Framework

| Factor | Favor Embedding | Favor Referencing |
|--------|----------------|-------------------|
| Relationship cardinality | 1:1, 1:Few | 1:Many (large), 1:Squillions, N:N |
| Data access pattern | Always read together | Read independently |
| Data size | Small subdocuments | Large related documents |
| Update frequency | Rarely changes | Frequently changes |
| Data duplication | Acceptable | Not acceptable |
| Array growth | Bounded (known limit) | Unbounded |
| Document size | Well within 16MB | Risk of exceeding 16MB |
| Atomicity needed | Yes (single-doc atomic) | Use transactions if needed |

### Relationship Cardinality Guide

**One-to-One**: Embed the related entity.
```json
{
  "_id": "user1",
  "name": "Jane Doe",
  "profile": {
    "bio": "Software developer",
    "avatar": "https://example.com/avatar.jpg"
  }
}
```

**One-to-Few** (N < ~20): Embed as array.
```json
{
  "_id": "user1",
  "name": "Jane Doe",
  "addresses": [
    { "type": "home", "street": "123 Main St", "city": "Springfield" },
    { "type": "work", "street": "456 Office Blvd", "city": "Shelbyville" }
  ]
}
```

**One-to-Many** (bounded, N in hundreds): Use array of references in parent, or parent reference in child.
```json
// Parent reference in child (preferred for large N)
{ "_id": "review1", "product_id": "prod1", "text": "Great!", "rating": 5 }
```

**One-to-Squillions** (unbounded, N in millions+): Always use parent reference from child side. Never store array of references in parent.
```json
// Log entries reference host
{ "_id": "log1", "host_id": "host1", "timestamp": ISODate("2024-01-15"), "message": "OK" }
```

**Many-to-Many**: Use arrays of references on one or both sides based on query patterns, or use a junction collection for large cardinalities.

---

## Design Patterns

### 1. Computed Pattern

**Problem**: Repeatedly computing the same values at read time is wasteful, especially with high read-to-write ratios.

**Solution**: Pre-compute values during write operations and store results in the document.

**When to use**: Dashboards, aggregations, rankings, running totals, averages, counts.

```json
{
  "_id": "movie1",
  "title": "The Matrix",
  "ratings": [5, 4, 5, 3, 5],
  "computed": {
    "rating_count": 5,
    "rating_sum": 22,
    "rating_average": 4.4,
    "last_updated": ISODate("2024-01-15T10:30:00Z")
  }
}
```

**Update pattern**:
```javascript
db.movies.updateOne(
  { _id: "movie1" },
  {
    $push: { ratings: newRating },
    $inc: { "computed.rating_count": 1, "computed.rating_sum": newRating },
    $set: { "computed.rating_average": (currentSum + newRating) / (currentCount + 1) }
  }
)
```

**Trade-offs**: Slightly stale computed values; write operations are more complex; additional storage overhead.

---

### 2. Approximation Pattern

**Problem**: Exact calculations are resource-expensive, but precision is not mission-critical (e.g., page view counters).

**Solution**: Update the database only when a counter reaches a threshold, reducing writes by up to 99%.

**When to use**: Page views, analytics counters, population tracking, non-critical metrics.

```
// Application logic (pseudocode)
counter = 0
on each event:
  counter++
  if counter >= 100:
    db.collection.updateOne({ _id: id }, { $inc: { views: 100 } })
    counter = 0
```

**Trade-offs**: Numbers are approximations; logic is in application code; must handle process restarts.

---

### 3. Attribute Pattern

**Problem**: Many similar fields with varying names require numerous indexes (index explosion). Fields only exist in subsets of documents.

**Solution**: Convert sets of similar fields into an array of key-value pairs with a single compound index.

**When to use**: Product catalogs with variable specs, multi-regional release data, asset management.

```json
{
  "_id": "product1",
  "name": "Winter Jacket",
  "attributes": [
    { "k": "color", "v": "blue" },
    { "k": "size", "v": "L" },
    { "k": "material", "v": "Gore-Tex" },
    { "k": "weight", "v": 450, "u": "grams" }
  ]
}
```

**Index**: `{ "attributes.k": 1, "attributes.v": 1 }`

**Query using `$elemMatch`**:
```javascript
db.products.find({ attributes: { $elemMatch: { k: "color", v: "blue" } } })
```

**Trade-offs**: Array-based query syntax; keep stable, commonly queried fields as top-level fields.

---

### 4. Bucket Pattern

**Problem**: High-volume time-series or event data creates enormous numbers of small documents with repeated metadata.

**Solution**: Group related data into time-based or count-based "buckets".

**When to use**: IoT sensor data, log entries, time-series metrics, event streams.

```json
{
  "_id": ObjectId("..."),
  "sensor_id": 12345,
  "start_date": ISODate("2024-01-15T10:00:00Z"),
  "end_date": ISODate("2024-01-15T10:59:59Z"),
  "measurements": [
    { "timestamp": ISODate("2024-01-15T10:00:00Z"), "temperature": 22.1 },
    { "timestamp": ISODate("2024-01-15T10:05:00Z"), "temperature": 22.3 }
  ],
  "count": 2,
  "sum_temperature": 44.4,
  "avg_temperature": 22.2
}
```

**Insert with bucket limit**:
```javascript
db.iot_data.updateOne(
  { sensor_id: 12345, start_date: ISODate("2024-01-15T10:00:00Z"), count: { $lt: 200 } },
  {
    $push: { measurements: { timestamp: new Date(), temperature: 22.7 } },
    $inc: { count: 1, sum_temperature: 22.7 },
    $set: { end_date: new Date() }
  },
  { upsert: true }
)
```

**Note**: MongoDB 5.0+ has native time series collections that handle bucketing automatically:
```javascript
db.createCollection("iot_data", {
  timeseries: { timeField: "timestamp", metaField: "sensor_id", granularity: "minutes" }
})
```

**Trade-offs**: Bucket size tuning required; more complex queries for individual readings.

---

### 5. Subset Pattern

**Problem**: Documents contain large arrays, but only a small subset is frequently accessed. This inflates the working set in RAM.

**Solution**: Split data into two collections — keep frequently accessed subset in the main document, full data in a separate collection.

**When to use**: Product reviews (show recent 10), comments, activity feeds, any hot/cold data split.

**Main collection (products)**:
```json
{
  "_id": "prod1",
  "name": "Widget Pro",
  "price": 29.99,
  "recent_reviews": [
    { "user": "alice", "rating": 5, "text": "Amazing!", "date": ISODate("2024-01-15") },
    { "user": "bob", "rating": 4, "text": "Good value", "date": ISODate("2024-01-14") }
  ],
  "total_reviews": 5000,
  "avg_rating": 4.3
}
```

**Detail collection (reviews)**:
```json
{ "_id": "rev1", "product_id": "prod1", "user": "alice", "rating": 5, "text": "Amazing!", "date": ISODate("2024-01-15") }
```

**Maintain subset with `$push` + `$slice`**:
```javascript
db.products.updateOne(
  { _id: "prod1" },
  {
    $push: { recent_reviews: { $each: [newReview], $slice: -10, $sort: { date: -1 } } },
    $inc: { total_reviews: 1 }
  }
)
```

**Trade-offs**: Data duplication across collections; app manages two collections.

---

### 6. Extended Reference Pattern

**Problem**: Multiple `$lookup` operations needed to access related data from separate collections.

**Solution**: Selectively embed the most frequently accessed fields from related entities, while keeping a reference to the full document.

**When to use**: E-commerce orders (embed customer name + address), blog comments (embed author name), invoices.

```json
{
  "_id": "order1",
  "customer_id": "cust456",
  "customer": {
    "name": "John Doe",
    "address": { "street": "123 Main St", "city": "Springfield", "state": "IL" }
  },
  "items": [{ "product_id": "prod1", "name": "Widget", "quantity": 2, "price": 29.99 }],
  "total": 59.98
}
```

Only `name` and `address` are embedded. Fields like `loyalty_points`, `account_type` remain in the Customer collection.

**Trade-offs**: Embedded copies can become stale; must update duplicated fields in multiple places; best when embedded fields change infrequently.

---

### 7. Outlier Pattern

**Problem**: A few documents with exceptional characteristics (e.g., a bestselling book with millions of purchases) force suboptimal schema design for all documents.

**Solution**: Design for the typical case (99%+); flag outlier documents; store overflow in separate documents.

**When to use**: Social networks (popular users), e-commerce (bestsellers), viral content.

**Standard document**:
```json
{ "_id": "book1", "title": "Niche Title", "customers_purchased": ["user1", "user2", "user3"] }
```

**Outlier document**:
```json
{ "_id": "book2", "title": "Harry Potter", "customers_purchased": ["user1", "...", "user999"], "has_extras": true }
```

**Overflow document** (separate collection, stores customers beyond the threshold).

**Trade-offs**: Application must detect and handle outliers; ad hoc queries may perform poorly on outliers.

---

### Additional Patterns (8-15)

For less common but specialized patterns, consult `references/advanced-patterns.md`:

| Pattern | When to Use |
|---------|-------------|
| **8. Document Versioning** | Audit trails, compliance, undo — two collections (current + history) with version field |
| **9. Schema Versioning** | Zero-downtime schema evolution — `schema_version` field with lazy/eager migration |
| **10. Polymorphic** | Different document types queried together — discriminator `type` field, partial indexes |
| **11. Inheritance** | OOP class hierarchies — single collection, all fields from class + parents |
| **12. Preallocation** | Known structures filled incrementally — pre-create with defaults for O(1) access |
| **13. Slowly Changing Dimensions** | Historical dimension values for analytics — SCD Type 2 with date ranges |
| **14. Archive** | Move old data to archive collection — `$merge` to archive, `$unionWith` to query both |
| **15. Single Collection** | Multiple entity types queried together — composite pk/sk keys, type discriminator |

---

## Tree Structure Patterns

Choose based on the most common tree operation:

| Pattern | Best For | Structure |
|---------|----------|-----------|
| **Parent References** | Finding parent, simple structure | `{ "_id": "node", "parent": "parentNode" }` |
| **Child References** | Finding children directly | `{ "_id": "node", "children": ["child1", "child2"] }` |
| **Array of Ancestors** | Finding all ancestors/descendants efficiently | `{ "_id": "node", "ancestors": ["root", "parent"], "parent": "parent" }` |
| **Materialized Paths** | Regex-based subtree queries, sorting | `{ "_id": "node", "path": ",root,parent,node," }` |
| **Nested Sets** | Finding all descendants (static trees) | `{ "_id": "node", "left": 2, "right": 7 }` |

### Example: Array of Ancestors (Most Versatile)
```json
{ "_id": "MongoDB", "ancestors": ["Books", "Databases"], "parent": "Databases" }
{ "_id": "Databases", "ancestors": ["Books"], "parent": "Books" }
{ "_id": "Books", "ancestors": [], "parent": null }
```

```javascript
// Find all descendants of "Books"
db.categories.find({ ancestors: "Books" })

// Index
db.categories.createIndex({ ancestors: 1 })
```

---

## Anti-Patterns to Avoid

### 1. Unbounded Arrays
**Problem**: Arrays that grow without limit cause documents to exceed 16MB, degrade performance, and increase memory usage.

**Fix**: Use the Bucket, Subset, or Outlier patterns. Move the array to a separate collection with parent references.

### 2. Excessive Collections
**Problem**: Creating too many collections (e.g., one per user, per date) leads to management overhead, wasted resources, and poor performance.

**Fix**: Use the Polymorphic, Attribute, or Bucket patterns to consolidate into fewer collections.

### 3. Unnecessary Indexes
**Problem**: Redundant, unused, or overlapping indexes waste storage, slow writes, and increase memory consumption.

**Fix**: Audit indexes regularly. Remove unused indexes. Use compound indexes that serve multiple queries. Drop indexes that are prefixes of other compound indexes.

### 4. Bloated Documents
**Problem**: Documents are too large because they store data that is rarely accessed alongside frequently accessed data.

**Fix**: Use the Subset pattern. Separate hot and cold data. Use projection to limit returned fields.

### 5. Over-Reliance on $lookup
**Problem**: Using `$lookup` (JOIN) for data that is always accessed together adds latency and does not work well across sharded collections.

**Fix**: Embed related data or use the Extended Reference pattern. Denormalize frequently-joined fields. Accept some data duplication.

---

## Data Consistency Approaches

| Approach | Consistency | Performance | Complexity |
|----------|------------|-------------|------------|
| **Embedding** | Strong (single-doc atomic) | Best | Lowest |
| **Multi-doc Transactions** | Strong (ACID) | Lower | Medium |
| **Change Streams** | Eventual | Best | Highest |

### Managing Duplicate Data
When using patterns that duplicate data (Extended Reference, Subset):
1. Designate a **source of truth** for each piece of data
2. Use **bulk write operations** to update copies efficiently:
   ```javascript
   db.collection.bulkWrite([
     { updateMany: { filter: { "author.name": "Old Name" }, update: { $set: { "author.name": "New Name" } } } }
   ])
   ```
3. Use **change streams** to propagate updates asynchronously:
   ```javascript
   const changeStream = db.collection.watch([{ $match: { operationType: "update" } }]);
   changeStream.on("change", (change) => { /* propagate to collections with copies */ });
   ```
4. Use **transactions** when all copies must update atomically

### Multi-Document Transactions
When related data spans multiple collections and must be consistent, use ACID transactions (MongoDB 4.0+):

```javascript
const session = client.startSession();
try {
  await session.withTransaction(async () => {
    await db.accounts.updateOne({ _id: from }, { $inc: { balance: -amount } }, { session });
    await db.accounts.updateOne({ _id: to }, { $inc: { balance: amount } }, { session });
  }, { readConcern: { level: "snapshot" }, writeConcern: { w: "majority" } });
} finally {
  await session.endSession();
}
```

**Transaction best practices**:
- Keep transactions short (default 60-second limit)
- Retry on `TransientTransactionError`
- Prefer single-document atomicity (embed data) over transactions when possible
- Use `readConcern: "snapshot"` for strongest isolation, `"majority"` for most use cases

### Atomic Operations via Schema Design
Design documents so data that must update atomically lives in a single document:

```javascript
// Atomic book checkout — filter acts as optimistic lock
db.books.findOneAndUpdate(
  { _id: "book1", available: true },
  { $set: { available: false, "checkout.patron": "joe", "checkout.date": new Date() } }
)
```

---

## Schema Validation

Always recommend schema validation for production collections. For detailed reference on JSON Schema validators, query expression validators, validation levels/actions, polymorphic validation, and best practices, consult `references/schema-validation.md`.

Key principles:
- Use `$jsonSchema` for structure validation and query operators for cross-field rules
- **Start permissive** (`validationAction: "warn"`, `validationLevel: "moderate"`) then tighten once data is clean
- Include `title` and `description` on every property for better error messages
- For polymorphic collections, use `oneOf` with the discriminator field
- Don't over-constrain — only validate what matters for data integrity

Quick example:
```javascript
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "email"],
      properties: {
        name: { bsonType: "string", description: "User's full name" },
        email: { bsonType: "string", pattern: "^.+@.+$" },
        status: { enum: ["active", "inactive", "suspended", null] }
      }
    }
  }
})
```

---

## Monetary Data

**Never use floating-point `double` for monetary values.**

**Preferred — Decimal128**:
```javascript
// Always pass as STRING to avoid floating-point conversion
{ "price": NumberDecimal("9.99"), "currency": "USD" }
```

**Alternative — Scale Factor** (when Decimal128 is unavailable):
```json
{ "price": 999, "scaleFactor": 100 }
```

---

## IoT / Time-Series Data

For MongoDB 5.0+, prefer native **time series collections**:
```javascript
db.createCollection("sensor_data", {
  timeseries: { timeField: "timestamp", metaField: "sensor_id", granularity: "minutes" }
})
```

For older versions, use the **Bucket Pattern** with pre-computed aggregates.

---

## Pattern Selection Quick Reference

| Use Case | Recommended Patterns |
|----------|---------------------|
| Content Management | Polymorphic, Schema Versioning, Document Versioning |
| E-commerce | Attribute, Extended Reference, Subset, Outlier |
| Analytics/Reporting | Approximation, Computed, Bucket |
| Hierarchical Data | Tree (choose variant), Polymorphic |
| Time-Series / IoT | Bucket, Computed, Approximation (or native time series) |
| User Profiles | Extended Reference, Schema Versioning |
| Financial / Compliance | Document Versioning, Computed, Decimal128 |
| Social / Activity Feeds | Subset, Outlier, Bucket |
| Product Catalogs | Attribute, Polymorphic, Subset |
| Data Warehousing | Slowly Changing Dimensions, Archive, Computed |
| Multi-entity Lookups | Single Collection, Extended Reference |

---

## Troubleshooting

### Document exceeds 16MB
**Cause**: An unbounded array is growing without limit.
1. Identify the array causing growth
2. Apply the Bucket or Subset pattern to split data into separate documents
3. Use parent references from the child side instead of storing child references in the parent

### $lookup performance degradation
**Cause**: Joining data that is always accessed together, or missing indexes on join fields.
1. Embed frequently-joined fields using the Extended Reference pattern
2. Verify both collections have indexes on the join fields
3. Check if collections are sharded — `$lookup` has limitations across shards

### Working set exceeds RAM
**Cause**: Documents contain large amounts of rarely-accessed data inflating memory usage.
1. Apply the Subset pattern to separate hot and cold data
2. Use projection to limit returned fields in queries
3. Review indexes — each index consumes RAM. Remove unused or redundant indexes

### Write contention on hot documents
**Cause**: A single document is updated very frequently by concurrent operations.
1. Separate volatile fields (counters, timestamps) from stable fields into different documents
2. Use the Approximation pattern for non-critical counters to reduce write frequency
3. Consider the Bucket pattern to distribute writes across multiple documents

---

## References

For source documentation and further reading, see `references/sources.md`.
For detailed schema validation guidance, see `references/schema-validation.md`.
For advanced design patterns (8-15), see `references/advanced-patterns.md`.

---

## Output Format

When presenting a data model, structure your response as:

### 1. Requirements Summary
Brief restatement of the user's requirements and key workload characteristics.

### 2. Collection Design
For each collection:
- **Name**: `collection_name`
- **Purpose**: What this collection stores
- **Example Document**:
```json
{ /* realistic sample document */ }
```
- **Indexes**:
```javascript
db.collection.createIndex({ /* index */ })  // Rationale
```

### 3. Patterns Applied
- Pattern name and why it was chosen for this specific use case

### 4. Schema Validation
```javascript
// JSON Schema validator for the collection
```

### 5. Relationship Map
Visual or textual representation of how collections relate (embed vs. reference).

### 6. Trade-offs and Considerations
- What was optimized (reads? writes? storage?)
- What trade-offs were made
- Growth projections and when to revisit the design

### 7. Migration Path (if applicable)
How to evolve from an existing schema to the proposed design.
