# Iterator

## Description

Provides a way to access the elements of an aggregate object sequentially without exposing its underlying representation (array, linked list, tree, map, generated sequence, ...). The consumer works against a uniform "give me the next element" interface regardless of how the collection actually stores its data.

## When to use it

- You want to traverse a collection without exposing its internal structure, so the collection is free to change its internal representation without breaking consumers.
- You need to support multiple simultaneous or multiple *kinds* of traversal (forward, filtered, paginated) over the same collection.
- You want a uniform way to iterate over different aggregate structures through one interface — this is largely why most modern languages, including TypeScript/JavaScript, bake this pattern directly into the language via `Symbol.iterator` and `for...of`.

## Related patterns

- [Composite](../gof/composite.md) — Iterators are commonly used to traverse Composite trees uniformly, hiding whether traversal is depth-first, breadth-first, over leaves only, etc.
- [Visitor](visitor.md) — both let you separate traversal/operation logic from the collection's classes; Iterator focuses on *sequencing access*, Visitor focuses on *performing an operation* at each element.

## Example

```typescript
class RingBuffer<T> implements Iterable<T> {
  private items: T[] = [];

  constructor(private capacity: number) {}

  add(item: T): void {
    if (this.items.length >= this.capacity) this.items.shift();
    this.items.push(item);
  }

  // Implementing the built-in Iterator protocol hides the fact that this
  // is backed by a capacity-bounded array rather than a "real" ring buffer.
  [Symbol.iterator](): Iterator<T> {
    let index = 0;
    const items = this.items;
    return {
      next(): IteratorResult<T> {
        if (index < items.length) {
          return { value: items[index++], done: false };
        }
        return { value: undefined, done: true };
      },
    };
  }
}

const buffer = new RingBuffer<number>(3);
[1, 2, 3, 4].forEach((n) => buffer.add(n));

for (const value of buffer) {
  console.log(value); // 2, 3, 4 — caller never touches the internal array
}
```
