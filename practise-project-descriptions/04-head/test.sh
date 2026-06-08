#!/usr/bin/env bash
set -euo pipefail

# Golden-test for head. Sammenligner kandidat mot systemets ekte head via diff.
# Bruk: ./test.sh "go run ."   (default: go run .)
# Sanity: ./test.sh head  -> skal gi PASS på alle case.
CAND="${1:-go run .}"
REF="head"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# 20 nummererte linjer slik at standard (10) og -n 3 gir ulik output.
for i in $(seq 1 20); do printf 'linje %02d\n' "$i"; done > "$tmp/f"
printf 'kort en\nkort to\n' > "$tmp/liten"

fail=0

# Vi leser fra stdin (< f) slik at head ikke skriver filnavn-overskrifter.
cmp_case() {
  local name="$1"; local flags="$2"; local file="$3"
  if diff \
      <(eval "$CAND $flags < $file") \
      <(eval "$REF $flags < $file") >/dev/null; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    fail=1
  fi
}

cmp_case "default"      ""        "$tmp/f"
cmp_case "lines-3"      "-n 3"    "$tmp/f"
cmp_case "lines-over"   "-n 100"  "$tmp/f"
cmp_case "bytes-5"      "-c 5"    "$tmp/f"
cmp_case "fewer-lines"  ""        "$tmp/liten"

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "ALLE TESTER PASS"
