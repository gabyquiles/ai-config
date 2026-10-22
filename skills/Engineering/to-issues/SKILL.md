---
name: to-issues
description: Break a plan, spec, or PRD into independently-grabbable GitHub issues using tracer-bullet vertical slices. Use when user wants to convert a plan into issues, create implementation tickets, or break down work into issues.
---

# To Issues

Break a plan into independently-grabbable GitHub issues using vertical slices (tracer bullets).

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a GitHub issue number or URL as an argument, fetch it with `gh issue view <number>` (with comments).

### 2. Explore the codebase

If you have not already explored the codebase, do so before drafting acceptance criteria. Acceptance criteria must reference the real integration points (schema, API, UI) for a slice to be genuinely vertical rather than aspirational, so understanding the current state of the code is required, not optional.

### 3. Draft vertical slices

Break the plan into **tracer bullet** issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
- If a slice can't be described in 2-3 sentences, or touches more than a handful of layers, split it
</vertical-slice-rules>

Write the acceptance criteria for each slice against the rules below.

<acceptance-criteria-rules>
- Criteria describe observable, verifiable behavior, NOT implementation steps
- Each criterion should be checkable by someone who never saw this conversation
- Avoid implementation-coupled wording ("uses X library"); prefer outcome wording ("returns 404 when the record is missing")
</acceptance-criteria-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them). These are carried into the issue body, so confirm the story wording with the user during the quiz.

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user approves the breakdown.

### 5. Create the GitHub issues

For each approved slice, create a GitHub issue using `gh issue create`. Use the issue body template below.

Create issues in dependency order (blockers first) so you can reference real issue numbers in the "Blocked by" field.

Apply labels for `HITL`/`AFK` and, if a parent/epic exists, tag it — e.g. `gh issue create --label afk`. Labels are a suggestion, not mandatory: if the repo lacks a label, omit it rather than letting the command fail.

<issue-template>
## Parent

#<parent-issue-number> (if the source was a GitHub issue, otherwise omit this section)

## User story

As a <actor>, I want <feature>, so that <benefit>

(Carry forward from the source PRD if present; synthesize only if absent. Omit this section if not applicable.)

## Context

Why this slice exists, with a link back to the PRD or parent issue. One or two sentences. Omit if trivial.

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

## Acceptance criteria

- [ ] Observable behavior 1
- [ ] Observable behavior 2
- [ ] Observable behavior 3

## How to verify

How to demo or verify this slice on its own (a command to run, a UI step, or a test to execute).

## Out of scope

What this slice deliberately does not cover. Omit if trivial.

## Blocked by

- Blocked by #<issue-number> (if any)

Or "None - can start immediately" if no blockers.

</issue-template>

Do NOT close or modify any parent issue.
