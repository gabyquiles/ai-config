# Projects (`gh project`, Projects v2)

Full recipes for reading, creating, and updating GitHub Projects (v2) and their items.

## Scope requirement

`gh project` needs the `project` scope (or `read:project` for read-only). If a command fails with a scope error:

```bash
gh auth refresh -s project        # read + write
gh auth refresh -s read:project   # read only
```

## Key concepts

- A project is identified by a **number** scoped to an **owner** (`--owner`). The owner is a user or org login, or `@me` for the authenticated user.
- Items are issues, PRs, or draft issues on the board.
- Fields (Status, custom single-selects, dates, etc.) are set per item with `item-edit`, which needs the project's `--id` and the field's `--field-id`.
- Use `--format json` (optionally with `--jq`) for machine-readable output.

## Projects: read

```bash
gh project list --owner @me
gh project list --owner ORG --closed

gh project view NUMBER --owner OWNER
gh project view NUMBER --owner OWNER --format json
gh project view NUMBER --owner OWNER --web
```

## Projects: create / update

```bash
gh project create --owner OWNER --title "Q3 Roadmap"

gh project edit NUMBER --owner OWNER --title "New title"
gh project edit NUMBER --owner OWNER --readme "Board description"
gh project edit NUMBER --owner OWNER --visibility PUBLIC   # or PRIVATE

gh project close NUMBER --owner OWNER
gh project close NUMBER --owner OWNER --undo
```

`gh project delete` is destructive — only run it after an explicit confirmation.

## Items: read

```bash
gh project item-list NUMBER --owner OWNER
gh project item-list NUMBER --owner OWNER --limit 100 --format json
```

## Items: add / create / update

```bash
# Add an existing issue or PR by URL
gh project item-add NUMBER --owner OWNER --url https://github.com/OWNER/REPO/issues/123

# Create a draft issue directly on the board
gh project item-create NUMBER --owner OWNER --title "Investigate X" --body "..."

# Archive / delete an item (delete is destructive — confirm first)
gh project item-archive NUMBER --owner OWNER --id ITEM_ID
gh project item-delete NUMBER --owner OWNER --id ITEM_ID
```

## Fields

```bash
# Discover field IDs and option IDs
gh project field-list NUMBER --owner OWNER
gh project field-list NUMBER --owner OWNER --format json

# Set a field value on an item.
# --id is the PROJECT id, --item-id the item, --field-id the field.
gh project item-edit \
  --id PROJECT_ID \
  --item-id ITEM_ID \
  --field-id FIELD_ID \
  --single-select-option-id OPTION_ID     # for single-select fields

gh project item-edit --id PROJECT_ID --item-id ITEM_ID --field-id FIELD_ID --text "value"
gh project item-edit --id PROJECT_ID --item-id ITEM_ID --field-id FIELD_ID --number 3
gh project item-edit --id PROJECT_ID --item-id ITEM_ID --field-id FIELD_ID --date 2025-01-31
```

Get `PROJECT_ID`, `ITEM_ID`, `FIELD_ID`, and `OPTION_ID` from the `--format json` output of `project view`, `item-list`, and `field-list`.

## Notes

- Project numbers differ from issue/PR numbers; get them from `gh project list`.
- Setting a Status column = setting the Status single-select field via `item-edit` with the matching `--single-select-option-id`.
