# Event Sourcing

## Description

Instead of persisting only the current state of an entity, every state change is appended to an ordered, immutable log of events (e.g. "AccountOpened", "FundsDeposited", "FundsWithdrawn"). Current state is never stored directly — it's derived by replaying an entity's events from the start (or from a snapshot) and folding them into a value. The event log becomes the single source of truth; any current-state view is just one possible projection of it.

## When to use it

- You need a complete, trustworthy audit trail of every change to an entity — not just its current value, but exactly how it got there.
- You want to derive multiple different read views (projections) from the same history without changing how writes happen.
- You need to reconstruct past state ("what did this account look like last Tuesday?") or replay history to rebuild a projection after a bug fix.

Be cautious: this is a significant commitment. Querying "current state" requires either replaying events on every read or maintaining separate projections (see CQRS), schema changes to event shapes must stay backward-compatible forever, and the mental model is unfamiliar to teams used to CRUD. Don't reach for it just because audit logging sounds nice — a simple append-only audit table alongside normal CRUD is often enough.

## Related patterns

- [CQRS](cqrs.md) — nearly always paired with Event Sourcing: the event log is the write model, and one or more projections built from it serve as read models.
- [Memento](../gof/memento.md) — both capture state so it can be restored later, but Memento snapshots one object's state at a point in time, while Event Sourcing stores the full sequence of changes and derives state by replaying them.

## Example

```typescript
type AccountEvent =
  | { type: "AccountOpened"; accountId: string }
  | { type: "FundsDeposited"; amount: number }
  | { type: "FundsWithdrawn"; amount: number };

class AccountEventStore {
  private events: AccountEvent[] = [];

  append(event: AccountEvent): void {
    this.events.push(event);
  }

  // Current state is derived, never stored directly.
  currentBalance(): number {
    return this.events.reduce((balance, event) => {
      if (event.type === "FundsDeposited") return balance + event.amount;
      if (event.type === "FundsWithdrawn") return balance - event.amount;
      return balance;
    }, 0);
  }
}

const store = new AccountEventStore();
store.append({ type: "AccountOpened", accountId: "acc-1" });
store.append({ type: "FundsDeposited", amount: 100 });
store.append({ type: "FundsWithdrawn", amount: 30 });

console.log(store.currentBalance()); // 70, derived by replaying the log
```
