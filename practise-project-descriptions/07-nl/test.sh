#!/usr/bin/env bash
set -euo pipefail

# Golden-test: sammenligner kandidat mot systemets ekte `nl`.
# Bruk: ./test.sh "go run ."   (default), eller ./test.sh nl for sanity.
# NB: GNU nl bruker variabel padding -> begge sider normaliseres med `tr -s ' '`.

CAND="${1:-go run .}"
REF="nl"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Sammenlign med whitespace-normalisering (tab -> space, squeeze).
check() {
  local name="$1" input="$2"; shift 2
  local got exp
  got=$($CAND "$@" < "$input" | tr '\t' ' ' | tr -s ' ')
  exp=$($REF  "$@" < "$input" | tr '\t' ' ' | tr -s ' ')
  if [[ "$got" == "$exp" ]]; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    diff <(printf '%s' "$exp") <(printf '%s' "$got") || true
    exit 1
  fi
}

# Fixture: blandede tomme/ikke-tomme linjer
printf 'forste\n\ntredje\n\nfemte\n' > "$tmp/mixed"

check "standard (kun ikke-tomme)" "$tmp/mixed"
check "-b a (alle linjer)"        "$tmp/mixed" -b a
check "-b t (kun ikke-tomme)"     "$tmp/mixed" -b t
check "-b n (ingen)"              "$tmp/mixed" -b n

echo "Alle tester bestått."
