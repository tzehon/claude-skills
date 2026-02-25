# Advanced Design Patterns

These patterns are less commonly used but valuable for specific use cases. For the core patterns (Computed, Approximation, Attribute, Bucket, Subset, Extended Reference, Outlier), see the main SKILL.md.

## 8. Document Versioning Pattern

**Problem**: Need to maintain historical versions of documents for auditing, compliance, or undo functionality.

**Solution**: Use two collections — current (latest version) and history (all previous versions). Add a `version` field.

**When to use**: Insurance policies, legal documents, content management, regulatory compliance.

**Current collection (policies)**:
```json
{
  "_id": "policy1",
  "policyNumber": "POL-2024-001",
  "holderName": "Jane Smith",
  "coverageAmount": 500000,
  "version": 3,
  "lastModified": ISODate("2024-01-15T10:30:00Z")
}
```

**History collection (policiesHistory)**:
```json
{
  "_id": ObjectId("..."),
  "docId": "policy1",
  "policyNumber": "POL-2024-001",
  "holderName": "Jane Smith",
  "coverageAmount": 250000,
  "version": 1,
  "lastModified": ISODate("2023-06-01T09:00:00Z")
}
```

**Update workflow**: Copy current to history, then update current with incremented version.

**Trade-offs**: Increased storage; write overhead; not suitable for high-churn documents.

---

## 9. Schema Versioning Pattern

**Problem**: Database schema must evolve without application downtime. Old and new document structures coexist.

**Solution**: Add a `schema_version` field. Implement application-level handlers for each version. Migrate lazily or eagerly.

**When to use**: Any evolving production system; frequent schema changes; zero-downtime deployments.

```json
// Version 1
{ "_id": "user1", "name": "Anakin Skywalker", "home": "503-555-0000", "work": "503-555-0010" }

// Version 2 (restructured with Attribute Pattern)
{
  "_id": "user2", "schema_version": 2, "name": "Anakin Skywalker",
  "contact_methods": [
    { "type": "work", "value": "503-555-0210" },
    { "type": "mobile", "value": "503-555-0220" },
    { "type": "twitter", "value": "@anakinskywalker" }
  ]
}
```

**Migration strategies**: Lazy (migrate on read/write), eager (batch update all), or no migration.

**Trade-offs**: App must handle multiple versions; may need dual indexes during migration.

---

## 10. Polymorphic Pattern

**Problem**: Documents of different types with similar-but-not-identical structures need to be queried together.

**Solution**: Store all types in a single collection with a discriminator field (`type`). Shared fields use consistent names.

**When to use**: Product catalogs (books, electronics, clothing), athletes in different sports, vehicles.

```json
// Tennis player
{ "_id": "a1", "type": "tennis", "name": "Serena Williams", "ranking": 1, "grandSlams": 23 }

// Soccer player
{ "_id": "a2", "type": "soccer", "name": "Lionel Messi", "ranking": 1, "goalsScored": 800 }
```

**Partial index for type-specific queries**:
```javascript
db.athletes.createIndex({ goalsScored: -1 }, { partialFilterExpression: { type: "soccer" } })
```

**Trade-offs**: Application must handle different document shapes; not ideal if types have no fields in common.

---

## 11. Inheritance Pattern

**Problem**: Object-oriented class hierarchies need to be persisted in MongoDB.

**Solution**: Store the full inheritance hierarchy in a single collection. Each document contains fields from its class and all parent classes. Use a discriminator field for the concrete type.

**When to use**: OOP applications with class hierarchies needing polymorphic queries.

```json
// Car (extends Vehicle)
{ "_id": "v1", "type": "car", "make": "Toyota", "model": "Camry", "year": 2024, "numDoors": 4 }

// Truck (extends Vehicle)
{ "_id": "v2", "type": "truck", "make": "Ford", "model": "F-150", "year": 2024, "towingCapacityKg": 6000 }
```

---

## 12. Preallocation Pattern

**Problem**: Known data structures that will be filled incrementally (e.g., seating charts, game boards).

**Solution**: Pre-create the document structure with empty/default values for O(1) index-based access.

**When to use**: Theater seating, game boards, calendars, inventory grids.

```json
{
  "_id": "show1",
  "theater": "Main Theater",
  "seats": [
    [
      { "row": "A", "number": 1, "status": "available" },
      { "row": "A", "number": 2, "status": "reserved" }
    ],
    [
      { "row": "B", "number": 1, "status": "available" },
      { "row": "B", "number": 2, "status": "available" }
    ]
  ]
}
```

Finding seat "B2" is `seats[1][1]` — O(1) lookup instead of linear search.

**Trade-offs**: Empty positions consume storage; larger documents increase RAM usage.

---

## 13. Slowly Changing Dimensions Pattern

**Problem**: Dimension attributes change over time and historical values must be preserved for analytics.

**Solution**: Apply SCD types from data warehousing:

**Type 2 (most common) — New record per change with date ranges**:
```json
{ "customerId": "cust1", "name": "Jane", "address": "123 Main St", "effectiveFrom": ISODate("2020-01-01"), "effectiveTo": ISODate("2024-01-14"), "isCurrent": false }
{ "customerId": "cust1", "name": "Jane", "address": "456 Oak Ave", "effectiveFrom": ISODate("2024-01-15"), "effectiveTo": null, "isCurrent": true }
```

**Point-in-time query**:
```javascript
db.customers.findOne({
  customerId: "cust1",
  effectiveFrom: { $lte: targetDate },
  $or: [{ effectiveTo: { $gt: targetDate } }, { effectiveTo: null }]
})
```

---

## 14. Archive Pattern

**Problem**: Collections accumulate rarely-accessed data that degrades performance.

**Solution**: Move old documents to an archive collection or cheaper storage tier.

```javascript
// Archive orders older than 2 years
const cutoff = new Date(); cutoff.setFullYear(cutoff.getFullYear() - 2);
db.orders.aggregate([
  { $match: { date: { $lt: cutoff }, status: "delivered" } },
  { $addFields: { archivedDate: new Date() } },
  { $merge: { into: "ordersArchive", whenMatched: "keepExisting" } }
]);
db.orders.deleteMany({ date: { $lt: cutoff }, status: "delivered" });
```

**Query across both with `$unionWith`**:
```javascript
db.orders.aggregate([
  { $match: { customerId: "cust1" } },
  { $unionWith: { coll: "ordersArchive", pipeline: [{ $match: { customerId: "cust1" } }] } },
  { $sort: { date: -1 } }
])
```

---

## 15. Single Collection Pattern

**Problem**: Multiple related entity types are frequently queried together, requiring expensive `$lookup` operations.

**Solution**: Store multiple entity types in a single collection with composite partition/sort keys and a type discriminator.

```json
// Product
{ "pk": "PRODUCT#prod1", "sk": "METADATA", "type": "product", "name": "Widget", "price": 29.99 }

// Review for that product
{ "pk": "PRODUCT#prod1", "sk": "REVIEW#2024-01-15#user1", "type": "review", "rating": 5, "text": "Great!" }
```

**Index**: `{ pk: 1, sk: 1 }`

**Query product + all reviews in one query**:
```javascript
db.entities.find({ pk: "PRODUCT#prod1" }).sort({ sk: 1 })
```

**Trade-offs**: Increased schema complexity; harder ad-hoc queries; requires upfront key design.
