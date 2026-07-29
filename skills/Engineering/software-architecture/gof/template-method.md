# Template Method

## Description

Defines the skeleton of an algorithm in a base-class method, deferring some individual steps to subclasses. The overall sequence of steps stays fixed in the base class (and can't be changed by subclasses), while subclasses override specific steps (often called "hooks") to vary parts of the behavior without restructuring the algorithm itself.

## When to use it

- Several classes implement algorithms that are identical except for a few steps, and that duplication should be pulled up into one shared method.
- You want to control the parts of an algorithm that are allowed to vary — expose exactly the extension points that make sense, and lock the rest, rather than letting subclasses override the whole method and potentially break the sequence.
- You're refactoring near-duplicate methods across sibling classes and the difference between them is isolable to a small number of steps.

## Related patterns

- [Factory Method](../gof/factory-method.md) — Factory Method is a special case of Template Method specifically for object creation; a Template Method's algorithm frequently calls a Factory Method as one of its steps.
- [Strategy](strategy.md) — Template Method varies steps via subclassing (inheritance, fixed at compile time); Strategy varies the whole algorithm via composition (an injected object, swappable at runtime) — prefer Template Method when the overall sequence is genuinely shared and only individual steps differ.

## Example

```typescript
abstract class DataExporter {
  // The template method — fixed sequence, not overridable by subclasses.
  export(): string {
    const data = this.fetchData();
    const formatted = this.format(data);
    return this.wrap(formatted);
  }

  protected abstract fetchData(): string[];
  protected abstract format(data: string[]): string;

  // A hook with a sensible default — subclasses may override, but don't have to.
  protected wrap(content: string): string {
    return content;
  }
}

class CsvExporter extends DataExporter {
  protected fetchData(): string[] {
    return ["id,name", "1,widget"];
  }
  protected format(data: string[]): string {
    return data.join("\n");
  }
}

class JsonExporter extends DataExporter {
  protected fetchData(): string[] {
    return ["widget"];
  }
  protected format(data: string[]): string {
    return JSON.stringify(data);
  }
  protected wrap(content: string): string {
    return `{"items": ${content}}`;
  }
}

console.log(new CsvExporter().export());
console.log(new JsonExporter().export());
```
