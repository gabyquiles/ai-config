# ai-config

A personal repo of Claude Code skills, agents, and MCP server definitions, installed into AI coding tools on this machine via an install script.

## Language

**Element**:
A single installable unit — a skill, an agent, or an MCP server. The atomic thing a user selects in the installer.
_Avoid_: item, entry, module, plugin

**Target**:
An AI tool the installer supports (Claude Code, Cursor, Pi, and potentially others later). Each target has its own install locations for skills/agents and its own MCP config file/mechanism. Targets also differ in which element kinds they support, so install is capability-gated per target (see **Skills-only target**).
_Avoid_: tool, client, platform

**Skills-only target**:
A target that supports installing skills but not agents or MCP servers. Pi is one: it intentionally has no sub-agents or built-in MCP, so the installer symlinks skills into `~/.pi/agent/skills/` (preserving the category path) and skips agents/MCP for it. The `target_supports` helper in `install.sh` encodes which kinds each target accepts.

**Category**:
A folder level above an element in the repo's directory tree (e.g. `Engineering`, `Productivity`), used purely to organize and group elements in the installer's picker. Categories have no content of their own — only elements (leaf folders containing a `SKILL.md`/`AGENT.md`/`mcp.json`) do. Nesting depth is arbitrary.
_Avoid_: group, folder (when referring to the organizational concept, not the filesystem mechanism)

**Install** (skills/agents):
Creating a symlink from a target's directory (e.g. `~/.claude/skills/...`) to the element's folder in this repo. The symlink _source_ always keeps the full category path (`skills/<Category>/<name>`). The _destination_ path depends on the target: Cursor and Pi preserve the category path (`.../skills/<Category>/<name>`), but Claude Code flattens skills to a single level (`~/.claude/skills/<name>`) because Claude Code only discovers skills one directory deep under `~/.claude/skills/` — a category subfolder would hide them. Flattening is keyed off the target name in `install.sh`'s skills loop and applied via the `flatten` argument to `install_symlink`; agents are never flattened. Leaf names must stay unique across categories so flattening cannot collide (they are today).

**Install** (MCP servers):
Merging the element's canonical JSON definition into a target's MCP config (`claude mcp add-json` at user scope for Claude Code; a `jq`-driven merge into `~/.cursor/mcp.json` for Cursor). Never symlinked — an MCP server is a JSON entry inside a shared config file, not a standalone file/folder, so symlinking doesn't apply.

**Canonical MCP definition**:
The single JSON shape stored per server in this repo (`mcp/<name>/mcp.json`), using Claude Code's schema (`type: "http"` + `url`, or `type: "stdio"` + `command`/`args`/`env`). Cursor uses the identical shape, so no translation is needed when merging into either target.

**skills-v2**:
A separate, in-progress rework of some skills, unrelated to the installer. Excluded entirely from selection — not read, not listed, not installed.

**Workflow skill**:
A skill that orchestrates other skills and agents across several steps, handing artifacts between them (e.g. `ship-issue`). The skill itself does little work directly; it sequences specialists.
_Avoid_: pipeline, team

**Orchestrator**:
The main agent running a workflow skill. It is the only participant that talks to the user, holds the evals, touches git, and opens the PR. Every other participant is a subagent it spawns.

**Eval**:
A check written from a GitHub issue before implementation starts: a scenario checklist (Given/When/Then plus an exact way to verify each one) together with executable acceptance tests. Evals are **hold-out**: the implementer never sees them while working. They are only run by the verifier, and are committed to the test suite once the change passes.
_Avoid_: spec, test plan

**Fix round**:
One pass in which the implementer fixes the reported failures, followed by a fresh verify-and-review pass. A workflow allows a fixed number of them (three in `ship-issue`) before handing control back to the user.

**Blocking finding**:
A review finding with severity `blocker` or `major`. It fails a round. A `minor` finding never blocks; it is carried into the PR as a follow-up.

**Manual validation step**:
A check of deployed behavior, written into a PR's `Manual validation` section and run against the **Shared dev environment** after a deploy. Unlike an **Eval**, it isn't hold-out and doesn't run locally. An agent runs it when it can; a human confirms it when it can't be automated.
_Avoid_: smoke test, QA step

**Shared dev environment**:
The single non-production environment that `make deploy` targets. Deploying a PR there overwrites whatever was deployed before.
_Avoid_: staging, sandbox
