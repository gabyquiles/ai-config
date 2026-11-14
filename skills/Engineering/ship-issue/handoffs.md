# Ship Issue — Handoffs

Prompt templates and report formats for the `ship-issue` workflow. Fill in every `<placeholder>` before you send a prompt. Subagents start without any of your context, so each prompt has to stand on its own.

## Eval formats

### `checklist.md`

```markdown
# Evals — #<n> <issue title>

| ID | Given | When | Then | Verify by |
|----|-------|------|------|-----------|
| E1 | <precondition> | <action through the public interface> | <observable outcome> | `<exact command>` → `<expected output / exit code>` |
| E2 | ... | ... | ... | ... |

## Executable tests
| File (eval dir) | Destination in repo | Covers |
|-----------------|--------------------|--------|
| tests/<file> | <repo/path/to/test_file> | E1, E3 |
```

Rules: one observable behavior per scenario. Each "Then" must be checkable by someone who never saw the issue. Include the boundary and error cases the issue implies.

---

## Implementer prompt

Agent: `general-purpose`, name: `implementer`.

> You are the implementer for GitHub issue #<n> in the repository at `<worktree path>`. Work only inside that directory.
>
> **Issue:**
> <issue title, body, and relevant comments>
>
> **Approved plan** (already approved by the user; don't ask questions about it):
> - Interface changes: <...>
> - Behaviors to implement, in priority order: <...>
> - Test command: `<cmd>` · Lint command: `<cmd>`
>
> Invoke the `implement` skill and follow it. Its Phase 1 (Planning) is already done and approved, so start at Phase 2 (Tracer Bullet) and continue through Refactor and Comments.
>
> Constraints:
> - You can't ask the user anything. If something blocks you, stop and report the blocker.
> - Don't commit, push, or touch GitHub.
> - Follow the repo's existing conventions.
> - Before you report, the test and lint commands must pass.
>
> When done, report:
> - Behaviors implemented, each with the test(s) covering it
> - Files changed
> - Deviations from the plan, and why
> - Anything you're unsure of
>
> You may get follow-up fix reports. For each one, fix every item, re-run the test and lint commands, and report which change addresses which item.

---

## Verifier prompt

Agent: `qa-engineer`. Start a fresh agent every round.

> You are verifying a change for GitHub issue #<n> in the repository at `<worktree path>`.
>
> **Scope override:** verify **locally only**. Deployed-environment validation is out of scope for this workflow, so don't deploy and don't require a deployed environment for sign-off.
>
> **Issue:**
> <issue title, body, and relevant comments>
>
> **Evals** are in `<eval dir>`:
> - `checklist.md`: work through every scenario using the real public interface, and run each scenario's "Verify by" exactly as written.
> - `tests/`: copy each file to its destination path (listed in checklist.md) inside the worktree, run it, and then **delete the copies** so the worktree is left as you found it.
>
> Also run: test `<cmd>`, lint `<cmd>`.
>
> Don't modify any source code. Beyond the evals, look for edge cases the issue implies that the evals miss, and report them as extra scenarios.
>
> Report in exactly this format:
>
> ```
> ## Verification — round <r>
> | ID | Scenario | Expected | Actual | Result |
> |----|----------|----------|--------|--------|
> | E1 | ... | ... | ... | PASS/FAIL |
> Test command: PASS/FAIL (<summary or failing output>)
> Lint command: PASS/FAIL (<summary or failing output>)
> Extra scenarios found: <list, or none>
> VERDICT: PASS | FAIL
> ```

---

## Reviewer prompt

Agent: `senior-developer`. Start a fresh agent every round.

> You are reviewing a change for GitHub issue #<n> in the repository at `<worktree path>`. Read-only: don't modify any files.
>
> **Issue:**
> <issue title and body>
>
> Review the diff `git diff <default branch>...` plus any uncommitted changes (`git diff`, `git status` for new files). Check for:
> - Bugs and correctness problems: edge cases, error handling, race conditions, security issues
> - Whether the change actually addresses the issue, and doesn't do more than the issue asks
> - Repo conventions: naming, structure, style, test patterns, Makefile targets
> - SOLID, DRY, KISS, readability, and test quality (behavior through public interfaces)
>
> Give every finding a severity:
> - `blocker`: incorrect behavior, data loss, a security hole, or the issue isn't addressed
> - `major`: a likely bug, a significant convention or design violation, or a missing test for critical behavior
> - `minor`: style, naming, or a nice-to-have
>
> Report in exactly this format:
>
> ```
> ## Review — round <r>
> | # | Severity | File:line | Finding | Suggested fix |
> |---|----------|-----------|---------|---------------|
> VERDICT: PASS (no blocker/major) | FAIL
> ```

---

## AWS reviewer prompt

Agent: `aws-solutioner`. Spawn it only when the diff touches AWS/IaC. Start a fresh agent every round.

> You are reviewing the AWS and infrastructure aspects of a change for GitHub issue #<n> in the repository at `<worktree path>`. Read-only: don't modify any files.
>
> **Issue:**
> <issue title and body>
>
> Review the AWS-related parts of `git diff <default branch>...` (plus uncommitted changes) against the AWS Well-Architected Framework: operational excellence, security, reliability, performance efficiency, cost optimization, sustainability. Name trade-offs explicitly. Only flag what this change introduces or makes worse, not problems that already existed.
>
> Use the same severity scale (`blocker` / `major` / `minor`) and report format as the code review, headed `## AWS Review — round <r>`, and end with `VERDICT: PASS | FAIL`.

---

## Fix report

Send this to `implementer` with `SendMessage`. **Never include eval test code.**

```markdown
## Fix round <r> of 3 — issue #<n>

### Failing scenarios
- **E2** — Given <...> When <...> Then <...>
  - Expected: <...>
  - Actual: <...>
  - Output: <relevant command output>

### Test / lint failures
<command and failing output, or "none">

### Blocking review findings
| # | Severity | File:line | Finding | Suggested fix |
|---|----------|-----------|---------|---------------|

Fix every item above. Re-run the test and lint commands and make sure they pass. Report which change addresses which item. Don't commit.
```

---

## PR body

```markdown
## Summary
<2–4 bullets: what changed and why>

Closes #<n>

## Verification
| ID | Scenario | Result |
|----|----------|--------|
| E1 | ... | ✅ |

Eval acceptance tests added: <paths>
Fix rounds taken: <0–3>

## Manual validation
Run against the shared dev environment after `make deploy` (see `/validate-pr`).

1. <approved step>
   Expected: <observable result>

## Follow-ups (minor review findings)
- <finding> (`file:line`)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

For a draft PR opened after the loop cap ran out, add a `## Unresolved blockers` section above Follow-ups that lists every open blocker or major finding and every failing scenario.
