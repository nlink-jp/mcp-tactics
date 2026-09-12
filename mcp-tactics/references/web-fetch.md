# Reading one URL — web-fetch

One server, one tool: `fetch` takes a URL you already have and returns its
body as text. Call `get_usage` first; it carries the arguments, the response
schema and the error-recovery table. No key, no cache on disk.

It is **tier 4**: the page is fetched from this machine's IP address, as a
plain GET with a `User-Agent` that names the tool. Quieter than a browser (no
cookies, no JavaScript, no profile) but still a visit the site can attribute
to you. For a URL **under investigation** this server is never the answer —
see [url-triage.md](url-triage.md).

## When it is the right server

| Situation | Server |
|---|---|
| The user gave a URL and wants what is on it | `web-fetch` |
| A search hit (`brave-search` `web_search`) must be read whole, not as a snippet | `web-fetch` |
| `llm_context` answered with a page other than the one asked for | `web-fetch` — `llm_context` substitutes silently for URLs outside Brave's index |
| A page that needs JavaScript or interaction | `chrome-pilot` — see [browser.md](browser.md) |
| A suspicious URL, or one from a phishing mail, a capture or a log | `urlscan-lookup` — see [url-triage.md](url-triage.md) |
| A PDF or other binary | not this server (`unsupported_content_type`) |

## How to read a page

- `fetch` with the URL. The default returns 6,000 characters of markdown from
  the start; `truncated` with `next_offset` means more remains — call again
  with `offset: next_offset` and concatenate. `total_chars` tells you how many
  turns that is; decide whether the whole page is worth them.
- The same `doc_id` across turns means the same page. A different one means the
  page changed or was refetched: start again at 0.
- `format: text` drops the markup; `format: raw` returns the decoded body as
  is — use it when the extraction missed the content (a page that is mostly
  script, an unusual layout). Plain text and JSON bodies come back raw whatever
  was asked.
- `fresh: true` refetches instead of reusing the page this server process
  cached (ten minutes by default).

## Pitfalls

- **`address_not_allowed` is the guard working, not a fault to route around.**
  The host resolved to a loopback, private, link-local or otherwise reserved
  address; the server will not reach it under any spelling of the same host.
  Do not try the IP literal, an alternate encoding or another tool to get
  there. An operator who wants LAN access sets it in their own configuration.
- **A 403 or 503 is usually a bot challenge**: the page needs a browser. Say
  so rather than retrying.
- **`too_large` is not a truncation**: the page is bigger than the server
  reads; nothing partial comes back. Only an operator can raise the cap.
- **The text is the page's content, extracted** — a heuristic body selection.
  A nearly empty result on a page you know has content means the content is
  rendered by script (`raw` will show only the shell); use `chrome-pilot` if
  the page is not under investigation.
- **Redirects are followed and listed** in `redirects`; a redirect into a
  private address, a credentialed URL or a non-http scheme stops the fetch
  with the reason.
