# mcp-tactics

A Claude Code Skill: the cross-cutting tactics book for
[nlink-jp](https://github.com/nlink-jp)'s 19 MCP servers and 2 proxies
([ADR-003](https://github.com/nlink-jp/.github/blob/main/adr/003-mcp-tactics-skill.md),
amended by
[ADR-018](https://github.com/nlink-jp/.github/blob/main/adr/018-mcp-observability-tiers.md)).
`SKILL.md` is a router of decision tables — input artifact → route,
cross-server chains, and a four-tier escalation doctrine ranked by who can see
that you asked, from no external observer up to contact from your own IP —
with per-domain playbooks under `references/`. It records selection and
ordering only; each server's own `get_usage` tool stays authoritative for
parameters and error recovery.

## Installation

### From a release zip (recommended)

Download `mcp-tactics-vX.Y.Z.zip` from
[Releases](https://github.com/nlink-jp/mcp-tactics/releases) and unzip it
into your skills directory:

```bash
unzip mcp-tactics-vX.Y.Z.zip -d ~/.claude/skills/
```

Use `.claude/skills/` inside a project instead for project-scoped installs.

On claude.ai, Claude Desktop, or mobile: upload the zip as-is under
**Settings → Skills**.

### From source

```bash
git clone https://github.com/nlink-jp/mcp-tactics.git
cd mcp-tactics
make install
```

`make install DEST=/path/to/project/.claude/skills` installs to a specific
project. `make uninstall` removes the installed copy.

## Usage

This is a reference skill: Claude loads it on its own when a task involves
one of the organization's MCP servers, and `/mcp-tactics` shows it on demand.

## Development

```bash
make check     # structural validation (frontmatter, relative links)
make package   # build dist/mcp-tactics-vX.Y.Z.zip (zip root = skill folder)
```

The skill content lives in [`mcp-tactics/`](mcp-tactics/) — that directory
is exactly what `make package` ships and `make install` copies. Repository
scaffolding (README, Makefile, tests) never enters the artifact.

When a server is added, removed, or gains a tool, update the decision tables
and the relevant playbook; when a tool's arguments change, do nothing —
parameters belong to `get_usage` (ADR-003).

## History

Before v0.1.0 this skill lived in
[skills-series](https://github.com/nlink-jp/skills-series); the split is
recorded in
[ADR-004](https://github.com/nlink-jp/.github/blob/main/adr/004-skills-series-umbrella.md).

## Documentation

- [English](README.md)
- [Japanese](README.ja.md)

## License

[MIT](LICENSE)
