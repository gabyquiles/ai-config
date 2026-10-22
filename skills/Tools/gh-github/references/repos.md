# Repositories (`gh repo`)

Full recipes for creating, reading, and updating repositories. `repo delete` is intentionally omitted from routine use — only run it after an explicit, unambiguous confirmation from the user.

## Read

```bash
# View a repo (readme, description, stats)
gh repo view OWNER/REPO

# View in the browser
gh repo view OWNER/REPO --web

# List repos for a user or org
gh repo list OWNER --limit 50
gh repo list OWNER --visibility private
gh repo list OWNER --source --no-archived   # only non-fork, non-archived
```

### JSON output for parsing

```bash
gh repo view OWNER/REPO --json name,description,visibility,defaultBranchRef,url,isArchived
gh repo view OWNER/REPO --json stargazerCount,forkCount --jq '.stargazerCount'
gh repo list OWNER --json name,visibility,updatedAt --limit 100
```

List available fields with `gh repo view --json` (no value) or check `gh repo view --help`.

## Create

```bash
# Interactive
gh repo create

# Create an empty remote repo
gh repo create OWNER/NAME --private --description "My project"
gh repo create OWNER/NAME --public --description "..." --clone

# Create from the current local directory and push
gh repo create OWNER/NAME --private --source=. --remote=origin --push

# From a template
gh repo create OWNER/NAME --template OWNER/TEMPLATE --private
```

Key flags: `--public` / `--private` / `--internal`, `--description`, `--homepage`, `--source`, `--remote`, `--push`, `--clone`, `--template`, `--gitignore`, `--license`, `--add-readme`, `--disable-issues`, `--disable-wiki`.

## Update (`edit`)

```bash
gh repo edit OWNER/REPO --description "New description"
gh repo edit OWNER/REPO --homepage "https://example.com"
gh repo edit OWNER/REPO --default-branch main
gh repo edit OWNER/REPO --add-topic cli --add-topic github
gh repo edit OWNER/REPO --remove-topic old-topic
gh repo edit OWNER/REPO --enable-issues --enable-wiki

# Visibility change — confirm with the user first (affects access)
gh repo edit OWNER/REPO --visibility private
```

Other useful flags: `--enable-projects`, `--enable-discussions`, `--allow-update-branch`, `--delete-branch-on-merge`, `--enable-auto-merge`, `--allow-forking`.

## Notes

- Omit `OWNER/REPO` to act on the repo of the current working directory (if inside a clone).
- Use `--repo OWNER/REPO` (or the positional arg) to target a different repo from anywhere.
