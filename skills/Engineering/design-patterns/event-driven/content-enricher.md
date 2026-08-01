# Content Enricher

## Description

Supplements an incoming message with additional data it doesn't already contain — often by looking up related information from another service or datastore — before passing the enriched message downstream. This keeps the producer's event lean (it only needs to know its own facts) while still letting downstream consumers get a complete, self-contained message without each of them independently querying for the missing piece.

## When to use it

- A producer's event is missing data that most or all downstream consumers need, and it's more efficient to fetch it once (in the enricher) than to have every consumer fetch it separately.
- The producer genuinely shouldn't know about the data being added — it belongs to a different bounded context or service.
- You want consumers to receive a single, self-contained message rather than requiring them to make follow-up calls.

Be cautious: an enricher that calls out to another service on every message introduces a synchronous dependency and latency into what was an asynchronous pipeline. If the lookup is slow or unreliable, consider whether the data belongs directly in the event instead (Event-Carried State Transfer) or whether the consumer can tolerate fetching it lazily.

## Related patterns

- [Message Translator](message-translator.md) — related but distinct: a translator reshapes existing data, an enricher adds new data that wasn't there before.
- [Decorator](../gof/decorator.md) — the in-process analog: both attach additional data/responsibility to something without changing its original shape or the code that produced it.

## Example

```typescript
interface OrderPlacedEvent {
  orderId: string;
  customerId: string;
}

interface EnrichedOrderPlacedEvent extends OrderPlacedEvent {
  customerTier: "standard" | "vip";
}

class CustomerLookup {
  private tiers = new Map<string, "standard" | "vip">([["cust-1", "vip"]]);
  getTier(customerId: string): "standard" | "vip" {
    return this.tiers.get(customerId) ?? "standard";
  }
}

class OrderContentEnricher {
  constructor(private customers: CustomerLookup) {}

  enrich(event: OrderPlacedEvent): EnrichedOrderPlacedEvent {
    return { ...event, customerTier: this.customers.getTier(event.customerId) };
  }
}

const enricher = new OrderContentEnricher(new CustomerLookup());
console.log(enricher.enrich({ orderId: "order-1", customerId: "cust-1" }));
// { orderId: "order-1", customerId: "cust-1", customerTier: "vip" }
```
