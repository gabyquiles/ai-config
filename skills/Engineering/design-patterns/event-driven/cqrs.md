# CQRS (Command Query Responsibility Segregation)

## Description

Splits an entity's write model from its read model(s), instead of using one shared model for both. Commands (writes) go through a model optimized for validating and applying changes; queries (reads) hit a separate model — often a denormalized projection — optimized for how the data is actually displayed or searched. The two models are usually kept in sync via events published from the write side.

## When to use it

- Read and write workloads have very different shapes (e.g. writes are narrow and transactional, reads need denormalized joins across many entities for a dashboard) and a single shared model is a compromise for both.
- Read and write sides need to scale independently — e.g. reads are 100x more frequent than writes and need their own caching/indexing strategy.
- You're already using Event Sourcing and need queryable current-state views, since the event log itself isn't efficient to query directly.

Be cautious: CQRS introduces eventual consistency between the write and read models (a write may not be visible in the read model instantly) and doubles the number of models to maintain. It's overkill for simple CRUD where one model comfortably serves both reads and writes — don't adopt it as a default.

## Related patterns

- [Event Sourcing](event-sourcing.md) — frequently paired: the event log is the write model, and read-model projections are built by folding those events into query-friendly shapes.
- [Command](../gof/command.md) — CQRS's write side is naturally modeled as Command objects, each encapsulating one request to change state.

## Example

```typescript
interface CreateOrderCommand {
  orderId: string;
  items: string[];
}

// Write model: validates and applies the change, then announces it.
class OrderWriteModel {
  constructor(private bus: EventBus) {}

  handle(command: CreateOrderCommand): void {
    // validation would go here
    this.bus.publish({ type: "OrderCreated", ...command });
  }
}

interface OrderCreatedEvent {
  type: "OrderCreated";
  orderId: string;
  items: string[];
}

class EventBus {
  private handlers: Array<(e: OrderCreatedEvent) => void> = [];
  subscribe(h: (e: OrderCreatedEvent) => void): void {
    this.handlers.push(h);
  }
  publish(e: OrderCreatedEvent): void {
    this.handlers.forEach((h) => h(e));
  }
}

// Read model: a denormalized projection built for fast lookups, not writes.
class OrderSummaryReadModel {
  private summaries = new Map<string, { itemCount: number }>();

  constructor(bus: EventBus) {
    bus.subscribe((e) => this.summaries.set(e.orderId, { itemCount: e.items.length }));
  }

  getSummary(orderId: string) {
    return this.summaries.get(orderId);
  }
}
```
