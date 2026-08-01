# Decorator

## Description

Attaches additional responsibilities to an object dynamically, by wrapping it in one or more decorator objects that implement the same interface as the object they wrap. This is a flexible alternative to subclassing for extending behavior, since decorators can be stacked and combined at runtime in any order.

## When to use it

- You need to add responsibilities to individual objects, not to an entire class — and you want to add or remove them at runtime.
- Extending behavior via subclassing would require a new subclass for every combination of features (`LoggingCachingRetryingClient`, `CachingClient`, `RetryingClient`, ...) — the same combinatorial-explosion problem Bridge solves for a different axis.
- You want to keep a core class focused on one responsibility and layer cross-cutting concerns (logging, caching, retries, compression, auth) on top, independently.

## Related patterns

- [Composite](composite.md) — structurally similar (recursive wrapping/composition), but Decorator is about adding behavior to one object, Composite is about representing a whole part-whole tree.
- [Proxy](proxy.md) — also wraps an object behind the same interface, but Proxy controls *access* to the object (lazy loading, permission checks) rather than adding new behavior/responsibilities.
- [Strategy](../gof/strategy.md) — Strategy swaps out an entire algorithm; Decorator layers additional behavior around an existing one without replacing it.
- [Content Enricher](../event-driven/content-enricher.md) — the cross-service analog: both attach additional data/responsibility to something without changing its original shape or the code that produced it.

## Example

```typescript
interface DataSource {
  read(): string;
}

class FileDataSource implements DataSource {
  constructor(private path: string) {}
  read(): string {
    return `raw contents of ${this.path}`;
  }
}

abstract class DataSourceDecorator implements DataSource {
  constructor(protected wrappee: DataSource) {}
  read(): string {
    return this.wrappee.read();
  }
}

class EncryptionDecorator extends DataSourceDecorator {
  read(): string {
    return `decrypt(${super.read()})`;
  }
}

class CompressionDecorator extends DataSourceDecorator {
  read(): string {
    return `decompress(${super.read()})`;
  }
}

// Stack decorators in any order/combination, decided at runtime.
const source: DataSource = new CompressionDecorator(
  new EncryptionDecorator(new FileDataSource("report.csv")),
);
console.log(source.read());
```
