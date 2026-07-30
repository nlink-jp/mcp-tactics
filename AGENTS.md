# AGENTS.md — mcp-tactics

## Project summary

Claude Code Skill: cross-cutting selection layer for nlink-jp's MCP servers
(ADR-003). Decision tables route an input artifact (IP, domain, URL, hash,
MAC, pcap, data file, …) to the right server in the right order, under an
offline-before-third-party-before-target-contact escalation doctrine.
Per-domain playbooks live under `mcp-tactics/references/`.

## Key commands

| Command | Purpose |
|---------|---------|
| `make install` | Copy the skill to `~/.claude/skills/mcp-tactics` |
| `make install DEST=<path>` | Copy to a custom skills directory |
| `make uninstall` | Remove the installed copy |
| `make check` (= `make test`) | Structural validation (frontmatter, relative links) |
| `make package` | Build `dist/mcp-tactics-vX.Y.Z.zip` (zip root = skill folder) |
| `make clean` | Remove `dist/` |

## Directory structure

```
mcp-tactics/
├── mcp-tactics/           The skill — the only thing that ships
│   ├── SKILL.md           Router: decision tables, chains, escalation doctrine
│   └── references/        Per-domain playbooks, read on demand
├── tests/
│   └── validate-skill.sh
├── Makefile
├── README.md / README.ja.md
├── CHANGELOG.md
├── CLAUDE.md / AGENTS.md
└── LICENSE
```

## Gotchas

- **Selection and ordering only** — parameters, return shapes, and error
  codes belong to each MCP server's own `get_usage` tool; duplicating them
  here guarantees drift (ADR-003). When a server gains or loses a *tool*,
  update the index; when a tool's arguments change, do nothing.
- The skill is Markdown — no build, no behaviour tests. Structure *is*
  tested: `make check` verifies frontmatter and relative links.
- The `mcp-tactics/` subdirectory is the distribution boundary (ADR-004):
  `make package` zips exactly that directory, so the zip root is the skill
  folder — the layout claude.ai accepts. Never add repo-level files inside
  it, and never bundle README.md into the zip.
- The directory name is the slash command; frontmatter `name` must match it.
- After editing skill files, run `make install` to refresh the deployed copy.
- Releases follow the org checklist with `make package` in place of a binary
  build; before uploading, unzip the artifact and confirm
  `mcp-tactics/SKILL.md` sits directly under the zip root.

## Module path

Repository: `github.com/nlink-jp/mcp-tactics`
