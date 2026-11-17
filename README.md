# ai-config

A personal collection of AI coding-tool **skills**, **agents**, and **MCP server definitions**, installed into Claude Code, Cursor, and Pi by a single interactive script.

Everything lives in this repo as the source of truth. The installer symlinks skills and agents into each tool, so edits here take effect immediately — no reinstall needed.

## Quick start

```bash
git clone <this-repo> ~/ai-config
cd ~/ai-config
make install        # or: ./install.sh
```

The installer:

1. Detects which supported tools exist on this machine.
2. Lists every skill, agent, and MCP server it finds and asks which to install (comma-separated numbers, `a` for all, blank to skip).
3. Installs your selection into every detected tool that supports it.

Re-running is safe: existing correct links are reported as `[ok]`, links pointing elsewhere are `[relink]`ed, and real files or directories already at a destination are `[skip]`ped and never overwritten.

### Requirements

- `bash` (works with the macOS default bash 3.2)
- At least one supported tool installed (see below)
- For MCP servers only: [`jq`](https://jqlang.github.io/jq/) (`brew install jq`), and the `claude` CLI on `PATH` for Claude Code
- For linting: [`shellcheck`](https://www.shellcheck.net/)

## Supported tools (targets)

| Target      | Detected by    | Skills | Agents | MCP servers |
|-------------|----------------|:------:|:------:|:-----------:|
| Claude Code | `~/.claude`    | ✅ | ✅ | ✅ |
| Cursor      | `~/.cursor`    | ✅ | ✅ | ✅ |
| Pi          | `~/.pi/agent`  | ✅ | — | — |

Pi is a skills-only target by design: it has no sub-agents or built-in MCP, so the installer skips agents and MCP servers for it.

### Where things are installed

| Element | Claude Code | Cursor | Pi |
|---------|-------------|--------|----|
| Skill   | `~/.claude/skills/<name>` (flattened) | `~/.cursor/skills/<Category>/<name>` | `~/.pi/agent/skills/<Category>/<name>` |
| Agent   | `~/.claude/agents/<name>` | `~/.cursor/agents/<name>` | — |
| MCP     | `claude mcp add-json <name> … --scope user` | merged into `~/.cursor/mcp.json` under `mcpServers` | — |

Claude Code only discovers skills one directory deep, so its skill links drop the category folder. Skill names therefore have to stay unique across categories.

## What's included

### Skills

**Engineering** (`skills/Engineering/`)

| Skill | What it does |
|-------|--------------|
| `software-architect` | Designs and documents architecture: C4 diagrams in Mermaid, an arc42 doc tree, and UML where needed. Also retrofits docs onto existing systems. |
| `design-patterns` | On-demand reference for the 23 GoF patterns and event-driven patterns (sagas, CQRS, event sourcing, …), with TypeScript examples. |
| `implement` | TDD red-green-refactor workflow that also writes interface and implementation comments. |
| `improve-codebase-architecture` | Finds refactoring opportunities, mainly by deepening shallow modules to make code easier to test. |
| `grill-with-docs` | Stress-tests a plan against the project's domain model and updates `CONTEXT.md` and ADRs inline. |
| `to-prd` | Turns the current conversation into a PRD. |
| `to-issues` | Breaks a plan or PRD into GitHub issues, one vertical slice each. |
| `ship-issue` | Workflow skill: takes a GitHub issue to a reviewed PR (hold-out evals, implement, parallel verify + review, up to 3 fix rounds). |
| `validate-pr` | Workflow skill: deploys a PR's worktree to the shared dev environment, has a QA agent run its manual validation steps, and posts the results on the PR. |

**Research** (`skills/Research/`)

| Skill | What it does |
|-------|--------------|
| `grill-me` | Interviews you relentlessly about a plan until every branch of the decision tree is resolved. |
| `ontology-interview` | Interviews you one question at a time to build a business ontology (YAML), a Mermaid flowchart, and test questions. |

**Tools** (`skills/Tools/`)

| Skill | What it does |
|-------|--------------|
| `gh-github` | Uses the `gh` CLI to manage GitHub repos, issues, PRs, and Projects v2. |

### Agents

| Agent | Purpose |
|-------|---------|
| `aws-solutioner` | AWS solutions architect grounded in the Well-Architected Framework. |
| `qa-engineer` | Tests from the user's side, hunts edge cases, and validates behavior in a deployed dev environment. |
| `senior-developer` | Enforces SOLID, DRY, TDD, and readability in reviews and implementation. |

### MCP servers

None are defined yet. `mcp/` is ready for them (see [Adding an MCP server](#adding-an-mcp-server)).

## Repository layout

```
ai-config/
├── skills/<Category>/<name>/SKILL.md   # one folder per skill, plus any supporting .md files
├── agents/<name>/AGENT.md              # one folder per agent
├── mcp/<name>/mcp.json                 # one folder per MCP server
├── docs/adr/                           # architecture decision records
├── install.sh                          # interactive installer
├── CONTEXT.md                          # glossary and conceptual model
└── Makefile
```

A folder counts as an element only when it holds its marker file (`SKILL.md`, `AGENT.md`, or `mcp.json`). Folders above it are **categories**: they only group elements in the picker and can be nested to any depth.

## Development

### Make targets

| Target | Runs |
|--------|------|
| `make install` | `./install.sh` |
| `make lint` | `shellcheck install.sh` |
| `make test` | `bash -n install.sh` (syntax check) |

Before committing, run `make lint` and `make test` and make sure both pass.

### Adding a skill

1. Create `skills/<Category>/<skill-name>/SKILL.md` with YAML frontmatter:
   ```markdown
   ---
   name: skill-name
   description: What it does and when to use it (this is what the tool matches on).
   ---
   ```
2. Put any supporting reference files next to it. The skill loads them on demand.
3. Make sure the name doesn't clash with a skill in another category.
4. Run `./install.sh` and select it.

### Adding an agent

1. Create `agents/<agent-name>/AGENT.md` describing the agent's role, behavior, and tools.
2. Run `./install.sh` and select it.

### Adding an MCP server

1. Create `mcp/<server-name>/mcp.json` using Claude Code's schema. Cursor uses the same shape, so one file serves both:
   ```json
   { "type": "http", "url": "https://example.com/mcp" }
   ```
   or
   ```json
   { "type": "stdio", "command": "npx", "args": ["-y", "some-server"], "env": {} }
   ```
2. Run `./install.sh` and select it.

## Troubleshooting

- **"no supported target found"**: none of `~/.claude`, `~/.cursor`, or `~/.pi/agent` exist. Install or launch one of those tools first.
- **`[skip] … real file/dir at …`**: a non-symlink is already at the destination. Move or delete it yourself, then re-run.
- **Skill not showing up in Claude Code**: check that `~/.claude/skills/<name>` exists with no category subfolder, and that it points into this repo (`ls -la ~/.claude/skills/`).
- **MCP install fails**: install `jq`, and for Claude Code make sure `claude` is on your `PATH`.

## Further reading

- [`CONTEXT.md`](CONTEXT.md): the project glossary (Element, Target, Category, Workflow skill, Eval, …)
- [`docs/adr/`](docs/adr/): decisions such as installing MCP by config merge and how pattern families are organized
- Each element's own `SKILL.md` / `AGENT.md`: full usage details

## License

[MIT](LICENSE). Some skills are derived from [mattpocock/skills](https://github.com/mattpocock/skills) (also MIT); see [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

## Author

Gabriel Quiles
