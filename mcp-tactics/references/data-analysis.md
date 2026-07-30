# Data analysis — data-toolbox

Workspace-scoped DuckDB plus a containerized Python sandbox, over files that
stay on the host. Call `get_usage` before first use.

## Prerequisites

Podman. `describe_runtime` once at session start reports the Python version,
container image, installed packages, fonts, network posture, and mount points —
run it before assuming a library exists. The runtime ships `duckdb`, `pandas`,
`polars`, `pyarrow`, `matplotlib`, and `Pillow`, plus Noto CJK fonts so
Japanese matplotlib labels render without setup.

## SQL first, Python second

| Tool | Use it for |
|---|---|
| `load_data` | Host file → table. Reader inferred from the extension (`.csv`, `.json` / `.jsonl`, `.parquet`) |
| `query_data` | Everything expressible as SQL — filtering, joins, aggregation, window functions |
| `execute_code` | Only what SQL genuinely cannot do: plotting, custom parsing, iterative computation |
| `load_from_work` | Table-ize a file that `execute_code` just wrote into `/work` |
| `attach_files` | Return an image or text file as inline MCP content so the client renders it |
| `describe_workspace` | Every table's column schema in one call — the "what's in here?" tool |

DuckDB is faster and less error-prone than pandas for the shape of work that is
actually SQL. Reach for `execute_code` when you need a chart or a parser, not to
avoid writing a join.

## The truncation trap

`query_data` **auto-appends a `LIMIT`** (default 20000) when your SQL has none.
The result carries `limit_applied`, `limit_reached`, `truncated`, and `total`.

Read them. A summary written from a silently truncated result is wrong in the
worst way — plausible, specific, and off by however many rows were dropped. If
`truncated` is true, either aggregate in SQL so the answer fits, or state the
truncation explicitly in the output. Aggregating is almost always right:
`COUNT`, `GROUP BY`, and percentiles do not truncate.

## Charts

Write the plot in `execute_code`, save it under `/work`, then `attach_files` it
so the chart appears inline instead of as a path the user has to open. Japanese
labels work out of the box thanks to the bundled CJK fonts — set the font family
rather than romanizing labels.

## Workspaces are the unit of state

Tables, `/work` contents, and the container live in one workspace. `load_data`
reads from the host through configured `allowed_paths`; `load_from_work` reads
what already lives in `/work` and bypasses that check, which is why it is the
right tool for `execute_code` output and the wrong tool for new host files.

`list_workspaces` to find an earlier session's work, `describe_workspace` to see
what is in it, `delete_workspace` with `dry_run: true` before removing anything.

## When not to use this server

- **A pcap** → [pcap.md](pcap.md). `pcap-analyzer` mounts the capture read-only
  and preserves its hash; loading packet exports into DuckDB loses that.
- **A one-line question about a small file** → reading the file directly is
  faster than provisioning a workspace and a container.
- **Data that must not leave its original form** → the workspace copies data
  into a container-visible directory. For evidence handling, prefer the
  read-only-mount servers.
