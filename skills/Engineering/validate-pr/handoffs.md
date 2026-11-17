# Validate PR — Handoffs

Formats and prompt templates for the `validate-pr` workflow. Fill in every `<placeholder>` before you send a prompt. The validator starts without any of your context, so its prompt has to stand on its own.

## Manual validation section format

The source of truth for the steps, written in the PR body (`ship-issue` writes it during its Plan checkpoint):

```markdown
## Manual validation
Run against the shared dev environment after `make deploy`.

1. <action against the deployed environment>
   Expected: <observable result>
2. (human) <action that can't be automated, e.g. "check the welcome email arrives">
   Expected: <observable result>
3. (after 1) <action that depends on step 1>
   Expected: <observable result>
```

Rules:
- Each step is one action and one `Expected:` line that someone who never saw the code can check.
- Mark a step `(human)` when no agent could check it.
- Mark dependencies with `(after N)`, so a failure leads to `blocked` instead of a misleading failure.
- Steps check the **deployed** behavior. Don't repeat the local evals.

---

## Validator prompt

Agent: `qa-engineer`, name: `validator`.

> You are validating PR #<n> "<title>" (<url>) on the **shared dev environment**. Commit `<deployed SHA>` has just been deployed from the worktree at `<worktree path>`.
>
> **Deploy outputs:**
> <URLs, endpoints, stack outputs, resource names>
>
> **Manual validation steps** (run them exactly as written):
> <steps verbatim>
>
> For each step, perform the action against the deployed environment and compare with `Expected:`. Use whatever fits: `curl`, CLIs, reading logs, or Claude in Chrome for UI steps. Prefix AWS CLI commands with `AWS_PROFILE=dev AWS_REGION=us-east-1` so you check the same account and region that was deployed to.
>
> Constraints:
> - You can't ask the user anything. If you're blocked, report it.
> - Don't modify code, commit, push, redeploy, or touch GitHub. You may read the worktree to understand the change.
> - Run every step even if an earlier one fails, unless it is marked `(after N)` and step N failed. Then mark it `blocked`.
> - Mark a step `needs-human` if it's marked `(human)` or you genuinely can't check it. Say what you tried and what the user should look at.
> - Don't reinterpret a step to make it pass. If a step seems wrong or ambiguous, mark it `fail` and say so.
>
> Report using the format below.

## Validator report

```markdown
| # | Step | Result | Evidence |
|---|------|--------|----------|
| 1 | <short action> | pass / fail / blocked / needs-human | <command + relevant output, screenshot description, or what the user should check> |

Notes: <anything odd about the environment, flaky behavior, steps that look wrong>
```

---

## Results comment

```markdown
## Manual validation results

**Deployed:** `<deployed SHA>` to the shared dev environment
**Overall:** ✅ all passed | ❌ <k> failed | ⚠️ <k> not run

| # | Step | Result | Run by | Evidence |
|---|------|--------|--------|----------|
| 1 | <short action> | ✅ pass | agent | <short evidence> |
| 2 | <short action> | ❌ fail | user | <user's note> |
| 3 | <short action> | ⛔ blocked | — | depends on step 2 |

<Notes from the validator, if any>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```
