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
Creating a symlink from a target's directory (e.g. `~/.claude/skills/...`) to the element's folder in this repo, preserving the category path exactly.

**Install** (MCP servers):
Merging the element's canonical JSON definition into a target's MCP config (`claude mcp add-json` at user scope for Claude Code; a `jq`-driven merge into `~/.cursor/mcp.json` for Cursor). Never symlinked — an MCP server is a JSON entry inside a shared config file, not a standalone file/folder, so symlinking doesn't apply.

**Canonical MCP definition**:
The single JSON shape stored per server in this repo (`mcp/<name>/mcp.json`), using Claude Code's schema (`type: "http"` + `url`, or `type: "stdio"` + `command`/`args`/`env`). Cursor uses the identical shape, so no translation is needed when merging into either target.

**skills-v2**:
A separate, in-progress rework of some skills, unrelated to the installer. Excluded entirely from selection — not read, not listed, not installed.
