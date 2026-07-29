# Singleton

## Description

Ensures a class has only one instance and provides a single, well-known point of access to it. The class itself owns and guards its own instantiation (typically via a private constructor and a static accessor), so callers can't accidentally create a second instance.

## When to use it

- Exactly one instance must exist and coordinate actions across the whole system — a connection pool, a config store, a logger, a hardware interface.
- You need lazy initialization: the instance shouldn't be created until it's first needed.
- You're tempted to reach for a global/module-level variable but want the added safety of controlled, lazy construction.

Be cautious: Singleton is one of the most overused GoF patterns. It introduces global mutable state, makes unit testing harder (tests can leak state through the shared instance), and hides a dependency instead of expressing it in a constructor or function signature. Prefer passing a single shared instance explicitly (dependency injection) unless there's a real constraint — like a hardware resource or a truly process-wide cache — that requires enforcing uniqueness at the type level.

## Related patterns

- [Facade](facade.md) — Facades are often implemented as Singletons, but the two are independent: a Facade simplifies an interface, Singleton restricts instantiation.
- [Abstract Factory](abstract-factory.md), [Builder](builder.md), [Prototype](prototype.md) — these creational patterns are commonly implemented *as* Singletons themselves (one factory instance for the whole app).

## Example

```typescript
class ConnectionPool {
  private static instance: ConnectionPool | undefined;
  private connections: string[] = [];

  private constructor() {
    // Expensive setup happens once, only when actually needed.
  }

  static getInstance(): ConnectionPool {
    if (!ConnectionPool.instance) {
      ConnectionPool.instance = new ConnectionPool();
    }
    return ConnectionPool.instance;
  }

  acquire(): string {
    return this.connections.pop() ?? "new-connection";
  }

  release(conn: string): void {
    this.connections.push(conn);
  }
}

// Every call site gets the same instance.
const pool = ConnectionPool.getInstance();
```
