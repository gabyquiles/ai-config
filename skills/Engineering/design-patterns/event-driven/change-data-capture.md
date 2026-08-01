# Change Data Capture (CDC)

## Description

Instead of application code explicitly publishing events, a CDC tool watches a database's transaction/commit log directly and turns each row insert/update/delete into a published event. This lets you get event-driven integration out of an existing database-backed service without touching its code — the database itself becomes the event source.

## When to use it

- You need to integrate a legacy or third-party system that writes to a database but can't (or shouldn't) be modified to publish its own events.
- You want a guarantee that every state change is captured, including ones made by scripts, migrations, or other services writing directly to the database — not just changes that go through one code path that remembers to publish.
- You're migrating off a monolith's shared database incrementally and need other services to observe its data changes as events during the transition.

Be cautious: CDC events are shaped like database rows, not domain concepts — a raw "row updated" event often leaks internal schema details and columns that have nothing to do with the business meaning of the change (see: exposing too much information in your events). Prefer a service explicitly publishing well-designed domain events when you can; reach for CDC when you can't change the source.

## Related patterns

- [Event-Carried State Transfer](event-carried-state-transfer.md) — CDC is a common automated way to produce these events, since each row change already carries the new state.
- [Content Enricher](content-enricher.md) — CDC's raw row-change events often need enrichment before publishing, to translate database columns into meaningful domain fields.

## Example

```typescript
interface RowChange {
  table: string;
  operation: "INSERT" | "UPDATE" | "DELETE";
  row: Record<string, unknown>;
}

// Simulates a CDC connector tailing a database's commit log.
class ChangeDataCapture {
  private handlers: Array<(change: RowChange) => void> = [];

  onChange(handler: (change: RowChange) => void): void {
    this.handlers.push(handler);
  }

  // In a real system this fires from the DB's replication/binlog stream,
  // not from application code calling it directly.
  simulateCommittedChange(change: RowChange): void {
    this.handlers.forEach((h) => h(change));
  }
}

const cdc = new ChangeDataCapture();
cdc.onChange((change) => {
  if (change.table === "orders" && change.operation === "UPDATE") {
    console.log(`order row changed: ${JSON.stringify(change.row)}`);
  }
});

cdc.simulateCommittedChange({
  table: "orders",
  operation: "UPDATE",
  row: { id: "order-1", status: "shipped" },
});
```
