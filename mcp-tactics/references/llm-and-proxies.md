# Second opinions and proxies

Two consultation servers and two proxies. The consultation servers are a
deliberate choice about **where the prompt goes**; the proxies are
infrastructure you work *with*, not tools you pick per task.

## ask-llm vs ask-gemini

Both expose a single tool that forwards a prompt and returns the response:
`ask_llm(prompt)` and `ask_gemini(prompt)`. That one tool is the whole
surface — neither ships `get_usage`, and nothing is missing when you do not
find one.

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

## mcp-bridge

A protocol-and-auth bridge, not a policy layer: it connects a stdio-only MCP
client to a Streamable HTTP MCP server that demands a **pre-registered OAuth
client** — the official Slack MCP, GitHub Apps, Microsoft Entra ID, and similar
enterprise SaaS that do not support Dynamic Client Registration. (Servers that
support DCR need no bridge; capable clients reach those directly.)

When it is in the path you should not notice it: the upstream's tools appear as
if the server were local, and nothing is added, masked, or recorded. Two things
follow:

- **A missing tool means the upstream does not offer it.** There is no masking
  layer to suspect and nothing to route around.
- **An authentication failure is the operator's to fix, not yours to retry.**
  Client registration happens in the provider's admin console and login at the
  operator's terminal; no tool call can repair an expired or absent login.
  Report it and stop.

Its predecessor `mcp-guardian` wrapped the same bridge in a governance layer —
audit receipts, tool masking, budget limits — and was archived in August 2026
with that layer never having entered service. Guidance that mentions masked
tools or receipt chains describes the archived proxy, not the current fleet.
