# Media production — voice-studio, video-studio, image-forge

Three servers that produce artifacts on local hardware. All three are
file-mediated (outputs are paths, never inline bytes) and async for heavy work.
Call each server's `get_usage` before first use.

## Division of labour

```
image-forge (or your own rendering) ─▶ page images ─┐
voice-studio ─▶ per-page audio ─────────────────────┴─▶ video-studio ─▶ mp4
```

`video-studio` is a **pure compositor**. It does not render slides and does not
synthesize speech; it muxes images and audio that already exist. If a request
needs a narrated video, the work is three steps, and the first two are where all
the judgement lives.

## voice-studio — Japanese only

The AivisSpeech Engine synthesizes **Japanese**. Other languages are not
supported — not degraded, not accented, unsupported. A request for English
narration cannot be served by this server, and translating the script into
Japanese instead is a decision to raise with the user, not to make silently.

Ordering:

1. `list_speakers` — pick voices by their actual characteristics rather than
   assuming a speaker id
2. `register_dictionary` — pronunciation entries for names, jargon, and
   initialisms **before** batch synthesis, so retakes are not needed
3. `synthesize_script` — batch-synthesize the script JSONL. Content-hash cached,
   so re-running after editing two lines re-synthesizes only those two
4. `synthesize_line` — single-line retakes
5. `master` — ffmpeg mastering: mp3 / m4b with chapters, loudness
   normalization, credits

Prerequisite: the AivisSpeech Engine must be running locally. Voice models carry
their own licences — the server has a license review workflow; honour it before
publishing anything.

For full workflows, the `radio-drama` and `multi-actor-narration` skills already
drive this server (script conversion, speaker attribution, performance
direction). Prefer the skill over hand-rolling the pipeline.

## video-studio

One real tool: `master`, over a page manifest pairing an image with its audio.

- **Each page lasts exactly as long as its audio**, so A/V sync is exact by
  construction — do not try to compute durations yourself
- `chapters` defaults on (per-page chapter markers)
- A page whose manifest `transition` is `"fade"` dips to the canvas background
  at that boundary. The fade happens **inside each page's own duration**, so the
  timeline never shifts — but narration keeps playing while the image dims, so
  leave trailing silence in the audio when it matters. `fade_seconds` sets the
  length (default 0.5); `0` makes every boundary a cut. There is no cross-page
  dissolve, by design
- `captions` (burned-in) and `soft_captions` (a toggleable `mov_text` track)
  both default **off** and are independent; burned-in pixels are the right
  choice when the video will be viewed where subtitle tracks are ignored
- Canvas override per call: `width` / `height` / `fps` — 16:9, 9:16, 1:1
- `async: true` → `job_id` → `check_job` for anything non-trivial

## image-forge

Local diffusion via stable-diffusion.cpp on Metal.

- **macOS on Apple Silicon only.** 16 GB RAM is the baseline; SDXL / Z-Image /
  Anima are comfortable there, while FLUX / SD3.5 need Q4 quantization on 16 GB.
  High resolutions on a 16 GB machine hit OOM — reduce resolution before
  reaching for `upscale`
- **Model weights are not bundled.** `list_models` shows what is actually
  installed; a model in the catalogue is not necessarily on this machine
- Per-model gotchas (CLIP-skip, the SDXL fp16-fix VAE, native resolution,
  sampler, prediction type) live in the model profile and are applied
  automatically — do not hand-tune them
- `generate` enqueues and returns a `job_id`; poll `check_job`. Outputs are PNG
  paths under the workspace
- `upscale` afterwards, rather than generating above the model's native
  resolution

The cloud counterpart is the `gem-image` CLI (Gemini). Choose `image-forge` when
the prompt or the subject should not leave the machine, or when no quota should
be spent; choose `gem-image` when the machine cannot host the model.
