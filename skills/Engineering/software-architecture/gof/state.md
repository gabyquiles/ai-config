# State

## Description

Lets an object alter its behavior when its internal state changes, so it appears to change its class. Each state is represented as its own class implementing a shared interface; the context object holds a reference to its current state object and delegates behavior to it, swapping that reference out as state transitions occur — replacing a large conditional (`switch (this.state)`) scattered across every method with polymorphism.

## When to use it

- An object's behavior depends on its state, and that behavior must change at runtime as the state changes.
- You have methods riddled with large conditionals that branch on a state field (order status, connection status, workflow stage), and those conditionals are duplicated across several methods and grow every time a new state is added.
- The valid transitions between states are meaningful and worth encoding explicitly, rather than leaving them implicit in scattered `if` checks.

## Related patterns

- [Strategy](strategy.md) — structurally identical (context holds a swappable object behind a shared interface), but the *intent* differs: Strategy lets a client choose an algorithm and is typically set once from outside; State represents an object's own internal state and transitions itself, usually without the client's involvement.
- [Bridge](../gof/bridge.md) — similar structural composition-over-inheritance shape, but State's implementations (states) know about and trigger transitions to each other; Bridge's implementations are unaware of and independent from one another.

## Example

```typescript
interface OrderState {
  next(order: Order): void;
  describe(): string;
}

class Placed implements OrderState {
  next(order: Order): void {
    order.setState(new Shipped());
  }
  describe(): string {
    return "placed";
  }
}

class Shipped implements OrderState {
  next(order: Order): void {
    order.setState(new Delivered());
  }
  describe(): string {
    return "shipped";
  }
}

class Delivered implements OrderState {
  next(): void {
    throw new Error("order already delivered");
  }
  describe(): string {
    return "delivered";
  }
}

class Order {
  private state: OrderState = new Placed();

  setState(state: OrderState): void {
    this.state = state;
  }

  advance(): void {
    this.state.next(this);
  }

  status(): string {
    return this.state.describe();
  }
}

const order = new Order();
order.advance(); // placed -> shipped
console.log(order.status()); // "shipped"
```
