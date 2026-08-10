# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.3.0] - 2026-08-10

Catches the skill up with the fleet's twentieth server, `otx-lookup`.

### Added

- **`otx-lookup`** — campaign context for an indicator, from OTX community
  pulses. Tier 2: it reads a third-party index and touches no target. Added to
  the tier table, the server index, the IP / domain / file-hash rows of the
  decision table, and a new row for the pivot from an indicator to the rest of
  a campaign.
- **[references/campaign-context.md](mcp-tactics/references/campaign-context.md)** —
  the per-domain playbook. Its core is how to read the result honestly:
  `incomplete` before trusting an empty answer, `pulses_held` vs `pulses_shown`
  because held is a lower bound, and `indicators_exact` which means "upstream
  stated a total", not "this list may be short".

### Changed

- **A fourth corollary to the doctrine: attributability inside tier 2.** The
  new server did not move the ranking's endpoints — they are still tier 1 and
  tier 4 — but it made an axis explicit that was always latent. `whois-lookup`,
  `doh-lookup` and `rdns-lookup` are anonymous reads; `abuse-lookup`,
  `urlscan-lookup` and `otx-lookup` carry a key, so the query lands in an
  account history someone else holds. `otx-lookup` is the only server where
  that choice is available per call, which is what makes the distinction worth
  writing down rather than leaving implied.

## [0.2.0] - 2026-08-08

Catches the skill up with the MCP fleet, which grew from 17 servers to 19.
Design: [ADR-018](https://github.com/nlink-jp/.github/blob/main/adr/018-mcp-observability-tiers.md),
amending ADR-003.

### Added

- **`chrome-pilot` and a fourth escalation tier.** `chrome-pilot-mcp` drives
  the Chrome on this machine, so a page it loads is a visit the site's
  operator can attribute to **us** — strictly more exposing than
  `urlscan-lookup scan_url`, which was the doctrine's ceiling. Tier 3 is now
  "target contact, by proxy" and tier 4 is "target contact, from you". The
  server is in the tactics book because the risk follows the capability, not
  because investigation is its purpose; the suspicious-URL chain explicitly
  has no `chrome-pilot` step. New playbook: `references/browser.md`.
- **`splunk-mcp`.** Searching our own Splunk is observed by nobody outside our
  infrastructure, which makes "have we seen this ourselves?" a tier 1 step —
  it now sits at the front of the unknown-IP ordering rather than being
  reached for last. Large results arrive as JSONL for `data-toolbox` to
  analyse. New playbook: `references/log-search.md`.
- `image-forge`'s `upscale` tool in the server index, and the `list_models`
  report of recorded-but-absent weights in `references/media.md`.

### Changed

- **Tier 1 is now "no external observer"**, widened from "answered from a
  local cache" so it admits `pcap-analyzer` (local container, no network) and
  `splunk-mcp` without weakening the promise. `pcap-analyzer`'s tier was
  previously blank.

### Fixed

- **"Every server ships `get_usage`" was false**, and it is a load-bearing
  instruction: `ask-gemini` and `ask-llm` expose one prompt-forwarding tool
  each, and `chrome-pilot` mirrors upstream `chrome-devtools-mcp`'s schemas.
  Stated as universal, it sent an agent looking for a tool that is not there.
  The instruction is now conditional and names all three exceptions.

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
