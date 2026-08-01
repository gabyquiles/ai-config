# Claim Check

## Description

When a message's real payload is too large to put on the broker efficiently (a video file, a large document, a big batch of records), store the payload in external storage and publish a small message containing only a reference — a "claim check" — to it. Consumers that need the full payload use the reference to fetch it from storage; consumers that only need the metadata never have to receive or discard a large blob they didn't want.

## When to use it

- A message's payload is large enough that including it directly would bloat the broker, slow down every consumer's receive path, or exceed the broker's message-size limits.
- Most consumers only care about metadata about the payload (that it exists, its type, its size) and only a subset need the full content.
- You want to decouple message throughput from payload size, so the broker stays fast regardless of how large individual payloads get.

## Related patterns

- [Proxy](../gof/proxy.md) — the in-process analog: both use a lightweight stand-in to reference something larger stored elsewhere, deferring the cost of fetching the full thing until it's actually needed.
- [Content Enricher](content-enricher.md) — the inverse operation: an enricher adds data into a message, while a claim check strips large data *out* of a message and leaves a reference behind.

## Example

```typescript
interface ClaimCheckMessage {
  type: "ReportGenerated";
  reportId: string;
  storageKey: string; // the "claim check" — a reference, not the payload
}

class BlobStorage {
  private blobs = new Map<string, Buffer>();
  put(key: string, data: Buffer): void {
    this.blobs.set(key, data);
  }
  get(key: string): Buffer | undefined {
    return this.blobs.get(key);
  }
}

class ReportPublisher {
  constructor(private storage: BlobStorage, private bus: { publish(m: ClaimCheckMessage): void }) {}

  publish(reportId: string, largeReport: Buffer): void {
    const storageKey = `reports/${reportId}`;
    this.storage.put(storageKey, largeReport); // large payload goes to storage
    this.bus.publish({ type: "ReportGenerated", reportId, storageKey }); // message stays small
  }
}

const storage = new BlobStorage();
const publisher = new ReportPublisher(storage, {
  publish: (m) => console.log(`published claim check: ${JSON.stringify(m)}`),
});

publisher.publish("report-1", Buffer.from("...large report contents..."));
// only { type, reportId, storageKey } goes over the broker —
// a consumer fetches the real payload from storage using storageKey.
```
