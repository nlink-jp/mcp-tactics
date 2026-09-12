# Web search — brave-search

One server, four tools, one contract: **every call is a billed request to
Brave, nothing is cached, and the results are not yours to keep.** Call
`get_usage` first; it carries the arguments, the result schemas, the cost
model and the error-recovery table.

## Which tool

| You want | Tool | Cost shape | Reach for it |
|---|---|---|---|
| URLs and snippets to read yourself | `web_search` | one request | first, almost always |
| Page text to reason over, sized to a token budget | `llm_context` | one request | when the snippets are too thin; start with a small `max_tokens` |
| A one-paragraph answer with numbered sources | `answer` | one search **plus ~10,000 input tokens** — about ten web searches | when the user wants the answer, not the sources |
| A thorough answer across several searches, with declared blind spots | `research` | every search it runs, plus tokens; cannot be stopped once dispatched | last, with small `max_queries` / `max_iterations` / `max_seconds`, and only after `answer` proved insufficient |

Order: `web_search` / `llm_context` → *(deliberate)* `answer` → *(last)*
`research`. Read `meta` on every result: it says what the call cost and, for
the Search tools, what rate budget is left.

## Pitfalls

- **Citations are unreliable for non-English replies.** Measured: an English
  reply carried citations every run, a Japanese reply in one run of three.
  An empty `citations` never means "no sources exist"; the result carries a
  `note` when Brave returned none. When sources matter, ask again or ask in
  English (`language: "en"`).
- **`altered` means Brave spell-corrected the query** and the results answer
  the altered form. Say so when you report them.
- **`research` cannot be cancelled.** The server receives the MCP cancel
  notification and ignores it because the upstream call has already been
  dispatched and will be billed regardless. Keep `max_seconds` small.
- **Brave's own defaults are US / English.** Set `country` and `search_lang`
  / `language` when the question is regional; the operator's config may
  already do so.
- **Search operators work in `query`** (`site:`, `-term`, `"phrase"`).
- **A URL under investigation does not go to `answer` / `research`.** Brave's
  model reads pages to compose the answer; whether it fetches them live is
  unverified. Searching *for* the indicator with `web_search` is an index
  read; use the URL row of the decision table for the rest.
- **`llm_context` is not a fetch.** For a URL outside Brave's index it answers
  with a *different* page and no error (measured: a two-day-old repository
  page came back as an unrelated project of the same name). When the user
  wants a specific URL read, use `web-fetch` — see
  [web-fetch.md](web-fetch.md); `llm_context` is for the pages a search found.

## Setup the operator has to do

Two Brave API keys — the Search plan and the Answers plan issue separate
ones — in `~/.config/brave-search/config.toml` (`api_key`,
`answers_api_key`). `brave-search auth check` confirms both without spending;
a `missing_api_key` error names the one that is absent.
