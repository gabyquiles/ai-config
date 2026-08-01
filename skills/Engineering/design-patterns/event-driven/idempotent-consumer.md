# Idempotent Consumer

## Description

A consumer is built so that processing the same message more than once produces the same result as processing it exactly once — reapplying it is safe. This matters because most brokers offer at-least-once delivery: retries, redelivery after a crash, or network hiccups mean a consumer should expect to see the same message again and must not, for example, double-charge a customer or double-decrement inventory when that happens.

## When to use it

- You're consuming from a broker or queue that guarantees at-least-once delivery (the overwhelming majority of them), which means duplicate delivery is a normal, expected case — not a rare edge case.
- The operation a message triggers isn't naturally idempotent on its own (e.g. "add $10 to balance" is not idempotent; "set balance to $110" or "apply transaction #4521 if not already applied" is).
- You're using Competing Consumers, where crash-and-redeliver semantics make duplicate delivery more likely.

## Related patterns

- [Competing Consumers](competing-consumers.md) — the most common reason a consumer needs to be idempotent: crashed or timed-out consumers cause their in-flight messages to be redelivered to another instance.

## Example

```typescript
interface PaymentAppliedEvent {
  transactionId: string; // stable identity of this exact operation
  amountCents: number;
}

class IdempotentPaymentConsumer {
  private processedTransactionIds = new Set<string>();
  private balanceCents = 0;

  handle(event: PaymentAppliedEvent): void {
    if (this.processedTransactionIds.has(event.transactionId)) {
      return; // already applied — safe to ignore a redelivered duplicate
    }
    this.balanceCents += event.amountCents;
    this.processedTransactionIds.add(event.transactionId);
  }
}

const consumer = new IdempotentPaymentConsumer();
const event = { transactionId: "txn-1", amountCents: 500 };
consumer.handle(event);
consumer.handle(event); // redelivered duplicate — balance is unaffected
```
