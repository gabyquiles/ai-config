# Visitor

## Description

Represents an operation to be performed on the elements of an object structure, letting you define a new operation without changing the classes of the elements it operates on. Each element accepts a visitor and calls back into the appropriate method on it (double dispatch), so the operation's logic lives entirely in the visitor rather than being spread across every element class.

## When to use it

- An object structure (often a Composite tree — an AST, a document model, a file tree) is stable, but you need to keep adding new, unrelated operations over it (pretty-printing, validation, export, cost calculation) — Visitor lets each new operation live in its own class instead of adding a method to every element class every time.
- You want to gather related behavior that would otherwise be scattered thinly across many element classes into one cohesive place.
- The element hierarchy itself is unlikely to grow much — Visitor's tradeoff is that adding a *new element type* requires updating every existing visitor, which is expensive if elements change often.

## Related patterns

- [Composite](../gof/composite.md) — Visitor is very frequently applied to traverse and operate on a Composite tree's nodes.
- [Iterator](iterator.md) — Iterator focuses purely on sequencing access to elements; Visitor focuses on performing type-specific operations at each element, often via double dispatch rather than a single uniform `next()`.
- [Interpreter](../gof/interpreter.md) — putting evaluation logic in a Visitor instead of on the grammar classes themselves is a common way to implement Interpreter while keeping the grammar classes free of behavior.

## Example

```typescript
interface Visitor {
  visitCircle(c: Circle): string;
  visitSquare(s: Square): string;
}

interface Shape {
  accept(visitor: Visitor): string;
}

class Circle implements Shape {
  constructor(public radius: number) {}
  accept(visitor: Visitor): string {
    return visitor.visitCircle(this);
  }
}

class Square implements Shape {
  constructor(public side: number) {}
  accept(visitor: Visitor): string {
    return visitor.visitSquare(this);
  }
}

// A new operation added without touching Circle or Square at all.
class AreaVisitor implements Visitor {
  visitCircle(c: Circle): string {
    return `area: ${(Math.PI * c.radius ** 2).toFixed(2)}`;
  }
  visitSquare(s: Square): string {
    return `area: ${s.side ** 2}`;
  }
}

const shapes: Shape[] = [new Circle(3), new Square(4)];
const areaVisitor = new AreaVisitor();
shapes.forEach((shape) => console.log(shape.accept(areaVisitor)));
```
