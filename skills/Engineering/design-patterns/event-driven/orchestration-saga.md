# Orchestration Saga

## Description

Coordinates a multi-step process that spans several services with a single, explicit orchestrator object that calls each participant in sequence, tracks progress, and decides what to do next — including triggering compensating actions on other participants if a later step fails. Unlike Choreography, participants don't listen for each other's events; they simply do what the orchestrator tells them and report back.

## When to use it

- The process has enough steps, branches, or failure/compensation logic that you want one place to read and change the entire sequence, rather than reconstructing it from independent event handlers scattered across services.
- Failure handling is nontrivial — if step 3 fails, steps 1 and 2 need explicit compensating actions (refund a payment, release a reservation), and you want that logic centralized.
- You're willing to accept a new component (the orchestrator) that every participant now depends on, in exchange for that visibility and control.

Be cautious: the orchestrator can accumulate knowledge of every participant's API and become a bottleneck for change — every new step means editing the orchestrator, even if the participants themselves didn't change. If the process is simple and stable, Choreography Saga's decentralization avoids creating this dependency at all.

## Related patterns

- [Choreography Saga](choreography-saga.md) — the decentralized alternative: participants react to each other's events directly, with no central coordinator to depend on or bottleneck through.
- [Mediator](../gof/mediator.md) — the in-process analog: both centralize coordination of multiple participants in one object so those participants don't need to know about each other, just about the coordinator.

## Example

```typescript
class OrderSagaOrchestrator {
  constructor(
    private payments: { charge(orderId: string): boolean; refund(orderId: string): void },
    private shipping: { ship(orderId: string): boolean },
  ) {}

  // The orchestrator explicitly directs each step and its compensation —
  // no participant needs to know about the others.
  run(orderId: string): void {
    const charged = this.payments.charge(orderId);
    if (!charged) return;

    const shipped = this.shipping.ship(orderId);
    if (!shipped) {
      this.payments.refund(orderId); // explicit compensation for step 1
    }
  }
}

const saga = new OrderSagaOrchestrator(
  { charge: () => true, refund: (orderId) => console.log(`refunded ${orderId}`) },
  { ship: () => false }, // simulate a shipping failure to trigger compensation
);

saga.run("order-1"); // logs "refunded order-1"
```
