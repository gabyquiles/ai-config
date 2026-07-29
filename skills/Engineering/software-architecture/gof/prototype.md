# Prototype

## Description

Specifies the kinds of objects to create using a prototypical instance, and creates new objects by copying (cloning) that prototype rather than instantiating a class directly. Useful when creating an object is more naturally expressed as "one like this one" than "one built from these parameters."

## When to use it

- The classes to instantiate are specified at runtime — e.g. loaded dynamically or determined by configuration — so you can't hard-code `new ConcreteClass()`.
- Creating an object from scratch is expensive (e.g. it requires an expensive computation or a network round-trip to populate), but you already have a similar object in memory that's cheap to copy and adjust.
- You need many objects that are mostly identical, differing only in a small number of fields, and constructing each from raw parameters would duplicate a lot of setup logic.

## Related patterns

- [Abstract Factory](abstract-factory.md) — an alternative way to avoid depending on concrete classes; Abstract Factory creates via a family of factory methods, Prototype creates by cloning an existing instance.
- [Memento](../gof/memento.md) — both involve copying object state, but Memento's copy is opaque and used only to *restore* the originating object later, not to create a new independent object.

## Example

```typescript
interface Prototype<T> {
  clone(): T;
}

class Enemy implements Prototype<Enemy> {
  constructor(
    public readonly type: string,
    public health: number,
    public readonly attackPattern: string[],
  ) {}

  clone(): Enemy {
    // Shallow copy is enough here since fields are primitives/immutable arrays.
    return new Enemy(this.type, this.health, [...this.attackPattern]);
  }
}

// Expensive to construct once (e.g. loaded from a data file, pathfinding precomputed).
const goblinPrototype = new Enemy("goblin", 30, ["slash", "block"]);

// Cheap to spawn many from the prototype instead of rebuilding each time.
const goblin1 = goblinPrototype.clone();
const goblin2 = goblinPrototype.clone();
goblin2.health = 15; // wounded variant, independent of goblin1
```
