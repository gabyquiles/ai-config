# Content-Based Router

## Description

Inspects an incoming message's content (its type, a header, a field value) and routes it to one of several possible destinations based on that inspection, instead of every consumer receiving every message and filtering for itself. The router centralizes the routing decision so producers don't need to know which destination a message should go to, and consumers only ever receive messages meant for them.

## When to use it

- Different message shapes or categories need to go to different downstream handlers, and you don't want every handler subscribed to the full firehose just to discard most of it.
- Routing logic (which destination handles which kind of message) changes independently of the producers and consumers, and should live in one place rather than duplicated in every consumer's filter.
- You're building a pipeline where messages branch based on business rules (e.g. high-value orders route to a fraud-review queue, others go straight to fulfillment).

## Related patterns

- [Splitter](splitter.md) — often used together: a Splitter breaks a compound message into parts, and a Content-Based Router then sends each part to the right destination.
- [Strategy](../gof/strategy.md) — the in-process analog: both pick one of several algorithms/destinations based on input, but Strategy selects behavior for a single caller while a router directs messages between independent producers and consumers.

## Example

```typescript
interface Order {
  id: string;
  totalCents: number;
}

class ContentBasedRouter {
  route(order: Order): string {
    if (order.totalCents > 100_000) return "fraud-review-queue";
    return "fulfillment-queue";
  }
}

const router = new ContentBasedRouter();
const destination = router.route({ id: "order-1", totalCents: 150_000 });
console.log(destination); // "fraud-review-queue"
```
