# Memento

## Description

Captures and externalizes an object's internal state so it can be restored to that state later, without violating encapsulation — the object being saved (the "originator") controls what goes into the memento and is the only thing that can read it back out, while whoever's holding onto the memento (the "caretaker") treats it as an opaque value.

## When to use it

- You need to implement undo/redo, checkpoints, or snapshots of an object's state at a point in time.
- Exposing an object's internal state directly (e.g. via public getters for every field, just so external code can save/restore it) would break encapsulation or leak implementation details.
- You want the logic for "how do I capture and restore my own state" to live inside the object itself, rather than duplicated in whatever external code needs to save/restore it.

## Related patterns

- [Command](command.md) — frequently paired: an undoable Command captures a Memento of the receiver's state before executing, and restores it on `undo()`.
- [Prototype](../gof/prototype.md) — both involve copying state, but Prototype's copy is a new, independent, fully-usable object; a Memento's copy is opaque and exists only to restore the *same* originator later.
- [Event Sourcing](../event-driven/event-sourcing.md) — both capture state so it can be restored later, but Memento snapshots one object's state at a point in time, while Event Sourcing stores the full sequence of changes and derives state by replaying them.

## Example

```typescript
class EditorMemento {
  // Only the Editor class that created this can read `content` back out —
  // the caretaker just holds the object without inspecting it.
  constructor(private readonly content: string) {}

  getContent(): string {
    return this.content;
  }
}

class Editor {
  private content = "";

  type(text: string): void {
    this.content += text;
  }

  save(): EditorMemento {
    return new EditorMemento(this.content);
  }

  restore(memento: EditorMemento): void {
    this.content = memento.getContent();
  }

  getContent(): string {
    return this.content;
  }
}

class History {
  private snapshots: EditorMemento[] = [];

  push(memento: EditorMemento): void {
    this.snapshots.push(memento);
  }

  pop(): EditorMemento | undefined {
    return this.snapshots.pop();
  }
}

const editor = new Editor();
const history = new History();

editor.type("draft v1");
history.push(editor.save());
editor.type(" — draft v2");

editor.restore(history.pop()!);
console.log(editor.getContent()); // "draft v1"
```
