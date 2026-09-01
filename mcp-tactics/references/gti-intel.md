# GTI intel — what does Google's index say about this indicator?

One server: `gti-lookup`. Call its `get_usage` before first use; this file
covers selection, ordering, and pitfalls only.

It reads Google Threat Intelligence with a **commercial licence key**: the
community collections an indicator is associated with, sandbox behaviour of a
sample, corpus-wide IOC search in GTI query syntax, the vulnerability
catalogue with relationship pivots and ATT&CK trees, and the account's own
LiveHunt rulesets. Only Google's index is read, so **no packet reaches the
target under investigation** — tier 2.

## The server may simply not be there

`gti-lookup` is the one member of the lookup family that requires a paid
licence, so **an environment without one will not have this server
configured at all**. Its absence is expected, not a fault: use it when it
appears in your tool list, plan without it when it does not, and never treat
a missing `gti-lookup` as a broken setup. The free-source siblings
(`malware-lookup`, `otx-lookup`, `urlscan-lookup`, ...) answer their rows of
the decision table with no licence.

## Attribution is total

Every query is recorded against the licence holder's commercial account.
There is no anonymous mode and no per-call opt-out — this is the far end of
tier 2's attribution axis (contrast `otx-lookup`, where `anonymous: true`
declines to identify you). When the fact that you asked is itself sensitive,
prefer the anonymous-read siblings first.

## Ordering

- **After the free siblings, not instead of them.** `malware-lookup` still
  answers "what is this hash" from three free sources; `gti-lookup`
  `lookup_ioc` adds whose collections it appears in, and `get_file_behaviour`
  what it did in a sandbox — questions no free sibling answers.
- **`lookup_ioc` is deliberately trimmed** to the association context; the
  overlapping questions (per-engine verdicts, passive DNS, reputation, URL
  behaviour) belong to `malware-lookup`, `rdns-lookup`, `abuse-lookup` and
  `urlscan-lookup`. `full: true` exists for a deliberate second opinion, not
  as the default.
- **`get_file_behaviour` is index-first.** A summary can exceed 2 MB, so the
  first call returns section names with counts; expand one section at a time
  and page with `offset` — never ask for everything.
- **CVEs have a first-class home**: `search_threats` with
  `collection_type: vulnerability`, then `get_threat` /
  `get_threat_mitre_tree` on the `vulnerability--cve-...` id.

## Pitfalls

- **The licence tier decides what answers.** On GTI Standard (what this
  fleet runs), the curated threat-actor / campaign / report catalogue is
  invisible: typed searches for those answer **empty, not an error**, and
  `gti_assessment` is absent. Never read a tier-empty search as "this actor
  does not exist" — the association context in `lookup_ioc` results is where
  actor names actually arrive.
- An indicator with no associations is a normal result. A result with
  `incomplete: true` is not — treat it as unanswered.
- LiveHunt ruleset answers are live (never cached) and read-only; an
  `enabled: false` ruleset will not fire, and the console — not this
  server — is where rules are created or enabled.
