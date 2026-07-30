# Second opinions and proxies

Two consultation servers and two proxies. The consultation servers are a
deliberate choice about **where the prompt goes**; the proxies are
infrastructure you work *with*, not tools you pick per task.

## ask-llm vs ask-gemini

Both expose a single tool that forwards a prompt and returns the response:
`ask_llm(prompt)` and `ask_gemini(prompt)`.

| | `ask-llm` | `ask-gemini` |
|---|---|---|
| Backend | OpenAI-compatible endpoint — primarily local LM Studio | Vertex AI Gemini |
| Where the prompt goes | Nowhere. Stays on the machine | Google Cloud |
| Cost | none | Vertex AI billing |
| Strength | Whatever model is loaded | Frontier-class |

**Try `ask-llm` first when the material is sensitive.** Customer mail bodies,
capture contents, internal hostnames, incident details, and anything under
investigation should go to the local model if they go anywhere at all. Reach for
`ask-gemini` when the question is hard and the material is not sensitive — a
design trade-off, an unfamiliar protocol, a second read on an algorithm.

Both exist mainly for MCP clients without shell access, where the `gem-*` and
`llm-cli` CLIs cannot be invoked. When a shell is available, the CLIs offer more
control; the MCP servers offer availability.

What a second opinion is good for: a review of reasoning you have already done,
a competing approach, a sanity check on an unfamiliar domain. What it is not:
a source of facts about this codebase or this incident. The other model cannot
see either, so treat its answer as an argument to evaluate, not as evidence.

## slack-mcp-extender

A transparent proxy over the **official** Slack MCP. Every `slack_*` tool passes
through unmodified — if a Slack capability exists, use it exactly as documented
and do not think about the proxy.

Its reason to exist is the three tools the official connector lacks:

| Tool | Does |
|---|---|
| `ext_file_upload` | Upload a local file as a root message |
| `ext_file_upload_to_thread` | Upload a local file as a thread reply |
| `ext_file_download` | Save a Slack file to local disk |

Uploads and downloads run under the user's own identity, and paths are contained
in both directions by operator configuration. A containment denial is the
configuration working, not a bug to route around — a denied path means the
operator put it out of bounds.

Posting to Slack is an outward-facing action. Get explicit confirmation of the
channel, the thread, and the file before uploading, and remember that a file
posted to a channel is visible to everyone in it.

## mcp-guardian

A governance proxy in front of MCP servers: hash-chained audit receipts per tool
call, failure-based constraint learning, budget and convergence limits, schema
validation, and **tool masking**.

You may not notice it, and that is the design. Two things follow:

- **A masked tool is masked deliberately.** If an expected tool is absent, the
  operator hid it. Do not look for another route to the same capability; say the
  tool is unavailable.
- **Repeating a failed call may be blocked by design.** The proxy learns from
  failures to stop retry loops. A refusal that mentions a prior failure means
  change the approach, not the retry count.

Every call you make through it is recorded in a tamper-evident receipt chain.
That is an argument for making the deliberate call rather than the exploratory
one — the record is the point.
