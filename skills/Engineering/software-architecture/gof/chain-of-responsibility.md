# Chain of Responsibility

## Description

Passes a request along a chain of potential handlers until one of them handles it. Each handler decides either to process the request or to pass it to the next handler in the chain, so the sender doesn't need to know which handler will ultimately deal with it — or how many handlers exist.

## When to use it

- More than one object may handle a request, and the handler isn't known in advance — it should be determined at runtime by walking a sequence of candidates.
- You want to issue a request without specifying the receiver explicitly, decoupling senders from receivers.
- The set of handlers and their order should be configurable independently of the code that issues requests (e.g. a middleware/interceptor pipeline: auth check → rate limit → logging → handler).

## Related patterns

- [Command](command.md) — Commands are often what gets passed along a Chain of Responsibility as the request object.
- [Decorator](../gof/decorator.md) — structurally similar (linked wrapper objects), but every Decorator in the chain runs, whereas Chain of Responsibility stops at the first handler that takes the request (unless it deliberately forwards).
- [Mediator](mediator.md) — Mediator centralizes communication through one object; Chain of Responsibility decentralizes it across a sequence of independent handlers.

## Example

```typescript
abstract class SupportHandler {
  private next?: SupportHandler;

  setNext(handler: SupportHandler): SupportHandler {
    this.next = handler;
    return handler;
  }

  handle(ticketPriority: number): string {
    if (this.next) return this.next.handle(ticketPriority);
    return "unhandled";
  }
}

class L1Support extends SupportHandler {
  handle(ticketPriority: number): string {
    if (ticketPriority <= 1) return "handled by L1";
    return super.handle(ticketPriority);
  }
}

class L2Support extends SupportHandler {
  handle(ticketPriority: number): string {
    if (ticketPriority <= 3) return "handled by L2";
    return super.handle(ticketPriority);
  }
}

class L3Support extends SupportHandler {
  handle(ticketPriority: number): string {
    return "handled by L3 (escalations)";
  }
}

const l1 = new L1Support();
l1.setNext(new L2Support()).setNext(new L3Support());

console.log(l1.handle(2)); // "handled by L2" — L1 passed it along
```
