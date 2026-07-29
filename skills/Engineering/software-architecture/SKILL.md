---
name: software-architecture
description: Provides object-oriented design pattern guidance — currently the 23 Gang of Four (GoF) patterns, with more pattern families (event-driven, etc.) to follow. Each pattern's description, when to use it, related patterns, and a TypeScript example are loaded on demand. Use when designing new classes, interfaces, or object collaborations ("how should I structure this," "how do I decouple X from Y"); refactoring for extensibility (removing type-switches/conditionals, decoupling construction from use, adding variants without modifying existing code); the user names a GoF pattern explicitly ("use Strategy here," "should this be a Factory?"); reviewing code or architecture where a recognizable pattern or anti-pattern (god object, giant type-switch) applies; or architecting a solution more broadly.
---

# Software Architecture

Design-pattern reference for object-oriented systems. This skill currently covers the Gang of Four (GoF) patterns; future pattern families (event-driven design, etc.) will be added as sibling sections below.

## How to use this index

Scan the one-line descriptions below for the pattern(s) that best match the symptom or intent at hand, then open only that pattern's file for full detail (description, when to use it, related patterns, and a TypeScript example). Don't load every file — the point of this index is to stay lightweight and let you go deep on exactly one pattern at a time.

## Gang of Four (GoF)

### Creational

Concerned with object creation — decoupling *how* an object is constructed from *who* uses it.

- [Singleton](gof/singleton.md) — Ensure a class has only one instance and provide a global point of access to it.
- [Factory Method](gof/factory-method.md) — Define an interface for creating an object, but let subclasses decide which class to instantiate.
- [Abstract Factory](gof/abstract-factory.md) — Provide an interface for creating families of related objects without specifying their concrete classes.
- [Builder](gof/builder.md) — Separate the construction of a complex object from its representation so the same process can build different representations.
- [Prototype](gof/prototype.md) — Create new objects by copying an existing instance rather than instantiating a class directly.

### Structural

Concerned with composing classes and objects into larger structures while keeping them flexible and efficient.

- [Adapter](gof/adapter.md) — Convert the interface of a class into another interface clients expect.
- [Bridge](gof/bridge.md) — Decouple an abstraction from its implementation so the two can vary independently.
- [Composite](gof/composite.md) — Compose objects into tree structures to represent part-whole hierarchies; treat individual objects and compositions uniformly.
- [Decorator](gof/decorator.md) — Attach additional responsibilities to an object dynamically, as a flexible alternative to subclassing.
- [Facade](gof/facade.md) — Provide a unified, higher-level interface to a set of interfaces in a subsystem.
- [Flyweight](gof/flyweight.md) — Use sharing to support large numbers of fine-grained objects efficiently.
- [Proxy](gof/proxy.md) — Provide a surrogate or placeholder for another object to control access to it.

### Behavioral

Concerned with communication and responsibility between objects.

- [Chain of Responsibility](gof/chain-of-responsibility.md) — Pass a request along a chain of handlers until one of them handles it.
- [Command](gof/command.md) — Encapsulate a request as an object, so requests can be queued, logged, or undone.
- [Interpreter](gof/interpreter.md) — Given a language, define a representation for its grammar and an interpreter that uses it.
- [Iterator](gof/iterator.md) — Access the elements of an aggregate object sequentially without exposing its underlying representation.
- [Mediator](gof/mediator.md) — Define an object that encapsulates how a set of objects interact, keeping them from referring to each other directly.
- [Memento](gof/memento.md) — Capture and externalize an object's internal state so it can be restored later, without violating encapsulation.
- [Observer](gof/observer.md) — Define a one-to-many dependency so that when one object changes state, all its dependents are notified automatically.
- [State](gof/state.md) — Let an object alter its behavior when its internal state changes; the object appears to change its class.
- [Strategy](gof/strategy.md) — Define a family of interchangeable algorithms and make them swappable independently of the clients that use them.
- [Template Method](gof/template-method.md) — Define the skeleton of an algorithm in a method, deferring some steps to subclasses.
- [Visitor](gof/visitor.md) — Represent an operation to perform on the elements of an object structure, letting you add new operations without changing the classes.
