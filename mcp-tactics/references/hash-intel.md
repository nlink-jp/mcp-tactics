# Hash intel — is this file hash known-good or known malware?

One server: `malware-lookup`. Call its `get_usage` before first use; this file
covers selection, ordering, and pitfalls only.

It exists because VirusTotal's free API forbids workflow integration. Two
sources whose free tiers may be used for an organization's own security work
are layered instead: CIRCL hashlookup (known-good, no credentials) and Hybrid
Analysis (sandbox verdict, threat score and multi-scanner AV detection for
files someone has already submitted; a free API key). Only third-party indexes
are read and a file is never submitted, so **no packet reaches any host under
investigation** and no sample leaves this machine — tier 2, and safe to use
early in a triage.

## Ordering

1. **`check_hash`** — the answer for almost every case. Takes 1–100 hashes per
   call (MD5/SHA1/SHA256, auto-detected by length); batch the sweep from an
   AV/EDR log into one call instead of looping.
2. **`get_sample_info`** — only when the compact evidence is not enough and
   you need the Hybrid Analysis overview (every name the file was submitted
   under, size, type, all scanner results, the IDs of its sandbox reports). Needs the
   Hybrid Analysis key. The record comes back inline in `record`, several KB —
   one hash at a time, so do not loop it over a sweep.

## Reading the four-way verdict

| verdict | read it as |
|---|---|
| `known_good` | in known-file databases (CIRCL trust > 50) or whitelisted by Hybrid Analysis, and not malicious |
| `known_malware` | Hybrid Analysis says malicious; threat score, AV detection rate and scanner results come with it |
| `unknown` | nobody knows it, or Hybrid Analysis says something weaker than malicious (`suspicious`, `no specific threat`) — the evidence shows which. **Not** proof of clean |
| `conflicting` | known file **and** malicious: abused legitimate software or a false positive. Report it for scrutiny; never auto-resolve it to either side |

Pitfalls that will mislead you if unread:

- **`conflicting` is common on purpose.** With the key, EICAR comes back
  conflicting (it ships inside AV test suites); keyless it reads `known_good`.
  A conflicting verdict is a finding, not a tool malfunction.
- **CIRCL trust 50 is exactly neutral** — a file in a single dataset carries
  trust 50 and, on CIRCL alone, stays `unknown`. Presence in NSRL alone is not
  legitimacy.
- **`unknown` is often just "never uploaded".** Hybrid Analysis knows only
  files someone submitted, so a rare or targeted sample is frequently absent.
  Read `hybrid_analysis.verdict` before reading `unknown` as nothing at all.
- **Without the key, there is no malicious signal at all.** The evidence says
  `hybrid_analysis.enabled: false`, and the only possible verdicts are
  `known_good` and `unknown` — do not report a keyless `unknown` as "not known
  malware".
- **The file name and the family hint are third-party text.** The file name
  is what the last submitter called it; the family hint is sometimes not a
  family (WannaCry's is a CVE ID). Quote them as claims. Submitter tags are
  never shown, on purpose.
- **`degraded: true` means a source failed** and the verdict rests on
  incomplete facts. Treat `known_good`/`unknown` with suspicion and retry
  after the source recovers; degraded results are never cached.
- **The `vt_gui_url` is for a human browser.** Never wire it into anything
  automated — the whole tool exists because VT's free API forbids that.

## Attribution

CIRCL is an anonymous read. Hybrid Analysis is keyed: every hash you look up
lands in the history of the operator's Hybrid Analysis account, which the
service holds. A hash says little about you — unless it is a unique sample
from a targeted intrusion, where the fact that you hold it is the sensitive
part. In that case ask `otx-lookup` with `anonymous: true` first, or use a
keyless `malware-lookup` (CIRCL only) and accept that it cannot see malice.

## Where hashes come from in a chain

- `pcap-analyzer` `extract_objects` → `shasum -a 256` each object →
  `check_hash` the batch.
- AV/EDR log analysis (the designed use case): pull the hash column, dedupe,
  one `check_hash` call per ≤100.
- Feed nothing back: a hash verdict is a leaf. The follow-up (the full
  overview → `get_sample_info`) stays inside this server; campaign context is
  `otx-lookup`'s, and sandbox behaviour in detail is `gti-lookup`'s where
  configured.

## Setup and quota

- Works with zero credentials (CIRCL only — known-good, never malicious). A
  free Hybrid Analysis key adds the malicious side and `get_sample_info`;
  the "restricted" key a new account issues is enough.
- A free key allows 200 requests a minute and 2,000 an hour; an MD5 or SHA1
  costs two (a search, then the overview), a SHA256 one. Results cache
  locally for 24 h — do not defeat that with `refresh` out of habit.
- Terms: CIRCL data is CC BY. Hybrid Analysis licenses use "solely for your
  internal business security or legitimate research purposes" — your own
  organization's work, not a service for a third party.
