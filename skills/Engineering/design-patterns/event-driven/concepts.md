# Event-Driven Architecture: Concepts

Foundational vocabulary for working with events. Unlike the patterns in this family, these aren't reusable solutions to a recurring problem — they're distinctions and trade-offs worth having precise language for before you reach for a pattern.

## Commands vs. Events

A **command** is a request for something to happen, directed at a specific recipient who can accept or reject it ("ChargeCustomer"). An **event** is a statement of fact that something already happened, broadcast to whoever cares, with no expectation of a response ("CustomerCharged"). Conflating the two is a common source of confusion: naming something "CreateOrder" as if it were a fact, when it's really a command someone might reject, hides that it can fail.

## Eventual Consistency

When state is propagated via events instead of a single shared transaction, there's a window of time after a change where different parts of the system see different (but each internally consistent) versions of the truth. The system is *eventually* consistent — all parts converge once the events finish propagating — but there's no instant at which every reader sees the same state. Designs that assume otherwise (e.g. reading your own write immediately from a different service) will intermittently break.

## Coupling Spectrum

Coupling between services isn't binary; it runs from tight (synchronous request/response, shared database, shared code) to loose (asynchronous events, no shared schema beyond the event contract). Moving further along the spectrum toward looser coupling generally buys independence and resilience at the cost of consistency guarantees and debuggability. Event-driven patterns move you toward the loose end, but "loosely coupled" isn't a free win — it's a specific trade being made deliberately.

## Queues vs. Streams vs. Pub/Sub

A **queue** delivers each message to one consumer and typically removes it once processed (see Competing Consumers). A **stream** (e.g. a log-based broker) retains an ordered, replayable history that multiple independent consumers can read at their own pace, each tracking its own position. **Pub/sub** broadcasts each message to every current subscriber, usually without retention for subscribers who weren't listening at the time. Picking the wrong one for the job — e.g. pub/sub when you need replayability, or a queue when multiple independent consumers each need to see every message — is a common architecture mistake.

## Message Delivery Guarantees

Brokers typically offer one of three guarantees: **at-most-once** (a message might be lost, but is never duplicated), **at-least-once** (a message is never lost, but might be delivered more than once), or **exactly-once** (delivered exactly one time — genuinely hard to guarantee end-to-end and often really "effectively-once" via at-least-once plus deduplication). At-least-once is the most common in practice, which is why consumers generally need to be built as Idempotent Consumers rather than assuming a message arrives exactly once.

## Schema Management / Event Versioning

An event's shape is a contract between a producer and every consumer that reads it — and unlike a synchronous API, you often can't tell who all the consumers are, since new ones can subscribe without the producer knowing. This means event schemas need explicit versioning and backward-compatible evolution (adding optional fields, not removing or repurposing existing ones) since you can't force every consumer to upgrade at the same time a producer changes its event shape.
