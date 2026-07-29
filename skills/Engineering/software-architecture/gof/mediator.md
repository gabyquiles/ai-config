# Mediator

## Description

Defines an object that encapsulates how a set of other objects interact, so those objects communicate only through the mediator instead of referring to each other directly. This replaces a tangle of many-to-many references between peer objects with a single hub-and-spoke relationship, centralizing interaction logic in one place.

## When to use it

- A set of objects communicate in complex, tangled ways, and it's hard to understand or change one object's behavior without understanding all the others it references (a "spaghetti" of direct peer-to-peer references).
- You want to reuse an object independently, but it's tightly coupled to several others through direct references — introducing a mediator lets you decouple it, since it now only needs to know about the mediator.
- Interaction logic (what should happen when X changes) belongs conceptually in one place rather than scattered across every participant.

## Related patterns

- [Facade](../gof/facade.md) — both introduce an intermediary, but Facade is a one-directional simplification for outside callers who don't participate in the subsystem; Mediator coordinates two-way communication *between* peer objects that all know about and talk through it.
- [Observer](observer.md) — Mediator is frequently implemented using Observer: colleagues notify the mediator of changes (as observers would), and the mediator decides how to react and whom else to notify.

## Example

```typescript
interface Mediator {
  notify(sender: string, event: string): void;
}

class DialogMediator implements Mediator {
  private submitEnabled = false;

  notify(sender: string, event: string): void {
    if (sender === "checkbox" && event === "checked") {
      this.submitEnabled = true;
      console.log("submit button enabled");
    }
    if (sender === "checkbox" && event === "unchecked") {
      this.submitEnabled = false;
      console.log("submit button disabled");
    }
  }
}

class Checkbox {
  constructor(private mediator: Mediator) {}

  check(): void {
    // Checkbox doesn't know about the submit button directly —
    // it only ever talks to the mediator.
    this.mediator.notify("checkbox", "checked");
  }
}

const mediator = new DialogMediator();
const checkbox = new Checkbox(mediator);
checkbox.check();
```
