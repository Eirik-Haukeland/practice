#!/usr/bin/env bash
set -euo pipefail

# Golden-test: sammenligner kandidat mot systemets ekte `uniq`.
# Bruk: ./test.sh "go run ."   (default), eller ./test.sh uniq for sanity.
# NB: locale-følsomt -> LC_ALL=C. -c har variabel padding -> normaliser med tr -s ' '.

export LC_ALL=C

CAND="${1:-go run .}"
REF="uniq"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Normaliser ledende/mellomliggende whitespace (for -c) med awk: trim + squeeze.
norm() { awk '{$1=$1};1'; }

check() {
  local name="$1" input="$2"; shift 2
  local got exp
  got=$($CAND "$@" < "$input" | norm)
  exp=$($REF  "$@" < "$input" | norm)
  if [[ "$got" == "$exp" ]]; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    diff <(printf '%s' "$exp") <(printf '%s' "$got") || true
    exit 1
  fi
}

# Sortert input med tilstøtende duplikater
printf 'apple\napple\nbanana\ncherry\ncherry\ncherry\n' > "$tmp/sorted"

check "standard"          "$tmp/sorted"
check "-c (tell)"         "$tmp/sorted" -c
check "-d (kun dupl.)"    "$tmp/sorted" -d
check "-u (kun unike)"    "$tmp/sorted" -u

echo "Alle tester bestått."
