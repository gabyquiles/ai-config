# Event-Carried State Transfer

## Description

The producer publishes an event that carries the full data a consumer needs, not just a fact that something happened. Consumers keep their own local copy of that data, updated as events arrive, so they never need to call back to the producer at read time. This trades data duplication (and the work of keeping replicas in sync) for consumer-side autonomy — each consumer can serve reads even if the producer is completely unavailable.

## When to use it

- Consumers need the producer's data on the hot path of their own requests, and a synchronous callback to the producer would be too slow or too fragile.
- You want to eliminate a runtime dependency between services — a consumer's availability shouldn't depend on the producer being up.
- The data is read far more often than it changes, so keeping a local, eventually-consistent replica is worth the sync complexity.

Be cautious: every consumer that keeps a copy now owns a replica that can drift or go stale, and the "who has the freshest data" question gets harder to answer with more replicas. If you don't need the data locally on every read, Event Notification's callback approach avoids this duplication entirely.

## Related patterns

- [Event Notification](event-notification.md) — the fact-only counterpart; use it when consumers can afford to call back for details instead of keeping a local copy.
- [Change Data Capture](change-data-capture.md) — a common way to *produce* these state-transfer events automatically, by turning database row changes into published events.

## Example

```typescript
interface OrderShippedEvent {
  type: "OrderShipped";
  orderId: string;
  customerEmail: string;
  trackingNumber: string;
  items: Array<{ sku: string; quantity: number }>;
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

// Consumer keeps its own local replica, populated entirely from events —
// it never calls back to the Order service to read shipment details.
class ShipmentTrackingReplica {
  private shipments = new Map<string, OrderShippedEvent>();

  constructor(bus: EventBus) {
    bus.subscribe((event) => this.shipments.set(event.orderId, event));
  }

  getTrackingNumber(orderId: string): string | undefined {
    return this.shipments.get(orderId)?.trackingNumber;
  }
}
```
