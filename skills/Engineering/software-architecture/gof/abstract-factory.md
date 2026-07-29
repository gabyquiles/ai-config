# Abstract Factory

## Description

Provides an interface for creating *families* of related or dependent objects without specifying their concrete classes. Where Factory Method produces one product, Abstract Factory produces a whole set of products that are designed to work together — and guarantees the caller can't accidentally mix products from different families.

## When to use it

- A system must be independent of how its products are created, composed, and represented, but multiple related products need to stay consistent with each other (e.g. a UI toolkit's `Button`, `Checkbox`, and `Scrollbar` must all match the same theme).
- You want to swap an entire family of related objects at runtime or via configuration (e.g. switch from a "Postgres family" of repositories to a "SQLite family" without touching business logic).
- You want to enforce, at compile time, that products from different families are never combined.

## Related patterns

- [Factory Method](factory-method.md) — Abstract Factories are typically implemented as a set of Factory Methods, one per product in the family.
- [Builder](builder.md) — Builder focuses on constructing one complex object step by step; Abstract Factory focuses on choosing between families of simple objects. They can be combined (a Builder that uses an Abstract Factory internally).
- [Prototype](prototype.md) — an Abstract Factory can be implemented by keeping a prototype per product per family, and creating new products by cloning.

## Example

```typescript
interface Button {
  render(): string;
}
interface Checkbox {
  render(): string;
}

// Family 1: Light theme
class LightButton implements Button {
  render() { return "[ light button ]"; }
}
class LightCheckbox implements Checkbox {
  render() { return "[x] light checkbox"; }
}

// Family 2: Dark theme
class DarkButton implements Button {
  render() { return "[ dark button ]"; }
}
class DarkCheckbox implements Checkbox {
  render() { return "[x] dark checkbox"; }
}

interface UIFactory {
  createButton(): Button;
  createCheckbox(): Checkbox;
}

class LightUIFactory implements UIFactory {
  createButton(): Button { return new LightButton(); }
  createCheckbox(): Checkbox { return new LightCheckbox(); }
}

class DarkUIFactory implements UIFactory {
  createButton(): Button { return new DarkButton(); }
  createCheckbox(): Checkbox { return new DarkCheckbox(); }
}

function renderForm(factory: UIFactory): void {
  // No matter which factory is passed in, button and checkbox always match.
  console.log(factory.createButton().render());
  console.log(factory.createCheckbox().render());
}

renderForm(new DarkUIFactory());
```
