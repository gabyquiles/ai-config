# Message Translator

## Description

Converts a message from one format or schema into another as it moves between a producer and a consumer that don't natively agree on shape — e.g. translating a legacy XML event into the JSON schema the rest of the system expects, or mapping one service's field names to another's. The translator is a dedicated step so neither the producer nor the consumer needs to know about the other's format.

## When to use it

- A producer and consumer need to communicate but use incompatible message schemas, versions, or serialization formats, and neither side can (or should) change to match the other.
- You're integrating an external or legacy system whose message shape you don't control, and want to isolate that shape from the rest of your system.
- A schema is evolving and you need to translate between an old version and a new one during a migration window.

## Related patterns

- [Content Enricher](content-enricher.md) — related but distinct: a translator changes a message's *shape/format*, while an enricher adds *new data* the message didn't have.
- [Adapter](../gof/adapter.md) — the in-process analog: both convert one interface/shape into another that the consuming side expects, just applied to messages crossing a broker instead of objects within one process.

## Example

```typescript
interface LegacyOrderXmlShape {
  OrderID: string;
  CustomerEmail: string;
}

interface OrderPlacedEvent {
  type: "OrderPlaced";
  orderId: string;
  customerEmail: string;
}

class OrderMessageTranslator {
  translate(legacy: LegacyOrderXmlShape): OrderPlacedEvent {
    return {
      type: "OrderPlaced",
      orderId: legacy.OrderID,
      customerEmail: legacy.CustomerEmail,
    };
  }
}

const translator = new OrderMessageTranslator();
const event = translator.translate({ OrderID: "order-1", CustomerEmail: "a@b.com" });
console.log(event); // { type: "OrderPlaced", orderId: "order-1", customerEmail: "a@b.com" }
```
