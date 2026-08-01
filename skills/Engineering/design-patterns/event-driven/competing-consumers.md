# Competing Consumers

## Description

Multiple consumer instances subscribe to the same queue, and the broker delivers each message to exactly one of them rather than to all of them. This lets you scale message processing horizontally — add more consumer instances to increase throughput — without any consumer needing to know about the others; they "compete" for messages, and the broker handles distributing the work.

## When to use it

- A single consumer can't keep up with the rate of incoming messages, and the work is safe to parallelize across multiple instances.
- Consumer instances are stateless (or share state externally) so it doesn't matter which instance handles which message.
- You want to scale processing capacity up or down independently of the producer, just by adding or removing consumer instances.

Be cautious: because any instance might get any message, consumers must not rely on messages arriving in order relative to each other unless the broker and partitioning scheme specifically guarantee it (e.g. partitioning by key so related messages always land on the same consumer). Also, a message that crashes one consumer will typically be redelivered to another — which means consumers must tolerate being handed a message more than once (see Idempotent Consumer).

## Related patterns

- [Idempotent Consumer](idempotent-consumer.md) — almost always required alongside Competing Consumers, since redelivery after a crash or timeout means the same message can be processed more than once.

## Example

```typescript
interface Job {
  id: string;
}

class JobQueue {
  private jobs: Job[] = [];
  enqueue(job: Job): void {
    this.jobs.push(job);
  }
  // Each call hands out the next job to whichever consumer asks —
  // no job is ever given to more than one consumer.
  dequeue(): Job | undefined {
    return this.jobs.shift();
  }
}

class Consumer {
  constructor(private id: string, private queue: JobQueue) {}
  processNext(): void {
    const job = this.queue.dequeue();
    if (job) console.log(`consumer ${this.id} processing job ${job.id}`);
  }
}

const queue = new JobQueue();
queue.enqueue({ id: "job-1" });
queue.enqueue({ id: "job-2" });

const consumerA = new Consumer("A", queue);
const consumerB = new Consumer("B", queue);
consumerA.processNext(); // gets job-1
consumerB.processNext(); // gets job-2, not job-1 again
```
