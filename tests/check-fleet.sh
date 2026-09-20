#!/usr/bin/env bash
#
# Repo-specific check: the fleet this skill describes is stated in five places,
# and they drift one language at a time — README.ja.md still said "24" when
# SKILL.md said "26". The server index in SKILL.md is the single source; every
# other statement of the count, and the references table, is held to it.
#
# Usage: make check
set -euo pipefail

cd "$(dirname "$0")/.."

skill=mcp-tactics/SKILL.md
fail=0
err() { printf 'FAIL: %s\n' "$1" >&2; fail=1; }

# The servers are the first-column names of the two index tables, which sit
# between "## Server index" and the "Proxies" paragraph.
servers=$(awk '/^## Server index/ { on = 1; next } /^Proxies/ { on = 0 } on && /^\| `/ { split($0, c, "`"); print c[2] }' "$skill" | sort)
count=$(printf '%s\n' "$servers" | grep -c .)
[ "$count" -ge 20 ] || err "only $count servers found in the index of $skill — the parser no longer matches the tables"

dupes=$(printf '%s\n' "$servers" | uniq -d)
[ -z "$dupes" ] || err "listed twice in the server index: $dupes"

# Every statement of the count.
check_count() { # file, pattern with N for the number
	local file=$1 pattern=$2 found
	found=$(grep -oE "$pattern" "$file" | grep -oE '[0-9]+' | head -1 || true)
	if [ -z "$found" ]; then
		err "$file no longer states the number of MCP servers (looked for /$pattern/)"
	elif [ "$found" != "$count" ]; then
		err "$file says $found MCP servers; the index in $skill lists $count"
	fi
}
check_count "$skill" '^[0-9]+ MCP servers and 2 proxies'
check_count README.md "[0-9]+ MCP servers and 2 proxies"
check_count README.ja.md '[0-9]+ MCP サーバと 2 プロキシ'
check_count AGENTS.md "[0-9]+ MCP servers"

# Every server has a playbook in the references table (after "## References").
refs=$(awk '/^## References/ { on = 1 } on && /^\| \[references\//' "$skill")
while IFS= read -r name; do
	[ -n "$name" ] || continue
	printf '%s\n' "$refs" | grep -q "\`$name\`" || err "$name is in the server index but no row of the references table covers it"
done <<EOF
$servers
EOF

if [ "$fail" -ne 0 ]; then
	exit 1
fi
printf 'fleet: %s servers, stated consistently, each covered by a reference\n' "$count"
