# Skills spanning multiple sub-topics use one subfolder per pattern family, not fully flat

`software-architecture` holds reference files for multiple pattern families (GoF now, others like event-driven later), unlike every other skill in this repo, which covers one topic and keeps its reference files flat next to `SKILL.md`. We group each family in its own subfolder (`gof/`, later `event-driven/`, etc.) with pattern files flat inside — no further nesting by category — because the family boundary is the one that stays stable as the skill grows, while a fully-flat listing (`gof-singleton.md`, `gof-factory-method.md`, ...) would get visually cluttered once more families are added.

## Considered Options
- **Fully flat with prefixed filenames** (`gof-singleton.md`) — rejected: doesn't scale visually as families are added, and the prefix is redundant with the folder name it should've been.
- **Category subfolders within each family** (`gof/creational/singleton.md`) — rejected: adds nesting depth with no functional benefit, since category grouping already lives in `SKILL.md`'s index; also GoF's clean 3-category split isn't guaranteed for future families.
