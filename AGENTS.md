# AGENTS.md — mcp-tactics

## Project summary

Claude Code Skill: cross-cutting selection layer for nlink-jp's 19 MCP servers
and 2 proxies (ADR-003, amended by ADR-018). Decision tables route an input
artifact (IP, domain, URL, hash, MAC, pcap, log question, data file, …) to the
right server in the right order, under a four-tier escalation doctrine ranked
by who can observe the query: no external observer → third party → target
contact via urlscan → target contact from our own IP (`chrome-pilot`).
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
- **`get_usage` is not universal** — `ask-gemini`, `ask-llm`, and
  `chrome-pilot` ship none (single-tool servers, and upstream schema
  compatibility respectively). The Skill names them so the absence reads as
  expected; if a fourth appears, add it to that list rather than restating
  its parameters here (ADR-018).
- **A new MCP server is in scope when it *can* contact a party under
  investigation**, not only when investigation is its purpose — that is why a
  browser automation server sits in an OSINT tactics book (ADR-018).
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
