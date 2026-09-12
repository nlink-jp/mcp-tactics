# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.8.0] - 2026-09-12

### Added

- `brave-search` — the fleet's 25th server and its first web-search one.
  Tier 2 (a keyed third-party index read) for `web_search` / `llm_context`;
  the two Answers tools are flagged as possibly fetching pages, so a URL
  under investigation never goes to them. New decision-table row "a
  question about the world", a standing caution on metering and the Brave
  ToS, and `references/web-search.md` with the tool order and pitfalls
  (citations unreliable for non-English replies; `research` cannot be
  cancelled). The trigger (`description`) gains web search / Web検索 with
  every earlier trigger kept, and stays under 1,024 characters by tightening
  its prose.

## [0.7.2] - 2026-09-06

### Fixed

- `description` trimmed to 1,017 characters: claude.ai and the desktop app
  refuse a SKILL.md whose description exceeds 1,024 characters, and v0.7.1
  had grown to 1,085. Every trigger is kept, including the generic
  BigQuery one; only wording was tightened. The vendored validator does
  not check this limit yet.

## [0.7.1] - 2026-09-06

### Fixed

- The skill's trigger (`description`) now names BigQuery: querying,
  exploring or analysing your own data warehouse — any dataset, not only
  audit exports — plus the Japanese terms BigQuery・データウェアハウス・DWH・
  テーブル探索・SQL集計. v0.7.0 added the `bigquery-mcp` routes to the body
  but not to the line clients use to decide whether to load the skill, so
  a plain question about a BigQuery table never reached them.

## [0.7.0] - 2026-09-06

### Added

- **`bigquery-mcp`** — what your own BigQuery data warehouse holds
  (tier 1: only your own project sees the job). Listed in the tier-1 row,
  the investigation-layer index, and a new decision-table row for
  "a question about your own data warehouse"; the IP row's "your own
  telemetry first" now names it beside `splunk-mcp`. The server dry-runs
  every query and refuses non-SELECT, out-of-allowlist and over-budget
  queries — the row tells the agent to read the verdict rather than
  suspect its own call or runtime.

### Changed

- Ordering endpoints re-derived: `bigquery-mcp` has no target-contact
  capability, so the four-tier doctrine and its endpoints are unchanged.
- Fleet count in README and AGENTS.md re-counted from the server index.

## [0.6.0] - 2026-09-01

### Added

- **`gti-lookup`** — Google Threat Intelligence context (tier 2): an
  indicator's associated collections, sandbox behaviour served index-first,
  GTI-syntax IOC corpus search, the vulnerability catalogue with ATT&CK
  trees, and read-only LiveHunt ruleset inspection. New reference
  `references/gti-intel.md`; a new decision row for CVEs; the file-hash row
  gains the association/behaviour follow-up.
- **A conditional-presence rule, stated wherever the server is named**:
  `gti-lookup` requires a commercial GTI licence, so unlicensed environments
  simply do not have it configured — its absence is expected, and every
  route that names it applies only when it is present.

### Changed

- The tier-2 attribution corollary gains its far end: `gti-lookup` queries
  are always recorded against a commercial licence, with no anonymous mode —
  exhaust the anonymous reads first when attribution matters.
- Fleet count corrected to 23 servers (the v0.5.0 gem-scribe addition never
  bumped the stated 21).

## [0.5.2] - 2026-08-31

### Changed

- Finished the sync the v0.5.1 follow-up started, after an audit of every
  reference against the servers as released today:
  - **network-intel**: `get_reports` no longer writes large pages to a
    workspace file — the tactic is now `per_page`-sized inline pages walked
    with `page`, fetched once because every page is metered.
  - **url-triage**: `get_screenshot` returns the PNG as inline image content
    when it fits, so the tactic is to look at the image, not reason about a
    path.
  - **media**: the file-mediation claim now carries its real exception (short
    transcripts come back inline — the intro used to contradict the
    voice-scribe section) and the read-back rule: pass a `workspace_root` you
    can open, or every result is a path to nothing.
- Confirmed unchanged on the same audit: splunk-mcp's `workspace_root`
  (log-search), rdns's `truncated`/`matching_records` reading, and the
  hash-intel / campaign-context updates from v0.5.1.

## [0.5.1] - 2026-08-31

### Changed

- Followed the lookup servers off file mediation. `get_sample_info` returns the
  MalwareBazaar record inline in `record` and no longer takes a
  `workspace_root`; `get_pulse` pages a feed dump's indicators with `limit` +
  `page` instead of spilling them to a file.

## [0.5.0] - 2026-08-30

### Added

- **`gem-scribe`** — cloud transcription on Vertex AI's dedicated model, the
  counterpart of `voice-scribe`. Same tool shapes and the same output
  envelope, so switching between them costs nothing; up to 8 speakers against
  voice-scribe's 4, at the price of metering and of the audio leaving the
  machine.
- A fifth corollary to the doctrine. Re-deriving the ranking's endpoints for
  the new server did not move them — it cannot contact a party under
  investigation — but it surfaced an axis the ladder does not measure: **the
  ladder ranks who sees that you asked, not who sees what you have.** A
  recording under investigation handed to a cloud transcription service has
  left your control regardless of tier, so that case is decided before the
  cost trade-off is considered.

### Changed

- The "recording to transcribe" row now presents two servers with no default,
  and states the one case that is not a trade-off: investigation material
  stays local.
- `gem-scribe` also translates and names speakers (`translate_to`,
  `speaker_hints`); `voice-scribe` has no equivalent, so that is a second
  reason to reach for the cloud one on a meeting.
- `gem-transcribe` is archived. It was the envelope `voice-scribe` was
  described as compatible with, so those references now name `gem-scribe`.

## [0.4.0] - 2026-08-28

Catches the skill up with the fleet as of late August: the twenty-first
server, a proxy succession, and a stale skill pointer.

### Added

- **`voice-scribe`** — local transcription (whisper.cpp): a recording in, a
  transcript out, with optional speaker labels, and no audio leaving the
  machine. It had actually shipped two days before v0.3.0 counted "the
  twentieth server", so the count was already one short when it was written.
  The ranking's endpoints were re-derived and did not move — the server cannot
  contact a party under investigation, so it joins the production layer, not
  the tier ladder. It ships `get_usage`, so the three-server exception list is
  unchanged. New decision-table row for recordings, and a playbook section in
  `references/media.md`.

### Changed

- **`mcp-guardian` → `mcp-bridge` in the proxy table.** The governance proxy
  was archived on 2026-08-23, its governance layer never having entered
  service; the bridge role it actually performed continues as `mcp-bridge`
  (stdio ⇄ Streamable HTTP for servers demanding a pre-registered OAuth
  client). The standing instruction "a masked tool is masked deliberately"
  is retired with it: the bridge masks nothing, so a missing tool now means
  the upstream does not offer it, and an authentication failure is the
  operator's to fix rather than a call to retry.

### Fixed

- The voicing row pointed to the `radio-drama` skill, which was merged into
  `multi-actor-narration` and deleted upstream — the pointer now names only
  the surviving skill.

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
