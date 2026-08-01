# Observer

## Description

Defines a one-to-many dependency between objects so that when one object (the subject) changes state, all objects that depend on it (observers) are notified and updated automatically. Subjects don't need to know anything concrete about their observers beyond a shared notification interface, so observers can be added or removed at runtime without changing the subject.

## When to use it

- A change to one object requires changing others, and you don't know in advance how many, or which, other objects need to react.
- You want to broadcast state changes to interested parties without tightly coupling the source of the change to every listener (event systems, pub/sub, reactive UI bindings, model-view synchronization).
- The set of interested parties can grow or shrink dynamically at runtime.

## Related patterns

- [Mediator](mediator.md) — Mediator is often built on top of Observer (colleagues observe the mediator), but Mediator additionally centralizes and coordinates *how* participants react to each other, not just that they're notified.
- [Chain of Responsibility](../gof/chain-of-responsibility.md) — both decouple a source from receivers, but Observer broadcasts to *every* interested party, while Chain of Responsibility passes a request along until exactly one handler (usually) deals with it.
- [Event Notification](../event-driven/event-notification.md) — the cross-service analog: Event Notification is Observer's subject/observer relationship stretched across process and service boundaries via a broker.

## Example

```typescript
interface Observer {
  update(temperature: number): void;
}

class WeatherStation {
  private observers: Observer[] = [];

  subscribe(observer: Observer): void {
    this.observers.push(observer);
  }

  unsubscribe(observer: Observer): void {
    this.observers = this.observers.filter((o) => o !== observer);
  }

  setTemperature(temp: number): void {
    for (const observer of this.observers) {
      observer.update(temp);
    }
  }
}

class Display implements Observer {
  constructor(private label: string) {}
  update(temperature: number): void {
    console.log(`${this.label}: ${temperature}°`);
  }
}

const station = new WeatherStation();
const phoneDisplay = new Display("phone");
station.subscribe(phoneDisplay);
station.subscribe(new Display("dashboard"));

station.setTemperature(72); // both displays notified automatically
```
