# arc42: Documentation Structure

arc42 is a template for architecture documentation: 12 sections, each answering a specific question a reader would otherwise have to dig for. Unlike the diagrams in `c4/` or `uml/`, arc42 isn't something to pick one of — it's the container all of them go in. Scaffold it in the target project under `docs/arc42/`, one file per section, using arc42's own canonical naming (`01_introduction_and_goals.md` … `12_glossary.md`). Create files lazily, as each section actually resolves — an empty section is worse than a missing one, since it looks decided when it isn't.

Not every section needs to be filled for every system. A small service might only need 1, 3, 5, 9. Don't pad thin sections to look complete.

## 1. Introduction and Goals

What the system does, who it's for, and the top 3-5 quality goals that should drive every trade-off decision below (e.g. "reads must be fast even if writes are eventually consistent"). Interview: what problem does this solve, who are the stakeholders, what does success look like, and — critically — what would make this project a failure even if it technically works (the goals that don't show up in a feature list).

## 2. Constraints

Non-negotiables imposed from outside the design: technology mandates, compliance requirements, deadlines, team skill constraints, existing systems it must integrate with. Interview: what's already decided and off the table, and why (this is often the most valuable section for a future reader wondering "why didn't they just use X").

## 3. Context and Scope

The system as a black box: who/what it talks to, and where its boundary is. This is exactly a C4 System Context diagram — see [c4/context.md](c4/context.md). Interview: who are the external actors and systems, and what crosses the boundary (data, not implementation).

## 4. Solution Strategy

The handful of fundamental decisions that shape everything else — architecture style (monolith/microservices/event-driven), key technology choices, how top quality goals from §1 get achieved. This is a summary, not a spec: 1-2 paragraphs, each decision expanded later where it belongs (§5 for structure, §8 for cross-cutting approach, §9 for the record of *why*).

## 5. Building Block View

The static decomposition: containers and components, and how they nest. This is a C4 Container diagram, optionally drilling into Component diagrams for containers complex enough to warrant it — see [c4/container.md](c4/container.md) and [c4/component.md](c4/component.md). When a container's internal object model needs more precision than a box-and-line diagram gives, drop into a UML class diagram — see [uml/class.md](uml/class.md). If a named design pattern is doing the work inside a component (e.g. Strategy, Saga, CQRS), don't re-explain it here — link to the pattern in the sibling `design-patterns` skill instead.

## 6. Runtime View

How the building blocks collaborate for the scenarios that matter most (a critical user flow, an error path, a startup sequence). This is UML sequence diagrams, one per scenario that's worth documenting — not every possible flow — see [uml/sequence.md](uml/sequence.md).

## 7. Deployment View

Where the containers actually run: infrastructure, environments, network boundaries. Often a variant of the C4 Container diagram annotated with deployment nodes rather than a distinct diagram type of its own — see [c4/container.md](c4/container.md). Interview: what environments exist (dev/staging/prod), what runs where, and what crosses a trust or network boundary.

## 8. Crosscutting Concepts

Concerns that cut across multiple building blocks rather than living in one: error handling strategy, logging/observability, security/auth approach, persistence conventions, i18n. Interview: what conventions does every component need to follow, and are any of them a named pattern worth linking to in `design-patterns` (e.g. a consistent Idempotent Consumer approach across all message handlers). A stateful concern that spans components (e.g. a workflow or approval process) is often better shown as a UML state machine diagram than described in prose — see [uml/state-machine.md](uml/state-machine.md).

## 9. Architecture Decisions

This section is a **pointer, not content**: list the significant decisions with one-line summaries and links into `docs/adr/` in the target project — don't duplicate ADR bodies here. Populate `docs/adr/` using the `grill-with-docs` skill's ADR format, not by writing decisions directly in this workflow. When a decision made anywhere else in this scaffolding process (§4, §5, §8) is hard to reverse, would surprise a future reader, or was a genuine trade-off between real alternatives, that's the signal to stop and run `grill-with-docs` before moving on, rather than pressing ahead and letting the decision go unrecorded.

## 10. Quality Requirements

The quality goals from §1, made concrete and testable: specific scenarios with a measurable bar ("search results return in <200ms at p95 under 1000 rps"), not adjectives ("fast", "scalable"). Interview: for each top-level goal, what's the concrete scenario that would prove or disprove it.

## 11. Risks and Technical Debt

Known weak points and deliberate shortcuts, named explicitly rather than left implicit. Interview: what are you worried about, and what did you knowingly defer (and why that was the right call *for now*). This section ages — revisit it rather than treating it as write-once.

## 12. Glossary

Precise definitions for domain terms used throughout the document, so "order" or "account" means one thing consistently. If the target project already has a `CONTEXT.md` (the `grill-with-docs` skill's glossary convention), point here to that file instead of maintaining a second glossary — a term should have exactly one canonical definition, not one per documentation system.
