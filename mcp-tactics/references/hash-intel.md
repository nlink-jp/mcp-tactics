# Hash intel — is this file hash known-good or known malware?

One server: `malware-lookup`. Call its `get_usage` before first use; this file
covers selection, ordering, and pitfalls only.

It exists because VirusTotal's free API forbids workflow integration: three
free sources that explicitly permit non-commercial use are layered instead —
CIRCL hashlookup (known-good), Team Cymru MHR (malicious + detection rate,
queried over DoH), MalwareBazaar (family/tags). Only third-party indexes are
read, so **no packet reaches any host under investigation** — tier 2, and safe
to use early in a triage.

## Ordering

1. **`check_hash`** — the answer for almost every case. Takes 1–100 hashes per
   call (MD5/SHA1/SHA256, auto-detected by length); batch the sweep from an
   AV/EDR log into one call instead of looping.
2. **`get_sample_info`** — only when the compact evidence is not enough and
   you need the full MalwareBazaar record (vendor intel, code-signing
   certificates, fuzzy hashes). Needs an abuse.ch Auth-Key and a
   `workspace_root`; the record arrives as a file, not inline.

## Reading the four-way verdict

| verdict | read it as |
|---|---|
| `known_good` | in known-file databases (CIRCL trust > 50), not flagged |
| `known_malware` | flagged by 30+ AV aggregate; family/tags attached when MalwareBazaar knows it |
| `unknown` | nobody knows it — **not** proof of clean |
| `conflicting` | known file **and** flagged: abused legitimate software or a false positive. Report it for scrutiny; never auto-resolve it to either side |

Pitfalls that will mislead you if unread:

- **`conflicting` is common on purpose.** EICAR comes back conflicting (it
  ships inside AV test suites), and even the empty file's hash is in MHR.
  A conflicting verdict is a finding, not a tool malfunction.
- **CIRCL trust 50 is exactly neutral** — a file in a single dataset carries
  trust 50 and stays `unknown`. Presence in NSRL alone is not legitimacy.
- **`unknown` may still be in MalwareBazaar.** Enrichment runs only on an MHR
  hit (fair-use courtesy), so a Bazaar-only sample reads `unknown`.
- **`degraded: true` means a source failed** and the verdict rests on
  incomplete facts. Treat `known_good`/`unknown` with suspicion and retry
  after the source recovers; degraded results are never cached.
- **The `vt_gui_url` is for a human browser.** Never wire it into anything
  automated — the whole tool exists because VT's free API forbids that.

## Where hashes come from in a chain

- `pcap-analyzer` `extract_objects` → `shasum -a 256` each object →
  `check_hash` the batch.
- AV/EDR log analysis (the designed use case): pull the hash column, dedupe,
  one `check_hash` call per ≤100.
- Feed nothing back: a hash verdict is a leaf. The follow-ups (family name →
  reporting, sample detail → `get_sample_info`) stay inside this server.

## Setup and quota

- Works with zero credentials (CIRCL + MHR). An abuse.ch Auth-Key (free
  registration) adds family/tag enrichment and `get_sample_info`.
- Nothing is metered, but all three upstreams are free services with
  unpublished limits: results cache locally for 24 h — do not defeat that
  with `refresh` out of habit.
- Non-commercial use only without contracts: commercial use of abuse.ch data
  requires Spamhaus, and Team Cymru MHR is free for non-commercial use.
