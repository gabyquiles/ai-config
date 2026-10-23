# ai-config

A personal repository of Claude Code **skills**, **agents**, and **MCP server definitions**, installable into AI coding tools on your machine via an automated install script.

## Overview

This repository provides reusable AI tool extensions for:
- **Claude Code**
- **Cursor**
- **Pi** (skills-only target)

All elements are managed and installed via a single, interactive install script that handles symlinks (for skills/agents) and config merges (for MCP servers).

## Project Structure

```
ai-config/
├── skills/                    # Reusable skill packs organized by category
│   ├── Engineering/          # Software engineering, architecture, and design skills
│   ├── Research/             # Research and discovery-focused skills
│   └── Tools/                # Tool integration skills
├── agents/                    # Specialized AI agent configurations
│   ├── aws-solutioner/
│   ├── qa-engineer/
│   └── senior-developer/
├── mcp/                       # MCP server definitions
├── docs/                      # Additional documentation
├── install.sh                 # Main installation script
├── CONTEXT.md                 # Terminology and conceptual guide
└── Makefile                   # Build and utility commands
```

## What's Included

### Skills

Located in `skills/`, organized by category:

#### Engineering
- **software-architect** — Design new software architecture with C4 diagrams and arc42 documentation
- **design-patterns** — Guidance on Gang of Four and event-driven architecture patterns
- **implement** — TDD-based implementation workflow with red-green-refactor loop
- **improve-codebase-architecture** — Identify architectural refactoring opportunities
- **to-prd** — Convert plans into Product Requirements Documents
- **to-issues** — Break down specs into GitHub issues
- **grill-with-docs** — Stress-test plans against domain models and documentation

#### Research
- **grill-me** — Interview and stress-test design decisions
- **ontology-interview** — Build domain ontologies and knowledge maps

#### Tools
- **gh-github** — GitHub CLI integration for repos, issues, PRs, and Projects v2

### Agents

Specialized agent personas for specific tasks:
- **aws-solutioner** — AWS architecture and solutions
- **qa-engineer** — Quality assurance and testing strategies
- **senior-developer** — Expert code review and architecture guidance

### MCP Servers

Model Context Protocol servers for extending tool capabilities (defined in `mcp/`).

## Installation

### Quick Start

```bash
./install.sh
```

The script will:
1. **Detect** which tools are installed on your machine (Claude Code, Cursor, Pi)
2. **Display** an interactive picker showing available skills, agents, and MCP servers
3. **Install** selected elements via:
   - **Symlinks** for skills and agents (preserving category paths)
   - **Config merge** for MCP servers

### Supported Targets

| Target | Skills | Agents | MCP |
|--------|--------|--------|-----|
| Claude Code | ✅ | ✅ | ✅ |
| Cursor | ✅ | ✅ | ✅ |
| Pi | ✅ | ❌ | ❌ |

**Note:** Pi is a skills-only target. Agents and MCP servers are not supported (by design).

## Key Concepts

### Element
A single installable unit—a **skill**, an **agent**, or an **MCP server**. The atomic thing you select in the installer.

### Target
An AI tool supported by the installer (Claude Code, Cursor, Pi). Each target has its own install locations and capabilities.

### Category
A folder level organizing elements (e.g., `Engineering`, `Research`, `Tools`). Used to group related skills in the installer's picker.

### Install Mechanics

**Skills & Agents:** Created as symlinks from the target's directory to the element's folder in this repo, preserving category paths.

**MCP Servers:** Merged as JSON entries into the target's MCP config file (`~/.claude/config.json`, `~/.cursor/mcp.json`, etc.).

## Usage

Once installed, skills and agents are available in:
- **Claude Code** — `/Applications/Claude.app` or command line via `claude`
- **Cursor** — Built into the Cursor editor
- **Pi** — `~/.pi/agent/skills/`

Select them from the respective tool's UI or invoke them via commands/shortcuts.

## Documentation

- **CONTEXT.md** — Detailed terminology, conceptual model, and design decisions
- **docs/** — Additional guides and specifications
- Each skill/agent includes its own `SKILL.md` or `AGENT.md` with usage details

## Development

### Adding a New Skill

1. Create a folder: `skills/<Category>/<skill-name>/`
2. Add a `SKILL.md` file with:
   - Description
   - When to use it
   - How to invoke it
   - Example usage

3. Run `./install.sh` and select your new skill

### Adding a New Agent

1. Create a folder: `agents/<agent-name>/`
2. Add an `AGENT.md` file describing the agent's purpose and behavior
3. Add supporting files (prompts, instructions, etc.)
4. Run `./install.sh` to install

### Adding MCP Servers

1. Create a folder: `mcp/<server-name>/`
2. Add `mcp.json` with the server definition
3. Run `./install.sh` to merge the config

## Troubleshooting

### Installation Issues

- **Target not found:** Ensure you have Claude Code (`~/.claude`), Cursor (`~/.cursor`), or Pi (`~/.pi/agent`) installed
- **Permission denied:** The installer requires write access to target directories

### Symlink Issues

- Verify symlinks with: `ls -la ~/.claude/skills/` or `ls -la ~/.pi/agent/skills/`
- Symlinks should point to folders in this repo, e.g., `ai-config/skills/Engineering/...`

## Contributing

To add or modify elements:
1. Create or edit the element folder
2. Update or create `SKILL.md`, `AGENT.md`, or `mcp.json`
3. Test with `./install.sh`
4. Commit and push

## License

[Your license here]

## Author

Gaby Quiles

---

**Questions?** See `CONTEXT.md` for terminology and design decisions, or check individual element documentation.
