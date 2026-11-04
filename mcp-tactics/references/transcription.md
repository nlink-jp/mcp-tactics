# Transcription — voice-scribe, gem-scribe

Two servers that turn a recording into text: `voice-scribe` locally and
`gem-scribe` through Vertex AI. The choice between them decides whether the
recording leaves the machine — which is why they are in this book. Both are
file-mediated and async for heavy work; they also return the transcript
*text* in the response, capped, because text is data.

**Every call names `work_dir`: the absolute path of a directory you can read
back** (your session or working directory). It is required and there is no
default — every result is a path under it, so a directory you cannot open
leaves you holding a path to nothing. It must already exist, and `~` is not
expanded. Under gem-agent and lagent the runtime attaches it for you. A
recording may also be named by an absolute path anywhere you can read (both
servers read it in place, never copying it), with credential locations such as
`~/.ssh` refused. Call each server's `get_usage` before first use.

## voice-scribe — recordings to text

Local speech-to-text via whisper.cpp.
No API key, no per-minute cost, and no audio leaves the machine — which is why
investigation material (a customer call, a meeting recording, a voicemail from
an incident) belongs here rather than in any cloud transcription API.

- **macOS on Apple Silicon only** — it needs CGO and Metal
- **Model weights are not bundled.** `list_models` shows what is actually
  installed; read it before promising a language or speaker labels
- `transcribe` enqueues and returns a `job_id`; poll `check_job`. The result
  carries the transcript up to `max_bytes` (default 65536, `0` = no cap); past
  it, `truncated` and an exact `omitted_bytes` say what is missing and the file
  holds all of it. Raise the cap or read the file — never re-run a narrower job
- It can label **who is speaking**, not just what was said — useful before
  handing a meeting recording to the `meeting-notes` skill
- The output envelope is shared with **`gem-scribe`**, so downstream parsers
  take a local and a cloud transcript interchangeably

## gem-scribe — recordings to text, through Vertex AI

The cloud counterpart of `voice-scribe`, on a **dedicated transcription model**
rather than a general one. Same tool shapes, so switching costs nothing:
`get_usage` → `transcribe` → `check_job`, the same workspace model, and the same
output envelope.

- **The audio leaves the machine and the call is metered** (~$0.30 per hour).
  That is the whole reason the choice exists
- **Up to 8 speakers**, against `voice-scribe`'s 4 — the usual reason to reach
  for it on a meeting with a large cast
- No models to download and no Apple Silicon requirement; it needs a Vertex AI
  project and credentials instead
- It also **translates and names speakers** — `translate_to` puts a translation
  beside the original in the same `text` map, and `speaker_hints` assigns real
  names to `spk:N`. Both are a second pass over the transcript text, so a
  failure there costs the enrichment and not the transcript; anything left
  behind is reported in `warning`. `voice-scribe` has no equivalent, which is
  a second reason to reach for this server on a meeting
- Results carry a **`warning`** field when the transcript is well-formed but
  probably wrong: speakers collapsed into one (two similar voices are returned
  as a single speaker, with no error), a speaker count past what attribution is
  reliable for, or no timings at all. You cannot hear the audio — read it

## Choosing between the two

Neither is the default.

- **Material under investigation stays local.** A customer call, an incident
  voicemail, anything whose content should not reach a third party: use
  `voice-scribe`. This decision is not a cost trade-off and is not reopened.
- Otherwise: cost and privacy favour `voice-scribe`; accuracy, speed and a cast
  larger than four favour `gem-scribe`.
- Either output feeds the `meeting-notes` skill unchanged.
