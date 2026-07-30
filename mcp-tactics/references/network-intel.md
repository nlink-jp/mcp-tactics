# Network intel — IP, domain, DNS, MAC

Eight servers answering "what is this address / name?". Four are offline, four
query a third party. Call each server's `get_usage` before first use; this file
covers selection, ordering, and pitfalls only.

## Which question goes to which server

| Question | Server | Tier |
|---|---|---|
| Which AS and country owns this IP? What prefixes does AS N announce? | `asn-lookup` | offline |
| Is this IP a Tor exit node? | `tor-exit-lookup` | offline |
| Is this IP an iCloud Private Relay egress? | `icloud-relay-lookup` | offline |
| Who manufactured this NIC / access point? | `mac-lookup` | offline |
| Who registered this domain / IP range / ASN, and when? | `whois-lookup` | third party |
| Where does this domain resolve right now? | `doh-lookup` | third party |
| What else is hosted on this IP? What subdomains does this domain have, and who CNAMEs to it? | `rdns-lookup` | third party |
| Has this IP been reported for abuse? | `abuse-lookup` | third party, **metered** |

## Ordering for an unknown IP

1. **`asn-lookup`** — `db_status`, then `lookup_ip`. AS, org, and country in one
   offline call. This is context for everything that follows: a hosting AS, a
   consumer ISP, and a cloud provider imply completely different follow-ups.
2. **`tor-exit-lookup`** + **`icloud-relay-lookup`** — both offline, both
   cheap, and both change the meaning of everything downstream. An anonymizing
   egress means the IP identifies a *network*, not an actor; abuse reports
   against it say little about the specific traffic you are looking at.
3. **`rdns-lookup`** — `lookup_rdns` for every domain the free ip.thc.org
   index associates with the address. This reads a third-party index, so no
   packet reaches the target — and it is *not* PTR: it aggregates PTR names,
   A-record matches, and CT-log names, which is why `1.1.1.1` yields tens of
   thousands of records where a PTR yields one. Read `truncated` and
   `matching_records` before calling a set complete.
4. **`whois-lookup`** — the allocation record: assignee, country, abuse contact.
   This is where the address to report to comes from.
5. **`abuse-lookup`** — last, because it is the only metered step. `check_ip`
   for the score and category summary; `get_reports` only when the individual
   reports matter (large pages are written to a file in the workspace you pass).

Skipping straight to step 5 is the common mistake: the score is meaningless
without knowing whether step 2 already explained the address.

## Ordering for an unknown domain

1. **`whois-lookup`** — registrar, creation date, nameservers. Registration age
   is the single most informative field for a suspicious domain.
2. **`doh-lookup`** — the current records over DoH. Every result states which
   resolver and endpoint answered and the DNSSEC AD flag; keep that in the
   writeup, because "Cloudflare said so at time T" is the actual finding.
3. **`rdns-lookup`** — `lookup_subdomains` for the domain's surrounding
   names, `lookup_cnames` for who points at it. Both read the index only;
   the freshness signal is each record's last-seen date, not "resolves now"
   (that is `doh-lookup`'s job).
4. **`asn-lookup`** on each resolved IP — where it is actually hosted, offline.

`whois-lookup` is RDAP-first with a port-43 fallback for RDAP-less ccTLDs
(`.jp` among them), so a JP domain works without special handling. Punycode is
handled in-house — pass the IDN as-is.

## MAC addresses: read the class before the vendor

`mac-lookup` classifies the address *first* and only then looks for a vendor.

**Always read `vendor_lookup_applicable` before `vendor`.** When it is false,
the address is broadcast, multicast, or locally administered — a randomized
MAC (modern phones do this by default on Wi-Fi), a virtual NIC, or a container
interface. There is no manufacturer to find, and reporting "unknown vendor"
misrepresents it. The correct finding is "this is a randomized/locally
administered address", which is itself evidence.

`search_vendor` goes the other way: vendor name → registry entries. Useful for
"which OUIs does this manufacturer hold?" during hardware inventory work.

## Setup, and what a stale cache looks like

The four offline servers answer from a local cache that must exist first:

| Server | Populate with | Credential |
|---|---|---|
| `asn-lookup` | `update_db` | `IPINFO_TOKEN` (free signup) — **only** for the update |
| `mac-lookup` | `update_db` | none |
| `tor-exit-lookup` | `update_list` | none |
| `icloud-relay-lookup` | `update_list` | none |

Check first (`db_status` / `list_status` / `cache_status`), populate if empty,
then query. A Tor exit list or Private Relay list from weeks ago produces
confident false negatives — when the answer will drive a decision and the cache
is old, refresh it.

`abuse-lookup` and `urlscan-lookup` are the only servers here that need a
credential to *query*. `whois-lookup`, `doh-lookup`, and `rdns-lookup` need
none — but `rdns-lookup` rides a free index that asks not to be abused, so its
default 100-record limit, `--all` ceiling, and local cache are courtesy, not
obstacles.

## Quota discipline

`abuse-lookup`'s free tier is **1000 checks/day**, and the daily quota does not
recover until reset — a 429 means stop, not retry. Results are cached with a
TTL, so asking the same question twice costs nothing; only force a refresh when
you specifically need a fresher answer than the cache holds. `cache_status`
reports cache health without spending quota.

## Reporting

State the tier you used for each fact. "Offline, from the IPinfo Lite database"
and "AbuseIPDB, checked today" have different shelf lives and different
confidence, and a reader who cannot tell them apart cannot re-verify the
finding.
