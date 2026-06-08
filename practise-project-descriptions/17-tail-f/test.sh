#!/usr/bin/env bash
set -euo pipefail

# OPPFØRSELS-TEST (ikke ren golden-diff).
# tail -f er sanntids/timing-avhengig, så vi tester funksjonelt:
# start kandidaten i bakgrunnen, append linjer med forsinkelse,
# og sjekk at de nye linjene dukker opp i utdata.
CAND="${1:-go run .}"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail=0

# --- Test 1: -n N (statisk, kan diffes) ---
log="$tmp/static.log"
printf 'l1\nl2\nl3\nl4\nl5\n' > "$log"
got=$($CAND -n 3 "$log" 2>/dev/null || true)
want=$'l3\nl4\nl5'
if [[ "$got" == "$want" ]]; then
  echo "PASS n3-static"
else
  echo "FAIL n3-static"
  echo "  got:  $(printf '%q' "$got")"
  echo "  want: $(printf '%q' "$want")"
  fail=1
fi

# --- Test 2: -f følger nye linjer (oppførsels-test) ---
flog="$tmp/follow.log"
out="$tmp/follow.out"
printf 'start\n' > "$flog"

# Start kandidaten i bakgrunnen; samle stdout i en fil.
$CAND -f "$flog" > "$out" 2>/dev/null &
pid=$!

# Gi programmet tid til å starte og lese eksisterende innhold.
sleep 1.5

# Append nye linjer med forsinkelse.
printf 'appended-1\n' >> "$flog"
sleep 1
printf 'appended-2\n' >> "$flog"
sleep 1.5

# Drep kandidaten rent.
kill "$pid" 2>/dev/null || true
wait "$pid" 2>/dev/null || true

if grep -q 'appended-1' "$out" && grep -q 'appended-2' "$out"; then
  echo "PASS follow-appends"
else
  echo "FAIL follow-appends"
  echo "  utdata var:"
  sed 's/^/    /' "$out" || true
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi
echo "ALL PASS"
