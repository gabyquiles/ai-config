---
name: gh-github
description: Manage GitHub from the command line with the `gh` CLI — repositories (create/read/update), issues (read/create/update), pull requests (read/create/update/merge), and Projects v2 (read/create/update items). Use when the user wants to work with GitHub repos, issues, PRs, or project boards.
---

# GitHub via `gh`

Drive GitHub using the official `gh` CLI. Prefer `gh` subcommands over raw API calls; drop to `gh api` only for things the porcelain commands cannot do.

## Prerequisites

1. **Check `gh` is installed:** `gh --version`. If missing, tell the user to install it (`brew install gh` on macOS).
2. **Check authentication before any command:** `gh auth status`. If not logged in, ask the user to run `gh auth login`.
3. **Projects need extra scope.** `gh project` requires the `project` (or `read:project` for read-only) OAuth scope. If a project command fails with a scope error, tell the user to run:
   ```bash
   gh auth refresh -s project        # read + write
   gh auth refresh -s read:project   # read only
   ```

## Golden rules

- **Confirm the target.** Always know which repo/owner you are acting on. Pass `--repo OWNER/REPO` explicitly when not inside the target repo's working directory, and `--owner` for projects.
- **Reads are free; writes are not.** `list`/`view` commands are safe to run freely. Before any **state-changing** action (create, edit, comment, close, merge, delete, visibility change), state what will happen and get explicit user confirmation.
- **Never destroy without a strong confirmation.** Repo delete, project delete, and PR merge are irreversible or high-impact — require an unambiguous "yes" first.
- **Machine-readable reads.** For anything you need to parse, use `--json <fields>` (issues/PRs/repos) or `--format json` (projects), optionally with `--jq`.
- **Never leak secrets** into issue/PR bodies, comments, or commits.

## Repositories

Common tasks (`create`, `view`, `list`, `edit`):

```bash
gh repo view OWNER/REPO
gh repo list OWNER --limit 30
gh repo create NAME --private --description "..."
gh repo edit OWNER/REPO --description "..."
```

See [references/repos.md](references/repos.md) for full recipes and JSON fields.

## Issues

Common tasks (`list`, `view`, `create`, `edit`, `comment`, `close`/`reopen`):

```bash
gh issue list --state open --label bug
gh issue view NUMBER --comments
gh issue create --title "..." --body "..." --label bug
gh issue edit NUMBER --add-label triage
```

See [references/issues.md](references/issues.md) for full recipes and filters.

## Pull Requests

Common tasks (`list`, `view`, `create`, `edit`, `comment`, `ready`, `merge`, `close`/`reopen`):

```bash
gh pr list --state open
gh pr view NUMBER --comments
gh pr create --base main --head feature --title "..." --body "..."
gh pr edit NUMBER --add-reviewer USER
```

`gh pr merge` is high-impact — confirm strategy (merge/squash/rebase) with the user first. See [references/pull-requests.md](references/pull-requests.md).

## Projects (Projects v2)

Common tasks (`list`, `view`, `create`, `edit`, item management, fields):

```bash
gh project list --owner @me
gh project view NUMBER --owner OWNER
gh project item-list NUMBER --owner OWNER
gh project item-add NUMBER --owner OWNER --url ISSUE_OR_PR_URL
```

Projects use a project **number** scoped to an `--owner` (a user or org). See [references/projects.md](references/projects.md).
