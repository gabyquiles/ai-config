# Flyweight

## Description

Uses sharing to support large numbers of fine-grained objects efficiently, by splitting an object's state into *intrinsic* state (shared, immutable, context-independent — safe to reuse across many logical instances) and *extrinsic* state (unique per usage, supplied by the caller at the point of use rather than stored on the object). A factory hands out shared intrinsic-state objects instead of letting callers construct duplicates.

## When to use it

- An application needs to create a very large number of similar objects, and the memory cost of storing full per-object state would be prohibitive (e.g. rendering millions of trees in a forest, or characters in a text document).
- Most of each object's state can be made extrinsic (passed in at the call site) without changing behavior, leaving a small, shareable intrinsic core.
- Object identity doesn't matter to callers — they only care about behavior/appearance, not which specific instance they got.

This is a narrower, more mechanical-sympathy-driven pattern than most GoF patterns — reach for it only when profiling or clear memory/object-count budgets justify the added complexity of splitting state.

## Related patterns

- [Singleton](singleton.md) — a Flyweight factory is often implemented as a Singleton, since there should be exactly one shared pool/cache of flyweight instances.
- [Composite](../gof/composite.md) — Flyweight is often used to implement the leaf nodes of a large Composite tree efficiently.

## Example

```typescript
// Intrinsic state: shared, immutable, safe to reuse (e.g. a tree species' sprite/model).
class TreeType {
  constructor(
    readonly name: string,
    readonly texture: string,
  ) {}

  draw(x: number, y: number): string {
    // Extrinsic state (x, y) is passed in, not stored on the flyweight.
    return `draw ${this.name} at (${x}, ${y}) using ${this.texture}`;
  }
}

class TreeTypeFactory {
  private static cache = new Map<string, TreeType>();

  static get(name: string, texture: string): TreeType {
    const key = `${name}:${texture}`;
    if (!this.cache.has(key)) {
      this.cache.set(key, new TreeType(name, texture));
    }
    return this.cache.get(key)!;
  }
}

class Tree {
  constructor(
    private x: number,
    private y: number,
    private type: TreeType, // shared across every tree of the same species
  ) {}

  draw(): string {
    return this.type.draw(this.x, this.y);
  }
}

// A million Tree instances share only a handful of TreeType instances.
const oakType = TreeTypeFactory.get("oak", "oak.png");
const forest = [new Tree(1, 2, oakType), new Tree(5, 9, oakType)];
```
