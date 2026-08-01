---
name: software-architect
description: Actively designs new software architecture and documents it — interviewing on goals and constraints, producing C4 diagrams (System Context → Container → Component) in Mermaid, scaffolding an arc42-structured documentation tree in the target project, and dropping into a curated set of UML diagrams (Class, Sequence, State Machine, Component) wherever a section needs more nuance than a C4 diagram gives. Also usable to retrofit documentation onto an already-built system by inferring structure from the codebase instead of interviewing. Use when the user wants to design the architecture for a new system or service ("design the architecture for X," "help me architect this system," "how should this system be structured"); wants a specific architecture diagram ("draw a C4 diagram," "give me a context/container/component diagram," "should this be a sequence diagram or a class diagram"); wants formal architecture documentation ("write an arc42 doc," "document this system's architecture," "scaffold architecture docs"); or is documenting an existing system's structure after the fact rather than designing a new one.
---

# Software Architect

Drives the design of a new system's architecture, and documents it (or an existing system's) using arc42 for the documentation structure, C4 for high-level diagrams, and a curated set of UML diagrams for detail that C4 doesn't capture. This is a workflow skill, not a reference index — for picking a specific design pattern once the shape of a solution is already known, use the sibling `design-patterns` skill instead.

<what-to-do>

Determine mode first: **design** (a new system, or a new part of one, doesn't exist yet) or **retrofit** (documenting a system that's already built). Ask if it isn't obvious from context.

**In design mode:**

1. Interview on goals, constraints, actors, and integration points — one question at a time, waiting for feedback before continuing. Offer a recommended default with each question rather than leaving it fully open; this is a generative session, not an adversarial one. This fills arc42 §1 (Introduction and Goals) and §2 (Constraints).
2. Produce C4 diagrams top-down: Context first, then Container, then Component only for containers complex enough to warrant it. Confirm each level with the user before going one level deeper — don't jump straight to Component. Load only the matching `c4/*.md` file for the level you're producing.
3. Scaffold the arc42 doc tree in the **target project** (not this skill's own files) under `docs/arc42/`, lazily — write a section's file once that section has actually resolved, not before. Follow the structure and guidance in `arc42.md`. Embed the C4 diagrams from step 2 into §3 and §5.
4. Wherever a section needs more precision than a C4 diagram gives, drop into the matching UML diagram from the curated set — Runtime View (§6) → sequence, Building Block View internals (§5) → class or component, a stateful cross-cutting concern (§8) → state machine. Load only the matching `uml/*.md` file.
5. When the object model or a cross-service integration calls for a named, reusable solution (not a one-off diagram), point to the sibling `design-patterns` skill rather than re-deriving pattern content here.
6. For arc42 §9 (Architecture Decisions): don't author decisions directly in this workflow. When a decision made in steps 1-5 is hard to reverse, would surprise a future reader, or was a genuine trade-off between real alternatives, stop and suggest running `grill-with-docs` to stress-test and record it in `docs/adr/`. §9 itself should only ever be a list of links into that folder.

**In retrofit mode:**

Replace step 1's interview with codebase exploration — infer the goals, constraints, actors, and structure from what's already built. Then follow steps 2-6 the same way, but confirm each inferred piece (the Context boundary, the Container split, any UML diagram) with the user before writing it down, since inference can be wrong in ways an interview isn't.

</what-to-do>

<supporting-info>

## Reference files

Load only the file matching what you're producing right now — don't preload the whole set.

- [arc42.md](arc42.md) — the 12 arc42 sections: what each is for, what to interview about, which diagram technique fills it.
- [c4/context.md](c4/context.md), [c4/container.md](c4/container.md), [c4/component.md](c4/component.md) — the three C4 zoom levels, in the order you'd normally produce them.
- [uml/class.md](uml/class.md), [uml/sequence.md](uml/sequence.md), [uml/state-machine.md](uml/state-machine.md), [uml/component.md](uml/component.md) — the curated core UML set used for detail beyond what C4 shows. This is a deliberately narrow slice of full UML — see each file for when (and when not) to reach for it.

All diagram examples use Mermaid, so every example renders natively in Markdown previews, GitHub, and Claude Artifacts with no external toolchain.

## Working with sibling skills

- **`design-patterns`** — the GoF and event-driven pattern catalog. This workflow produces the *shape* of a system (diagrams, doc structure); `design-patterns` supplies the *named solution* when a piece of that shape is a recognizable, reusable pattern. Don't duplicate pattern descriptions here — link out.
- **`grill-with-docs`** — stress-tests a plan against existing docs and records decisions as ADRs (`docs/adr/`) and glossary entries (`CONTEXT.md`). This workflow is generative (it originates a design from a blank slate, or infers one from code); `grill-with-docs` is adversarial (it pressure-tests a design that already exists). Run this workflow first to produce the shape, then `grill-with-docs` to harden and record the decisions inside it — particularly for arc42 §9. Don't invent a second ADR or glossary mechanism inside this workflow; arc42 §9 and §12 are pointers into `grill-with-docs`' machinery, not parallel content.
- **`aws-solutioner`** (agent, not a skill) — a persona for AWS/cloud infrastructure trade-off decisions (reliability, cost, performance pillars), typically spawned as a subagent inside a build pipeline like `build-with-team`. This skill is a different job: a cloud-agnostic, inline workflow for producing arc42/C4/UML documentation regardless of what infrastructure the system runs on. When a decision in this workflow turns out to hinge on AWS-specific trade-offs (which managed service, what RTO/RPO, cost model), that's the point to bring in `aws-solutioner` rather than reasoning about it here.

</supporting-info>
