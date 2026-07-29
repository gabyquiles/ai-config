# Builder

## Description

Separates the construction of a complex object from its representation, so the same step-by-step construction process can produce different representations. Instead of a telescoping constructor or a giant options object, a Builder exposes small, focused steps and a final `build()` that assembles the result.

## When to use it

- An object requires many optional or interdependent parameters, and a constructor (or constructor overloads) would become unreadable — the classic "telescoping constructor" smell.
- Construction involves multiple steps that must happen in a specific order, or the same steps can be recombined to produce meaningfully different objects.
- You want construction code to be readable as a sequence of intent ("set title, add section, add section, build") rather than a flat argument list where parameter order/meaning is easy to get wrong.

## Related patterns

- [Abstract Factory](abstract-factory.md) — Abstract Factory returns a product immediately from a single call; Builder constructs a product incrementally over several calls and returns it only at the end.
- [Composite](../gof/composite.md) — Builders are often used to assemble Composite tree structures step by step.

## Example

```typescript
class HttpRequest {
  constructor(
    readonly method: string,
    readonly url: string,
    readonly headers: Record<string, string>,
    readonly body?: string,
  ) {}
}

class HttpRequestBuilder {
  private method = "GET";
  private headers: Record<string, string> = {};
  private body?: string;

  constructor(private readonly url: string) {}

  setMethod(method: string): this {
    this.method = method;
    return this;
  }

  addHeader(key: string, value: string): this {
    this.headers[key] = value;
    return this;
  }

  setBody(body: string): this {
    this.body = body;
    return this;
  }

  build(): HttpRequest {
    return new HttpRequest(this.method, this.url, this.headers, this.body);
  }
}

const request = new HttpRequestBuilder("https://api.example.com/orders")
  .setMethod("POST")
  .addHeader("Content-Type", "application/json")
  .setBody(JSON.stringify({ item: "widget" }))
  .build();
```
