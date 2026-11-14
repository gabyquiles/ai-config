---
name: validate-pr
description: Deploy a pull request to the shared dev environment and run its manual validation steps — find or create the PR's worktree, sync it to the PR head, run `make install` and `make deploy`, have a fresh QA agent execute the PR's "Manual validation" section (handing un-automatable steps to the user), and post the results as a PR comment. Use when the user wants to validate, deploy and test, or QA a PR in a deployed environment, or says "/validate-pr #N".
---

# Validate PR

A **workflow skill**: you are the **orchestrator**. You own every interaction with the user, git, and GitHub. A fresh `qa-engineer` subagent executes the validation steps. Prompt templates and formats are in [handoffs.md](handoffs.md).

Invocation: `/validate-pr <PR number | PR URL>`. If no PR is given, ask for one.

```
Preflight → Worktree (sync to PR head) → Confirm → make install → make deploy → Validate (qa-engineer) → Human steps (HITL) → PR comment
```

This is the deployed-environment counterpart to `ship-issue`, which only verifies locally. It **reports only**: it never changes code, commits, or pushes.

## Step 0 — Preflight

1. Read the PR: `gh pr view <n> --json number,title,url,state,headRefName,headRefOid,body` (follow the `gh-github` skill's conventions).
2. If `state` isn't `OPEN`, warn the user and ask whether to continue.
3. Extract the `## Manual validation` section from the body (format in [handoffs.md](handoffs.md#manual-validation-section-format)). If it's missing or has no steps, stop and ask the user: they can paste steps to use for this run, or abort. Don't edit the PR body.

## Step 1 — Worktree

The goal is a worktree whose `HEAD` is exactly the PR head. Never modify the user's main checkout.

1. `git fetch origin <headRefName>`.
2. Find an existing worktree on that branch: in `git worktree list --porcelain`, look for a `branch refs/heads/<headRefName>` entry. Match on the branch, not the folder name, so `ship-issue` worktrees (`../<repo>-issue-<n>`) are reused.
3. **None found:** `git worktree add --track -b <headRefName> ../<repo>-pr-<n> origin/<headRefName>`. If a local branch with that name already exists outside any worktree, use `git worktree add ../<repo>-pr-<n> <headRefName>` instead and treat it like an existing worktree in the next step.
4. **Found (or local branch reused):** inside it,
   - uncommitted changes (`git status --porcelain` non-empty) → **stop and ask**. The deploy wouldn't match what's under review.
   - ahead of `origin/<headRefName>` (`git rev-list --count origin/<headRefName>..HEAD` > 0) → **stop and ask**, same reason.
   - behind → `git merge --ff-only origin/<headRefName>`.
5. Record `git rev-parse HEAD` as the **deployed SHA** and check it equals `headRefOid`. If it doesn't, stop and report.

## Step 2 — Install and deploy

1. Check the worktree's Makefile has both targets: `make -n install` and `make -n deploy`. If either is missing, stop and tell the user.
2. **Confirm with the user** before deploying: "Deploying `<short SHA>` of PR #<n> to the shared dev environment. This overwrites whatever is deployed there. Continue?" Only run `make deploy` exactly as defined. Never add prod/stage arguments or environment overrides.
3. In the worktree, run `make install`, then `make deploy`. If either fails, stop and show the user the last ~50 lines of output. Don't retry or attempt a fix.
4. From the deploy output, capture anything the validator will need: URLs, endpoints, stack outputs, resource names.

## Step 3 — Validate

Spawn **one fresh** `qa-engineer` agent named `validator`, using the [Validator prompt](handoffs.md#validator-prompt). Give it the PR title and URL, the steps verbatim, the worktree path, the deployed SHA, and the deploy outputs.

It runs every step against the deployed environment and returns the [Validator report](handoffs.md#validator-report). Each step is `pass`, `fail`, `blocked` (a prerequisite step failed), or `needs-human` (it can't be automated, or it was marked `(human)`).

## Step 4 — Human steps

For each `needs-human` step, ask the user **one at a time**: show the action, the expected result, and any context the validator gathered. Record their answer as `pass` or `fail`, with their note as evidence and `user` as the runner. If the user skips a step, record it as `not run`.

## Step 5 — Report

1. Post **one** comment on the PR with `gh pr comment <n> --body-file <file>`, using the [Results comment](handoffs.md#results-comment) template. Don't change labels, reviews, or the PR body.
2. Summarize in chat: overall result, any failing steps with their evidence, and the comment URL.
3. Leave the worktree in place and tell the user its path.

## Rules

- Only the orchestrator talks to the user or touches GitHub. The validator prompt must say it can't ask questions and must not modify code or GitHub.
- No commits, pushes, or code changes. A failure is reported, not fixed. The user decides whether to send it back through `ship-issue`.
- Deploy only the exact PR head, and only after the user confirms.
- Run every step even after a failure, unless it depends on a failed step (then it's `blocked`).
- Never reword or weaken a step to make it pass. If a step looks wrong, report it as such.
