# Command

## Description

Encapsulates a request (an action plus its receiver and arguments) as a standalone object, so it can be parameterized, queued, logged, or undone like any other value. This decouples the object that issues a request (the invoker) from the object that knows how to perform it (the receiver).

## When to use it

- You need to queue, schedule, or log requests, or support undo/redo — none of which is possible if a "request" is just a direct method call.
- You want to parameterize objects (e.g. a button, a menu item, a macro) with an action to perform, without the parameterizing code needing to know anything about how that action works.
- You want to decouple the sender of a request from anything about how or when it's carried out.

## Related patterns

- [Chain of Responsibility](chain-of-responsibility.md) — Commands are frequently what gets passed along a chain of handlers.
- [Memento](memento.md) — often paired with Command to implement undo: each Command can capture a Memento of state before executing, to restore later.
- [Strategy](../gof/strategy.md) — structurally similar (both wrap a unit of behavior as an object passed around), but Strategy is about choosing *which algorithm* to run for an ongoing operation, while Command is about capturing *a specific request* (receiver + action + args) as a first-class, storable/queueable/undoable object.

## Example

```typescript
interface Command {
  execute(): void;
  undo(): void;
}

class Document {
  content = "";
}

class InsertTextCommand implements Command {
  constructor(private doc: Document, private text: string) {}

  execute(): void {
    this.doc.content += this.text;
  }

  undo(): void {
    this.doc.content = this.doc.content.slice(0, -this.text.length);
  }
}

class CommandHistory {
  private history: Command[] = [];

  run(command: Command): void {
    command.execute();
    this.history.push(command);
  }

  undoLast(): void {
    this.history.pop()?.undo();
  }
}

const doc = new Document();
const history = new CommandHistory();

history.run(new InsertTextCommand(doc, "hello "));
history.run(new InsertTextCommand(doc, "world"));
history.undoLast();
console.log(doc.content); // "hello "
```
