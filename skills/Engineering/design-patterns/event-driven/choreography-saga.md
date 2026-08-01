# Choreography Saga

## Description

Coordinates a multi-step process that spans several services by having each service react to events published by the others, with no central coordinator. Each participant knows only what event to listen for and what event to emit next (or what compensating action to take on failure) — the overall sequence emerges from these independent reactions rather than being directed by any one place.

## When to use it

- The steps in the process are owned by genuinely independent services/teams, and you want to preserve that independence rather than introduce a central component they all depend on.
- The number of steps is small and stable enough that "the sequence emerges from independent reactions" stays easy to follow.
- You're comfortable that no single place in the code describes the whole process, and are willing to reconstruct it by tracing events across services when debugging.

Be cautious: as steps are added, choreography's biggest weakness shows up — there's no single place to read "what happens, in order, and what happens if step 3 fails." Tracing a failure means jumping across every participating service's event handlers. Once that tracing burden outweighs the benefit of decentralization, Orchestration Saga's explicit coordinator becomes the better trade.

## Related patterns

- [Orchestration Saga](orchestration-saga.md) — the centralized alternative: a single coordinator directs each step explicitly instead of participants reacting to each other's events.
- [Chain of Responsibility](../gof/chain-of-responsibility.md) — the in-process analog: both decentralize handling across independent participants, each deciding locally whether/how to react, rather than a central object dictating the sequence.

## Example

```typescript
type SagaEvent =
  | { type: "OrderPlaced"; orderId: string }
  | { type: "PaymentCharged"; orderId: string };

class EventBus {
  private handlers: Array<(e: SagaEvent) => void> = [];
  subscribe(h: (e: SagaEvent) => void): void {
    this.handlers.push(h);
  }
  publish(e: SagaEvent): void {
    this.handlers.forEach((h) => h(e));
  }
}

// Each service only knows what it listens for and what it emits next —
// no participant knows about the saga as a whole.

class OrderService {
  constructor(private bus: EventBus) {}
  placeOrder(orderId: string): void {
    this.bus.publish({ type: "OrderPlaced", orderId });
  }
}

class PaymentService {
  constructor(private bus: EventBus) {
    bus.subscribe((e) => {
      if (e.type === "OrderPlaced") {
        this.bus.publish({ type: "PaymentCharged", orderId: e.orderId });
      }
    });
  }
}

class ShippingService {
  constructor(bus: EventBus) {
    bus.subscribe((e) => {
      if (e.type === "PaymentCharged") {
        console.log(`shipping order ${e.orderId}`);
      }
    });
  }
}

const bus = new EventBus();
new PaymentService(bus);
new ShippingService(bus);

new OrderService(bus).placeOrder("order-1");
// logs "shipping order order-1" — the sequence emerged from three
// independent reactions, with no coordinator directing it.
```
