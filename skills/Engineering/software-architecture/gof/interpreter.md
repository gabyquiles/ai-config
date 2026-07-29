# Interpreter

## Description

Given a language (even a tiny, domain-specific one), defines a representation for its grammar along with an interpreter that evaluates sentences in that language. Each grammar rule typically becomes a class, and evaluating an expression means walking the resulting tree — so this pattern is essentially Composite applied specifically to language evaluation.

## When to use it

- You have a simple, well-defined grammar that recurs often enough to be worth modeling explicitly — search filter expressions, permission rules, arithmetic in a spreadsheet cell, a small rules engine.
- The grammar is simple enough that a class-per-rule tree stays manageable — this pattern doesn't scale well to complex grammars (parsers/compilers), where a dedicated parser generator is a better fit.
- You want the grammar itself to be easy to extend (new rule types) by adding new classes, in the spirit of Composite.

This is one of the least commonly reached-for GoF patterns in typical application code — most "I need a small expression language" needs are better served by an existing embedded scripting/expression library. Reach for it when the grammar is genuinely small and stable, and a dependency would be overkill.

## Related patterns

- [Composite](../gof/composite.md) — Interpreter is a specialized application of Composite, where the tree specifically represents a grammar and nodes know how to evaluate themselves.
- [Visitor](visitor.md) — an alternative to putting an `interpret()` method on every node class: define the evaluation logic externally as a Visitor instead, keeping the grammar classes free of behavior.

## Example

```typescript
interface Expression {
  interpret(context: Record<string, number>): number;
}

class Number implements Expression {
  constructor(private value: number) {}
  interpret(): number {
    return this.value;
  }
}

class Variable implements Expression {
  constructor(private name: string) {}
  interpret(context: Record<string, number>): number {
    return context[this.name] ?? 0;
  }
}

class Add implements Expression {
  constructor(private left: Expression, private right: Expression) {}
  interpret(context: Record<string, number>): number {
    return this.left.interpret(context) + this.right.interpret(context);
  }
}

// Represents the expression: x + 5
const expression: Expression = new Add(new Variable("x"), new Number(5));
console.log(expression.interpret({ x: 10 })); // 15
```
