# Factory Method

## Description

Defines an interface for creating an object, but lets subclasses (or a passed-in creator function/class) decide which concrete class to instantiate. The calling code depends only on an abstract product type and an abstract creation method — it never names a concrete class directly.

## When to use it

- A class can't anticipate the exact class of objects it must create — the concrete type should be decided by a subclass or configuration.
- You want to localize the knowledge of *which concrete class to build* in one place, so adding a new variant doesn't require touching every call site that creates the product.
- You're replacing a constructor call scattered across the codebase with a single seam that can be overridden or swapped (e.g. for testing, or to support a new product type).

## Related patterns

- [Abstract Factory](abstract-factory.md) — often implemented using a set of Factory Methods, one per product; use Abstract Factory when you need to create *families* of related objects, Factory Method when you only need one product type.
- [Template Method](../gof/template-method.md) — Factory Method is frequently just one step inside a larger Template Method.
- [Prototype](prototype.md) — an alternative way to avoid hard-coding a concrete class: clone an existing instance instead of calling a creation method.

## Example

```typescript
interface Notification {
  send(message: string): void;
}

class EmailNotification implements Notification {
  send(message: string): void {
    console.log(`Email: ${message}`);
  }
}

class SmsNotification implements Notification {
  send(message: string): void {
    console.log(`SMS: ${message}`);
  }
}

abstract class NotifierCreator {
  // The factory method — subclasses decide the concrete product.
  abstract createNotification(): Notification;

  notify(message: string): void {
    const notification = this.createNotification();
    notification.send(message);
  }
}

class EmailNotifierCreator extends NotifierCreator {
  createNotification(): Notification {
    return new EmailNotification();
  }
}

class SmsNotifierCreator extends NotifierCreator {
  createNotification(): Notification {
    return new SmsNotification();
  }
}

// Caller only knows about NotifierCreator, never the concrete Notification class.
const creator: NotifierCreator = new SmsNotifierCreator();
creator.notify("build finished");
```
