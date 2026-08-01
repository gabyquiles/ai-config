---
name: design-patterns
description: Provides design pattern guidance across two pattern families — the 23 Gang of Four (GoF) object-oriented patterns, and event-driven architecture (EDA) patterns for asynchronous, event-based integration. Each pattern's description, when to use it, related patterns, and a TypeScript example are loaded on demand. Use when designing new classes, interfaces, or object collaborations ("how should I structure this," "how do I decouple X from Y"); refactoring for extensibility (removing type-switches/conditionals, decoupling construction from use, adding variants without modifying existing code); designing asynchronous integration between services (events vs. commands, sagas, message routing, event sourcing, CQRS); the user names a pattern explicitly ("use Strategy here," "should this be a Factory?," "should we use Event Sourcing?"); or reviewing code or architecture where a recognizable pattern or anti-pattern (god object, giant type-switch, shared-database coupling) applies.
---

# Design Patterns

Design-pattern reference covering two pattern families: the Gang of Four (GoF) object-oriented patterns, and Event-Driven Architecture (EDA) patterns.

For actively designing or documenting a new system's architecture end-to-end (arc42 docs, C4 diagrams, UML), use the sibling `software-architect` skill instead — it reaches into this index when a section needs a named pattern.

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

## Event-Driven Architecture (EDA)

Concerned with integrating independent services asynchronously via events, rather than direct synchronous calls.

### Event Styles

Concerned with how state changes are represented and propagated as events, and how services derive their own truth from them.

- [Event Notification](event-driven/event-notification.md) — Publish a fact-only event announcing that something happened, without the full data behind it.
- [Event-Carried State Transfer](event-driven/event-carried-state-transfer.md) — Publish an event that carries the full state a consumer needs, so it can keep a local, queryable copy.
- [Event Sourcing](event-driven/event-sourcing.md) — Persist every state change as an immutable event and derive current state by replaying the log.
- [CQRS](event-driven/cqrs.md) — Separate the write model (commands) from the read model(s) (queries), kept in sync via events.
- [Change Data Capture](event-driven/change-data-capture.md) — Turn a database's own row changes into published events, without modifying the application that writes them.

### Messaging & Integration

Concerned with transforming, enriching, and routing messages as they move between producers and consumers.

- [Content-Based Router](event-driven/content-based-router.md) — Inspect a message's content and route it to the destination that should handle it.
- [Message Translator](event-driven/message-translator.md) — Convert a message from one format or schema into another that the consumer expects.
- [Content Enricher](event-driven/content-enricher.md) — Supplement a message with additional data it doesn't already contain before passing it downstream.
- [Claim Check](event-driven/claim-check.md) — Store a large payload externally and pass only a reference to it in the message.
- [Splitter](event-driven/splitter.md) — Break a single compound message into multiple individual messages, one per item.

### Coordination & Delivery

Concerned with reliable message processing and multi-step coordination across independent services.

- [Competing Consumers](event-driven/competing-consumers.md) — Let multiple consumer instances share one queue so the broker distributes work across them.
- [Idempotent Consumer](event-driven/idempotent-consumer.md) — Build a consumer so reprocessing the same message twice is safe, since most brokers redeliver at least once.
- [Choreography Saga](event-driven/choreography-saga.md) — Coordinate a multi-step process by having each service react to the others' events, with no central coordinator.
- [Orchestration Saga](event-driven/orchestration-saga.md) — Coordinate a multi-step process with a single orchestrator that directs each step and its compensations.

### Concepts

See [event-driven/concepts.md](event-driven/concepts.md) for foundational EDA vocabulary that isn't a reusable pattern on its own: commands vs. events, eventual consistency, the coupling spectrum, queues vs. streams vs. pub/sub, message delivery guarantees, and schema management/versioning.
