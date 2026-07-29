# Composite

## Description

Composes objects into tree structures to represent part-whole hierarchies, and lets clients treat individual objects (leaves) and compositions of objects (branches) through the same interface. Client code can call the same method on a single item or an entire subtree without knowing or caring which it has.

## When to use it

- Your domain is naturally a tree — file systems, UI component hierarchies, organization charts, nested menus, arithmetic expressions.
- You want callers to be able to apply an operation uniformly, without branching on "is this a leaf or a container" (`if (isGroup) { ... } else { ... }`).
- You expect the recursive structure to grow (deeper nesting, new leaf/branch types) and want that growth to not require changes to client code.

## Related patterns

- [Decorator](decorator.md) — structurally similar (both rely on recursive composition), but Decorator adds responsibilities to a single object, while Composite represents a whole part-whole hierarchy of many objects.
- [Visitor](../gof/visitor.md) — commonly used together: Visitor lets you define a new operation over a Composite tree without adding a method to every node class.
- [Builder](../gof/builder.md) — often used to construct a Composite tree step by step.

## Example

```typescript
interface FileSystemNode {
  name: string;
  size(): number;
}

class File implements FileSystemNode {
  constructor(public name: string, private bytes: number) {}
  size(): number {
    return this.bytes;
  }
}

class Directory implements FileSystemNode {
  private children: FileSystemNode[] = [];

  constructor(public name: string) {}

  add(node: FileSystemNode): void {
    this.children.push(node);
  }

  // Same method name/shape as File.size() — callers don't need to know
  // whether a given node is a leaf (File) or a branch (Directory).
  size(): number {
    return this.children.reduce((total, child) => total + child.size(), 0);
  }
}

const root = new Directory("root");
root.add(new File("readme.md", 1200));

const src = new Directory("src");
src.add(new File("index.ts", 3400));
root.add(src);

console.log(root.size()); // sums recursively through the whole tree
```
