# Schema Validation Reference

Detailed reference for MongoDB schema validation using JSON Schema (`$jsonSchema`) and query expression validators.

## Creating a Validator with JSON Schema

```javascript
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      title: "User Validation",
      required: ["name", "email", "schema_version"],
      properties: {
        name: { bsonType: "string", description: "User's full name" },
        email: { bsonType: "string", pattern: "^.+@.+$", description: "Valid email address" },
        schema_version: { bsonType: "int", minimum: 1 },
        age: { bsonType: "int", minimum: 0, maximum: 150, description: "Age in years" },
        status: { enum: ["active", "inactive", "suspended", null], description: "Account status" },
        addresses: {
          bsonType: "array",
          maxItems: 10,
          items: {
            bsonType: "object",
            required: ["street", "city"],
            properties: {
              street: { bsonType: "string" },
              city: { bsonType: "string" },
              state: { bsonType: "string" },
              zip: { bsonType: "string", pattern: "^[0-9]{5}(-[0-9]{4})?$" }
            }
          }
        }
      }
    }
  }
})
```

## Supported JSON Schema Keywords

- **Type**: `bsonType` — validates BSON type (`"string"`, `"int"`, `"long"`, `"double"`, `"decimal"`, `"bool"`, `"date"`, `"object"`, `"array"`, `"objectId"`, `"null"`, `"number"` alias for int/long/double/decimal)
- **Required fields**: `required` — array of field names that must exist
- **Properties**: `properties` — per-field validation rules
- **Additional properties**: `additionalProperties` — `false` to reject fields not in `properties`
- **Numeric range**: `minimum`, `maximum`, `exclusiveMinimum`, `exclusiveMaximum`
- **String constraints**: `minLength`, `maxLength`, `pattern` (regex)
- **Array constraints**: `minItems`, `maxItems`, `uniqueItems`, `items` (per-item schema)
- **Enum**: `enum` — restrict to allowed values
- **Logical composition**: `allOf`, `anyOf`, `oneOf`, `not`
- **Metadata**: `title`, `description` — documentation (shown in error messages)

## Specifying Allowed Field Values

Use `enum` for fixed sets of values:
```javascript
{ status: { enum: ["draft", "published", "archived"], description: "Document status" } }
```

Use `minimum`/`maximum` for numeric ranges:
```javascript
{ rating: { bsonType: "int", minimum: 1, maximum: 5 } }
```

Use `pattern` for string format validation:
```javascript
{ phone: { bsonType: "string", pattern: "^\\+?[1-9]\\d{1,14}$" } }
```

## Query Expression Validators

For validations that cannot be expressed in JSON Schema, use query operators:

```javascript
db.createCollection("sales", {
  validator: {
    $and: [
      { quantity: { $gte: 0 } },
      { price: { $gte: 0 } },
      { item: { $type: "string" } },
      { $expr: { $lte: ["$discountPrice", "$price"] } }
    ]
  }
})
```

## Combining JSON Schema with Query Conditions

Use `$jsonSchema` alongside query operators for complex rules:
```javascript
db.createCollection("orders", {
  validator: {
    $and: [
      {
        $jsonSchema: {
          bsonType: "object",
          required: ["item", "quantity", "price"],
          properties: {
            item: { bsonType: "string" },
            quantity: { bsonType: "int", minimum: 1 },
            price: { bsonType: "decimal" }
          }
        }
      },
      { $expr: { $lte: ["$discountPrice", "$price"] } }
    ]
  }
})
```

## Validation Levels

| Level | Behavior |
|-------|----------|
| `"strict"` (default) | Validates all inserts and updates |
| `"moderate"` | Validates inserts and updates to documents that already satisfy the rules. Skips validation for updates to documents that already violate rules (useful during migration) |

```javascript
db.runCommand({ collMod: "users", validator: { /* ... */ }, validationLevel: "moderate" })
```

## Validation Actions

| Action | Behavior |
|--------|----------|
| `"error"` (default) | Rejects writes that violate validation rules |
| `"warn"` | Logs a warning but allows the write to proceed |

```javascript
db.runCommand({ collMod: "users", validator: { /* ... */ }, validationAction: "warn" })
```

## Handling Invalid Documents

When adding validation to an existing collection with non-conforming documents:

1. Start with `validationAction: "warn"` to identify violations without blocking writes
2. Use `validationLevel: "moderate"` so existing invalid documents can still be updated
3. Fix invalid documents over time
4. Graduate to `validationLevel: "strict"` and `validationAction: "error"` once clean

## Bypassing Validation

Some operations can bypass validation using `bypassDocumentValidation: true`:
```javascript
db.collection.insertOne({ /* invalid doc */ }, { bypassDocumentValidation: true })
```

Available on: `insert`, `update`, `findAndModify`, `$out`, `$merge`, `mapReduce`. Requires the `bypassDocumentValidation` privilege. Useful for admin/migration scripts.

## Viewing Existing Validation Rules

```javascript
db.getCollectionInfos({ name: "users" })
// Returns validator, validationLevel, validationAction in the options field
```

## Updating Validation Rules

```javascript
db.runCommand({
  collMod: "users",
  validator: { $jsonSchema: { /* new schema */ } },
  validationLevel: "strict",
  validationAction: "error"
})
```

## Validating Polymorphic Collections

For collections with multiple document types (Polymorphic Pattern), use `oneOf` or conditional validation:

**Using `oneOf`** — each document must match exactly one sub-schema:
```javascript
db.createCollection("vehicles", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["type", "make", "model", "year"],
      properties: {
        type: { enum: ["car", "truck", "motorcycle"] },
        make: { bsonType: "string" },
        model: { bsonType: "string" },
        year: { bsonType: "int", minimum: 1900 }
      },
      oneOf: [
        {
          properties: { type: { const: "car" }, numDoors: { bsonType: "int" } },
          required: ["numDoors"]
        },
        {
          properties: { type: { const: "truck" }, towingCapacityKg: { bsonType: "int" } },
          required: ["towingCapacityKg"]
        },
        {
          properties: { type: { const: "motorcycle" }, engineCC: { bsonType: "int" } },
          required: ["engineCC"]
        }
      ]
    }
  }
})
```

**Using `if/then/else`** (MongoDB 5.0+):
```javascript
{
  if: { properties: { type: { const: "car" } } },
  then: { required: ["numDoors"], properties: { numDoors: { bsonType: "int" } } },
  else: {
    if: { properties: { type: { const: "truck" } } },
    then: { required: ["towingCapacityKg"] }
  }
}
```

## JSON Schema Tips

1. Use `description` fields — they appear in validation error messages, making debugging easier
2. Use `title` on the top-level schema to identify which validator failed
3. Set `additionalProperties: false` only when you want strict control — it prevents any fields not listed in `properties`
4. Arrays of allowed BSON types: `{ bsonType: ["string", "null"] }` — allows either string or null
5. For optional fields, do not put them in `required` — they are only validated if present
6. Test validators before production: `db.collection.validate()` checks existing documents against rules

## Best Practices

1. **Start permissive**: `validationAction: "warn"` + `validationLevel: "moderate"` for existing collections
2. **Tighten gradually**: Move to `"strict"` + `"error"` once data is clean
3. **Include descriptive metadata**: `title` and `description` on every property
4. **Validate polymorphic collections**: Use `oneOf` with the discriminator field to enforce per-type rules
5. **Version your validators**: When using Schema Versioning Pattern, update the validator alongside your application code
6. **Don't over-constrain**: Only validate what matters for data integrity — overly strict schemas make evolution harder
