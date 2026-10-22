# Pull Requests (`gh pr`)

Full recipes for reading, creating, and updating pull requests. Target a specific repo with `--repo OWNER/REPO` when not inside the repo's working directory. Most `pr` commands accept a PR number, branch name, or URL; with no argument they use the PR of the current branch.

## Read

```bash
gh pr list
gh pr list --state all --limit 100
gh pr list --author @me --label needs-review
gh pr list --base main --search "sort:updated-desc"

gh pr view NUMBER
gh pr view NUMBER --comments
gh pr view                      # PR for the current branch
gh pr diff NUMBER               # show the diff
gh pr checks NUMBER             # CI status
gh pr status                    # PRs relevant to you
```

### JSON output for parsing

```bash
gh pr view NUMBER --json number,title,state,isDraft,mergeable,reviewDecision,headRefName,baseRefName,url
gh pr list --json number,title,author,reviewDecision --jq '.[] | select(.reviewDecision=="APPROVED")'
```

## Create

```bash
# Interactive (prompts for base/head/title/body)
gh pr create

# Fully specified
gh pr create \
  --base main \
  --head feature-branch \
  --title "Add search endpoint" \
  --body "What & why..." \
  --reviewer USER1 --reviewer team/backend \
  --assignee @me \
  --label enhancement \
  --milestone "v1.0"

# Draft PR
gh pr create --draft --title "WIP: ..." --fill

# Auto-fill title/body from commits
gh pr create --fill

# Body from a file
gh pr create --title "..." --body-file ./pr.md
```

`--head` may be `OWNER:branch` for cross-fork PRs.

## Update (`edit`)

```bash
gh pr edit NUMBER --title "New title"
gh pr edit NUMBER --body-file ./updated.md
gh pr edit NUMBER --add-reviewer USER --remove-reviewer OTHER
gh pr edit NUMBER --add-label ready --remove-label wip
gh pr edit NUMBER --add-assignee @me
gh pr edit NUMBER --base develop        # retarget base branch
gh pr edit NUMBER --milestone "v1.1"

gh pr ready NUMBER              # mark a draft as ready for review
gh pr ready NUMBER --undo      # convert back to draft
```

## Comment / review

```bash
gh pr comment NUMBER --body "Nice work."

# Reviews change state — confirm intent with the user first
gh pr review NUMBER --approve --body "LGTM"
gh pr review NUMBER --request-changes --body "See comments"
gh pr review NUMBER --comment --body "Question about X"
```

## Merge / close / reopen (HIGH IMPACT — confirm first)

`gh pr merge` is irreversible on the base branch. Always confirm the merge strategy with the user before running it.

```bash
gh pr merge NUMBER --squash --delete-branch
gh pr merge NUMBER --merge
gh pr merge NUMBER --rebase
gh pr merge NUMBER --auto --squash        # enable auto-merge when checks pass

gh pr close NUMBER
gh pr reopen NUMBER
```

## Notes

- `gh pr checkout NUMBER` checks out the PR branch locally for review/testing.
- Reviewers, labels, and milestones must already exist in the repo.
