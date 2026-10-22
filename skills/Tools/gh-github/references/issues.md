# Issues (`gh issue`)

Full recipes for reading, creating, and updating issues. Target a specific repo with `--repo OWNER/REPO` when not inside the repo's working directory.

## Read

```bash
# List (defaults to open issues)
gh issue list
gh issue list --state all
gh issue list --state closed --limit 100
gh issue list --label bug --label "help wanted"
gh issue list --assignee @me
gh issue list --author USER --milestone "v1.0"
gh issue list --search "memory leak in:title sort:created-desc"

# View a single issue, including the discussion thread
gh issue view NUMBER
gh issue view NUMBER --comments
gh issue view NUMBER --web
```

### JSON output for parsing

```bash
gh issue view NUMBER --json number,title,state,labels,assignees,body,url
gh issue list --json number,title,state,labels --jq '.[] | .number'
```

## Create

```bash
# Interactive
gh issue create

# Fully specified
gh issue create \
  --title "Fix login crash" \
  --body "Steps to reproduce..." \
  --label bug --label priority-high \
  --assignee @me \
  --milestone "v1.0" \
  --project "Roadmap"

# Body from a file (better for long/markdown bodies)
gh issue create --title "..." --body-file ./issue.md

# Body via heredoc
gh issue create --title "..." --body "$(cat <<'EOF'
## Summary
Multi-line markdown body.
EOF
)"
```

## Update (`edit`)

```bash
gh issue edit NUMBER --title "New title"
gh issue edit NUMBER --body "Replacement body"
gh issue edit NUMBER --body-file ./updated.md
gh issue edit NUMBER --add-label triage --remove-label needs-info
gh issue edit NUMBER --add-assignee USER --remove-assignee OTHER
gh issue edit NUMBER --milestone "v1.1"

# Edit several at once
gh issue edit 12 13 14 --add-label backlog
```

## Comment / close / reopen

```bash
gh issue comment NUMBER --body "Thanks, taking a look."
gh issue comment NUMBER --body-file ./comment.md

gh issue close NUMBER --reason completed      # or: not planned
gh issue close NUMBER --comment "Fixed in #42"
gh issue reopen NUMBER
```

## Notes

- `--label`, `--assignee`, and `--project` values must already exist in the repo.
- `@me` resolves to the authenticated user for `--assignee`.
- Closing/reopening changes state — confirm with the user before doing it in bulk.
