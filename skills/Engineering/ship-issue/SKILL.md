---
name: ship-issue
description: Take a GitHub issue to a reviewed PR — plan and write hold-out evals with the user, implement via the implement skill, verify and review in parallel with fresh agents, run a capped fix loop (max 3 rounds), then commit and open a PR. Use when the user wants to ship, implement, or work a GitHub issue end-to-end, or says "/ship-issue #N".
---

# Ship Issue

A **workflow skill**: you are the **orchestrator**. You own every interaction with the user, the evals, git, and the PR. Subagents do the implementing, verifying, and reviewing. Agent prompt templates and report formats are in [handoffs.md](handoffs.md).

Invocation: `/ship-issue <issue number | issue URL>`. If no issue is given, ask for one.

```
Preflight → Plan checkpoint (HITL) → Implement → [Verify ∥ Review] → pass? → Ship
                                          ▲                         │ fail (≤3 fix rounds)
                                          └──── Fix (same agent) ◄──┘
```

## Step 0 — Preflight

1. Read the issue and its comments: `gh issue view <n> --comments` (follow the `gh-github` skill's conventions). If the issue links a PRD, read it too.
2. If the issue lists **Blocked by** issues, check whether they're still open (`gh issue view <m> --json state`). Warn the user about any open blockers and ask whether to continue.
3. Find the default branch (`gh repo view --json defaultBranchRef -q .defaultBranchRef.name`) and fetch it.
4. Create an isolated worktree on branch `issue-<n>-<slug>` (slug = kebab-case issue title, ≤ 5 words) off the default branch. Prefer the `EnterWorktree` tool; otherwise run `git worktree add ../<repo>-issue-<n> -b issue-<n>-<slug> origin/<default>` and `cd` into it. Every subagent works inside this worktree. Never modify the user's main checkout.
5. Create an **eval directory outside the worktree**: the session scratchpad if one exists, otherwise `${TMPDIR:-/tmp}/ship-issue-<repo>-<n>/`. Record its absolute path.

## Step 1 — Plan checkpoint (the only human-in-the-loop step)

Everything after this step runs unattended, so settle every open question here.

1. Explore the codebase: the integration points the issue touches, existing conventions, the test framework.
2. Find the **test and lint commands**. Prefer `make test` and `make lint`. If they don't exist, detect the repo's own commands (`npm test`, `pytest`, `go test ./...`, `ruff`, `eslint`, …) and confirm them with the user.
3. If the issue is ambiguous or has no acceptance criteria, ask the user clarifying questions **one at a time**, and give your recommended answer with each. Don't edit the issue.
4. Draft the **implementation plan**:
   - Interface changes (public signatures, CLI flags, endpoints, schema).
   - Behaviors to implement, in priority order. These are behaviors, not implementation steps.
   - Test and lint commands.
5. Write the **evals** into the eval directory (formats in [handoffs.md](handoffs.md#eval-formats)):
   - `checklist.md` — Given/When/Then scenarios covering every acceptance criterion plus the important edge cases. Each scenario gets an exact verification method (a command and its expected output, or a precise observable result).
   - `tests/` — **executable acceptance tests** in the repo's test framework, wherever that's feasible. They exercise the public interface only. Record each one's intended destination path in the repo.
6. Draft the **manual validation steps**: checks of the deployed behavior, to be run later by `/validate-pr` against the shared dev environment. Use the format in [validate-pr's handoffs](../validate-pr/handoffs.md#manual-validation-section-format). Unlike evals, they aren't hold-out. They go in the PR body.
7. Show the user the plan, the eval checklist, and the manual validation steps, and get their approval. Revise until they approve.

**Evals are hold-out.** The implementer never sees the eval files or their contents. This keeps it from coding to the tests instead of to the issue.

## Step 2 — Implement

Spawn **one** `general-purpose` agent named `implementer`, using the [Implementer prompt](handoffs.md#implementer-prompt). Give it the issue, the approved plan, and the worktree path, but **not the evals**. It invokes the `implement` skill and starts at Phase 2 (tracer bullet), because Phase 1 planning is already approved. It doesn't commit.

Wait for its summary: behaviors covered, tests added, any deviations from the plan.

## Step 3 — Verify ∥ Review

Spawn these agents **in parallel, in a single message**, and start them **fresh every round** so each one has a clean context:

| Agent | When | Prompt |
|---|---|---|
| `qa-engineer` (verifier) | always | [Verifier prompt](handoffs.md#verifier-prompt) |
| `senior-developer` (reviewer) | always | [Reviewer prompt](handoffs.md#reviewer-prompt) |
| `aws-solutioner` (AWS reviewer) | only when the diff touches AWS/IaC* | [AWS reviewer prompt](handoffs.md#aws-reviewer-prompt) |

\* Check with `git diff --name-only <default>...` plus a content grep. Spawn the AWS reviewer if you see any of: `*.tf`, `*.tfvars`, CDK code (`aws-cdk-lib`, `aws_cdk`), CloudFormation/SAM templates (`AWSTemplateFormatVersion`, `Transform: AWS::Serverless`), `serverless.yml`, or AWS SDK usage (`boto3`, `@aws-sdk/`, `aws-sdk-go`, `aws/aws-sdk-php`).

The verifier works **locally only**. Deployed-environment validation happens after the PR is open, via `/validate-pr`, which runs the PR's manual validation steps. Reviewers don't modify code.

## Step 4 — Gate and fix loop

A round **passes** only if all of these hold:
- every eval scenario passes (checklist and executable tests),
- the test and lint commands pass,
- no review finding is a **blocking finding** (severity `blocker` or `major`).

Minor findings never block. Collect them for the PR body.

If the round fails:
1. Consolidate everything into one [Fix report](handoffs.md#fix-report): the failing scenarios with their descriptions, expected vs. actual, and the command output; failing test or lint output; and the blocking findings. Leave out the eval test code, so the evals stay hold-out.
2. Send the report to the **same** `implementer` with `SendMessage`, so it keeps its context and design choices.
3. Once it reports back, go back to Step 3 with **fresh** verifier and reviewer agents. Each verify pass checks the scenarios again in full, not only the ones that failed.

**Cap: at most 3 fix rounds** after the initial implementation. If round 3 still fails, **stop and don't commit**. Show the user the remaining blockers and ask them to choose one:
- open a **draft** PR with the blockers listed in the body,
- run more fix rounds (ask how many),
- abandon. The worktree and branch stay in place for manual work.

## Step 5 — Ship

1. Copy the executable eval tests from the eval directory to their recorded destinations in the repo's test suite.
2. Run the test and lint commands one last time. **Both must pass.** If they fail now (e.g. the eval tests clash with lint rules), fix it trivially yourself or treat it as one more fix round.
3. Stage everything and make **one** commit:
   ```
   <type>: <issue title> (#<n>)

   <1–3 line summary>

   Co-Authored-By: <the attribution trailer from your system instructions>
   ```
   `<type>` is a conventional-commit type (`feat`, `fix`, `refactor`, …) chosen from the nature of the issue.
4. Push: `git push -u origin issue-<n>-<slug>`.
5. Open the PR with `gh pr create` (ready for review, base = default branch), using the [PR body](handoffs.md#pr-body) template. It must contain `Closes #<n>`.
6. Report the PR URL to the user. If you created the worktree yourself, tell them where it is; it can be removed once the PR merges. Suggest `/validate-pr <pr#>` to deploy it and run the manual validation steps.

## Rules

- Only the orchestrator talks to the user. Subagent prompts must say that the plan is already approved and they must not ask questions. If they're blocked, they report the blocker.
- Only the orchestrator commits, pushes, or touches GitHub.
- Never show the eval files to the implementer.
- Verifier and reviewers start fresh every round. The implementer is resumed, never replaced, unless it becomes unreachable.
- Don't skip the gate. Don't weaken or delete an eval to make a round pass. If an eval itself is wrong, stop and confirm the change with the user.
