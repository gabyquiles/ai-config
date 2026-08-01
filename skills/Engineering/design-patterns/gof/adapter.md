# Adapter

## Description

Converts the interface of a class into another interface that clients expect. An Adapter lets classes work together that otherwise couldn't because of incompatible interfaces, by wrapping the incompatible class and translating calls to it.

## When to use it

- You want to use an existing class (often third-party, or legacy, or otherwise not yours to change) but its interface doesn't match what the rest of your code expects.
- You're integrating multiple subsystems or libraries that were designed independently and use different shapes for conceptually the same operation.
- You need a stable interface at a boundary in your code, and want to isolate the churn/quirks of an external dependency behind that boundary rather than letting them leak throughout the codebase.

## Related patterns

- [Facade](facade.md) — both wrap something else, but Facade *simplifies* a broad interface for convenience, while Adapter *translates* one specific interface into another that's already expected — Facade defines a new, simpler API; Adapter conforms to an existing one.
- [Bridge](bridge.md) — Bridge is designed up front to let abstraction and implementation vary independently; Adapter is typically applied after the fact, to make incompatible existing interfaces work together.
- [Decorator](decorator.md) — Decorator keeps the same interface and adds behavior; Adapter changes the interface.
- [Message Translator](../event-driven/message-translator.md) — the cross-service analog: both convert one interface/format into another the consuming side expects, just applied to messages crossing a broker instead of objects within one process.

## Example

```typescript
// The interface our code expects everywhere.
interface PaymentProcessor {
  charge(amountCents: number): Promise<void>;
}

// A third-party SDK with an incompatible interface we don't control.
class LegacyBillingSdk {
  async makePayment(dollars: number, cents: number): Promise<{ ok: boolean }> {
    console.log(`Legacy charge: $${dollars}.${cents}`);
    return { ok: true };
  }
}

class LegacyBillingAdapter implements PaymentProcessor {
  constructor(private readonly legacy: LegacyBillingSdk) {}

  async charge(amountCents: number): Promise<void> {
    const dollars = Math.floor(amountCents / 100);
    const cents = amountCents % 100;
    const result = await this.legacy.makePayment(dollars, cents);
    if (!result.ok) throw new Error("charge failed");
  }
}

// Rest of the codebase only ever depends on PaymentProcessor.
const processor: PaymentProcessor = new LegacyBillingAdapter(new LegacyBillingSdk());
await processor.charge(1999);
```
