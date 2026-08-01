# Strategy

## Description

Defines a family of interchangeable algorithms, encapsulates each one behind a common interface, and makes them swappable independently of the client code that uses them. Instead of a client (or the algorithm's host object) branching on which variant to run, it holds a reference to a strategy object and delegates to it.

## When to use it

- You have several related variants of an algorithm (different sorting comparators, pricing rules, validation rules, compression schemes) and want to select between them without a conditional at every call site.
- You want to isolate an algorithm's implementation details from the code that uses it, so new variants can be added without modifying that code (open/closed principle).
- A class currently has multiple behaviors expressed as conditional logic, and those behaviors change independently of the rest of the class.

## Related patterns

- [State](state.md) — structurally identical, but Strategy is typically chosen by a client from outside and doesn't change itself over the object's lifetime, while State represents an object's own internal condition and transitions itself, usually driving its own changes.
- [Command](../gof/command.md) — both encapsulate behavior as an object, but Command represents a specific request to be executed (and possibly undone/queued/logged), while Strategy represents one member of an interchangeable family of algorithms performing the same kind of computation.
- [Template Method](template-method.md) — Template Method varies part of an algorithm via subclassing (inheritance); Strategy varies the *whole* algorithm via composition (a swappable object) — prefer Strategy when you need to change the algorithm at runtime rather than at compile time.
- [Content-Based Router](../event-driven/content-based-router.md) — the cross-service analog: both pick one of several algorithms/destinations based on input, but Strategy selects behavior for a single caller while a router directs messages between independent producers and consumers.

## Example

```typescript
interface PricingStrategy {
  price(baseAmountCents: number): number;
}

class StandardPricing implements PricingStrategy {
  price(baseAmountCents: number): number {
    return baseAmountCents;
  }
}

class MemberDiscountPricing implements PricingStrategy {
  price(baseAmountCents: number): number {
    return Math.round(baseAmountCents * 0.9);
  }
}

class BulkPricing implements PricingStrategy {
  price(baseAmountCents: number): number {
    return Math.round(baseAmountCents * 0.75);
  }
}

class Checkout {
  constructor(private strategy: PricingStrategy) {}

  setStrategy(strategy: PricingStrategy): void {
    this.strategy = strategy;
  }

  total(baseAmountCents: number): number {
    return this.strategy.price(baseAmountCents);
  }
}

const checkout = new Checkout(new StandardPricing());
console.log(checkout.total(1000)); // 1000

checkout.setStrategy(new MemberDiscountPricing());
console.log(checkout.total(1000)); // 900
```
