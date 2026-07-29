# Facade

## Description

Provides a unified, higher-level interface to a set of interfaces in a subsystem, making the subsystem easier to use. A Facade doesn't hide the subsystem's classes from callers who need finer control — it just gives most callers a simple entry point that handles the common case.

## When to use it

- A subsystem has many interacting classes with a complex, order-dependent, or easy-to-misuse API, and most callers only need a small slice of that complexity.
- You want to decouple client code from a subsystem's internals, so the subsystem can change internally without breaking every caller.
- You're layering a system and want a clean, minimal entry point at each layer boundary, rather than letting callers reach across layers into internal classes.

## Related patterns

- [Adapter](adapter.md) — Adapter conforms to an *existing* interface a client expects; Facade defines a *brand-new*, simpler interface on top of a subsystem. Adapter typically wraps one class, Facade typically wraps many.
- [Mediator](../gof/mediator.md) — both reduce coupling by introducing an intermediary, but Mediator centralizes communication *between peer objects* that already know about the mediator, while Facade is a one-way simplification for external callers who don't participate in the subsystem.
- [Singleton](singleton.md) — Facades are frequently implemented as Singletons, since there's usually only one meaningful entry point to a subsystem.

## Example

```typescript
// Subsystem: several classes with an intricate, order-dependent API.
class VideoDecoder {
  decode(file: string): string { return `decoded(${file})`; }
}
class AudioMixer {
  mix(track: string): string { return `mixed(${track})`; }
}
class SubtitleRenderer {
  burnIn(video: string, lang: string): string { return `${video}+subs(${lang})`; }
}

// Facade: one simple method for the common case.
class VideoConverterFacade {
  private decoder = new VideoDecoder();
  private mixer = new AudioMixer();
  private subtitles = new SubtitleRenderer();

  convert(file: string, language: string): string {
    const video = this.decoder.decode(file);
    const audio = this.mixer.mix(file);
    return this.subtitles.burnIn(`${video}+${audio}`, language);
  }
}

// Most callers just do this — the subsystem classes are still available
// directly for the rare caller that needs fine-grained control.
const output = new VideoConverterFacade().convert("clip.mp4", "en");
```
