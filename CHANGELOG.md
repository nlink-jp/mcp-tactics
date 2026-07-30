# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-07-31

### Added

- Initial release as a standalone repository, split out of
  [skills-series](https://github.com/nlink-jp/skills-series) per
  [ADR-004](https://github.com/nlink-jp/.github/blob/main/adr/004-skills-series-umbrella.md).
  The skill itself is unchanged from skills-series v0.3.1 (17 MCP servers,
  2 proxies, 7 reference playbooks); earlier history lives in that repository.
- `make package` — builds `dist/mcp-tactics-vX.Y.Z.zip` with the skill folder
  at the zip root, ready to attach to a GitHub Release, unzip into
  `~/.claude/skills/`, or upload to claude.ai (Settings → Skills).
