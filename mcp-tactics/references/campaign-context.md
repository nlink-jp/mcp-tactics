# Campaign context — is this indicator part of a known operation?

One server: `otx-lookup`. Call its `get_usage` before first use; this file
covers selection, ordering, and pitfalls only.

Every other investigation server answers "one indicator, one attribute" —
attribution, registration, reputation, DNS relationships, what a hash is, how a
URL behaves. This one answers a different question: **has anyone reported this
indicator as part of a campaign, and if so, whose?** It reads the community
reports ("pulses") of the LevelBlue Open Threat Exchange, so only a third-party
index is touched — tier 2, and safe early in a triage.

It duplicates no sibling **by design**: the sections OTX carries that
`abuse-lookup`, `rdns-lookup`, `malware-lookup` and `urlscan-lookup` each own
(`reputation`, `passive_dns`, `malware`/`analysis`, `url_list`) are off by
default. Ask for them through `sections` only when you deliberately want OTX's
second opinion, and prefer the sibling's answer when the two disagree.

## Ordering

1. **`lookup_indicator`** — the entry point for any indicator type: IPv4, IPv6,
   domain, hostname, URL, MD5/SHA1/SHA256, or CVE. One request in the common
   case. Read `context` for the aggregate — adversaries, malware families,
   ATT&CK techniques, targeted industries and countries, each with the number
   of pulses that named it.
2. **`get_pulse`** with `indicators: true` — the pivot. Take a `pulse_id` from
   step 1 and you have the other indicators reported alongside it. **No API key
   needed**: the pulse detail embeds them.
3. **`search_pulses`** — only when you have a campaign *name* rather than an
   indicator. Requires an API key.

## Reading the result honestly

The three fields that decide whether an answer means anything:

| Field | Read it as |
|---|---|
| `incomplete` | **Check this before trusting any empty result.** True means a lookup failed, so `pulses_held: 0` is "we could not ask", not "nobody reported this" |
| `pulses_held` vs `pulses_shown` | `held` is a **lower bound** — OTX returns exactly 50 for heavily-reported indicators, which is a page size, not a total. `capped: true` marks it |
| `indicators_exact` | False means upstream stated no total. It does **not** mean the list is short — the detail returns the complete set; only a key confirms the number |

Pitfalls that will mislead you if unread:

- **`otx-lookup` reports claims, never verdicts.** Pulses are community
  submissions of wildly varying quality — some are curated campaign reports,
  some are automated blocklists with hundreds of thousands of indicators and
  scraped junk tags. The author, vote counts, `validation` and
  `false_positive_reports` come back so you can weigh them. A pulse hit is not
  a malicious verdict, and a well-known legitimate domain will carry dozens.
- **A name is asked as both `domain` and `hostname`.** OTX indexes each name
  under exactly one of the two and answers 200 either way, so the wrong guess
  returns zero pulses and looks like a clean indicator. The server tries both
  and reports which answered in `type` / `tried_types` — do not "optimise" that
  away by pinning a type yourself.
- **The pulse count is not a severity score.** A pulse carrying 300,000
  indicators is a feed dump; a pulse carrying twelve is someone's analysis.
  `indicator_count` on each pulse tells you which you are looking at.
- **Pivoting is two steps on purpose.** There is no "give me everything
  related" call, because which pulse to trust is your judgement — automatic
  aggregation would silently mix a curated report with a scraped blocklist.

## Where it sits in a chain

- **IP or domain**: run it alongside the standard ladder, not inside it. The
  ladder establishes *what the indicator is*; this establishes *whether anyone
  has seen it before, and as part of what*.
- **File hash**: after `malware-lookup`. That server says what the file is;
  this says whose operation it belongs to.
- **Out of a pulse**: the indicators from `get_pulse` are ordinary indicators —
  send them back through the IP, domain and hash rows of the decision table.
  This is the one server that *widens* an investigation rather than narrowing
  it, so decide how far you mean to follow it before you start.

## Setup and quota

- Works with zero credentials for everything except `search_pulses`. A free
  key adds search, an exact indicator total, and lifts the ceiling from 1,000
  to 10,000 requests/hour.
- **A keyed query is recorded against that OTX account.** Pass
  `anonymous: true` when the fact that you asked is itself sensitive — this is
  the only server in the fleet where that choice is available per call.
- OTX returns no rate-budget header, so the ceiling is counted locally; it also
  returns 429s and 504s under load. Results cache for 24 h — do not defeat that
  with `refresh` out of habit.
- **Non-commercial use only.** OTX is free to end users for non-commercial use.
