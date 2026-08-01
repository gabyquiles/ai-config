# Bridge

## Description

Decouples an abstraction from its implementation so the two can vary independently, by putting the implementation behind its own interface and having the abstraction hold a reference to it (composition) instead of inheriting from it. This avoids a combinatorial explosion of subclasses when a hierarchy has two or more independent dimensions of variation.

## When to use it

- You have (or would otherwise need) a class hierarchy that varies along two independent axes — e.g. shape × renderer, or notification-type × delivery-channel — and subclassing for every combination would multiply out of control (`RedCircle`, `RedSquare`, `BlueCircle`, `BlueSquare`, ...).
- You want to be able to swap an implementation at runtime, not just at compile time.
- Changes to the implementation side shouldn't require recompiling or touching the abstraction side, and vice versa.

## Related patterns

- [Adapter](adapter.md) — Adapter is applied after the fact to make an already-existing interface compatible; Bridge is designed up front, before either side is built, specifically to let both vary independently.
- [Abstract Factory](../gof/abstract-factory.md) — can be used to create and configure a particular Bridge implementation.

## Example

```typescript
// Implementation hierarchy (the "how").
interface Renderer {
  renderCircle(radius: number): string;
}

class VectorRenderer implements Renderer {
  renderCircle(radius: number): string {
    return `<circle r="${radius}" />`;
  }
}

class RasterRenderer implements Renderer {
  renderCircle(radius: number): string {
    return `pixels for circle of radius ${radius}`;
  }
}

// Abstraction hierarchy (the "what") — holds a Renderer instead of extending one.
abstract class Shape {
  constructor(protected renderer: Renderer) {}
  abstract draw(): string;
}

class Circle extends Shape {
  constructor(renderer: Renderer, private radius: number) {
    super(renderer);
  }
  draw(): string {
    return this.renderer.renderCircle(this.radius);
  }
  resize(factor: number): void {
    this.radius *= factor;
  }
}

// Shape and Renderer vary independently — no RasterCircle/VectorCircle subclasses needed.
const circle = new Circle(new VectorRenderer(), 5);
console.log(circle.draw());
```
