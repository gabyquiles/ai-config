# Event Notification

## Description

A producer publishes a small, fact-only event ("OrderShipped", "UserRegistered") announcing that something happened, without including the full data behind it. Consumers that care about the fact react to it, then — if they need more detail than the event carries — call back to the producer (or a shared source of truth) to fetch it. The producer doesn't know or care who's listening, or what they do in response; it only guarantees that the fact was broadcast.

## When to use it

- Other services need to react to something happening, but don't need to duplicate the producer's full state to do so.
- You want to decouple producer from consumers so new reactions can be added without changing the producer.
- The event's payload can stay minimal (mostly an ID and a type) because consumers already have — or can cheaply fetch — the rest.

Be cautious: because consumers must call back for details, this reintroduces a runtime dependency on the producer being available. If that callback becomes the bottleneck, or consumers need the data even when the producer is down, Event-Carried State Transfer removes that dependency by pushing the data along with the event.

## Related patterns

- [Event-Carried State Transfer](event-carried-state-transfer.md) — same broadcast mechanism, but carries the full state payload instead of just a fact, removing the callback dependency at the cost of data duplication.
- [Observer](../gof/observer.md) — the in-process analog: Event Notification is Observer's subject/observer relationship stretched across process and service boundaries via a broker.

## Example

```typescript
interface OrderShippedEvent {
  type: "OrderShipped";
  orderId: string;
}

class EventBus {
  private handlers: Array<(event: OrderShippedEvent) => void> = [];

  subscribe(handler: (event: OrderShippedEvent) => void): void {
    this.handlers.push(handler);
  }

  publish(event: OrderShippedEvent): void {
    for (const handler of this.handlers) {
      handler(event);
    }
  }
}

// Producer only announces the fact — no shipment details included.
class OrderService {
  constructor(private bus: EventBus) {}

  ship(orderId: string): void {
    this.bus.publish({ type: "OrderShipped", orderId });
  }
}

// Consumer reacts to the fact, fetching details only if it needs them.
class NotificationService {
  constructor(private bus: EventBus, private orders: OrderService) {}

  listen(): void {
    this.bus.subscribe((event) => {
      console.log(`sending shipment email for order ${event.orderId}`);
    });
  }
}
```
