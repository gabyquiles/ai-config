# Proxy

## Description

Provides a surrogate or placeholder for another object to control access to it. The proxy implements the same interface as the real object, so it's a drop-in substitute — but it can add behavior around access itself: deferring expensive creation, checking permissions, adding caching, or forwarding across a process boundary.

## When to use it

- **Lazy initialization (virtual proxy)** — the real object is expensive to create and you want to defer that cost until it's actually needed.
- **Access control (protection proxy)** — different callers should have different permissions to the same underlying object.
- **Remote access (remote proxy)** — the real object lives in a different address space (another process/server) and the proxy hides the networking details behind a local-looking interface.
- **Caching (caching proxy)** — you want to cache the results of expensive operations on the real object transparently.

## Related patterns

- [Decorator](decorator.md) — same structural shape (wraps an object behind the same interface), but Decorator *adds new responsibilities/behavior*, while Proxy *controls access* to functionality that's already fully defined by the real subject — Proxy usually doesn't change what the object does, just when/whether/how it's reached.
- [Adapter](adapter.md) — Adapter changes an interface to something different; Proxy keeps the exact same interface as the object it stands in for.

## Example

```typescript
interface ImageLoader {
  display(): string;
}

class HighResImage implements ImageLoader {
  constructor(private path: string) {
    console.log(`expensive load from disk: ${path}`);
  }
  display(): string {
    return `displaying ${this.path}`;
  }
}

// Virtual proxy: defers the expensive load until display() is actually called.
class LazyImageProxy implements ImageLoader {
  private real?: HighResImage;

  constructor(private path: string) {}

  display(): string {
    if (!this.real) {
      this.real = new HighResImage(this.path);
    }
    return this.real.display();
  }
}

const image: ImageLoader = new LazyImageProxy("banner.png");
// No disk load happens until this line:
console.log(image.display());
```
