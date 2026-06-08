#!/usr/bin/env bash
set -euo pipefail

# Golden-test: sammenligner kandidat mot systemets ekte `tac`.
# Bruk: ./test.sh "go run ."   (default), eller ./test.sh tac for sanity.

CAND="${1:-go run .}"
REF="tac"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail=0
check() {
  local name="$1" input="$2"
  local got exp
  got=$($CAND < "$input")
  exp=$($REF < "$input")
  if [[ "$got" == "$exp" ]]; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    diff <(printf '%s' "$exp") <(printf '%s' "$got") || true
    exit 1
  fi
}

# Fixture: flere linjer
printf 'alpha\nbeta\ngamma\ndelta\n' > "$tmp/multi"
check "reverser flere linjer" "$tmp/multi"

# Fixture: én linje
printf 'kun en linje\n' > "$tmp/single"
check "enkelt-linje" "$tmp/single"

# Fixture: tom input
printf '' > "$tmp/empty"
check "tom input" "$tmp/empty"

echo "Alle tester bestått."
