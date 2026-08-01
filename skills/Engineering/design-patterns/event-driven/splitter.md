# Splitter

## Description

Breaks a single compound message containing many items into multiple individual messages, one per item, so downstream consumers and routing logic can operate on each item independently rather than every consumer having to unpack the batch themselves. A common counterpart, the Aggregator, does the reverse — combining many related messages back into one — but the Splitter's job is strictly decomposition.

## When to use it

- An incoming message is a batch or collection (a bulk order with many line items, a CSV upload with many rows) but downstream processing, retries, or routing needs to happen per-item.
- You want a failure in processing one item to be isolated from the others, instead of one bad item failing the entire batch.
- Different items in the same batch may need to go to different destinations, which only works cleanly once they're separate messages (often paired with a Content-Based Router).

Be cautious: splitting loses the batch's original grouping unless you carry a correlation ID on each resulting message, which you'll need if anything downstream (an Aggregator, a completion check) needs to know when all the pieces from one batch have been processed.

## Related patterns

- [Content-Based Router](content-based-router.md) — frequently chained after a Splitter, to route each resulting item to the destination appropriate for its content.

## Example

```typescript
interface BulkOrderMessage {
  batchId: string;
  items: Array<{ sku: string; quantity: number }>;
}

interface OrderItemMessage {
  batchId: string; // correlation ID back to the original batch
  sku: string;
  quantity: number;
}

class OrderSplitter {
  split(bulk: BulkOrderMessage): OrderItemMessage[] {
    return bulk.items.map((item) => ({ batchId: bulk.batchId, ...item }));
  }
}

const splitter = new OrderSplitter();
const messages = splitter.split({
  batchId: "batch-1",
  items: [{ sku: "widget", quantity: 3 }, { sku: "gadget", quantity: 1 }],
});
console.log(messages.length); // 2, each independently processable
```
