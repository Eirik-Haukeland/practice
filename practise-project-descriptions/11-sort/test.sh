#!/usr/bin/env bash
set -euo pipefail

# Golden-test: sammenligner kandidat mot systemets ekte `sort`.
# Bruk: ./test.sh "go run ."   (default), eller ./test.sh sort for sanity.
# NB: sort er locale-følsomt -> LC_ALL=C for deterministisk byte-sortering.

export LC_ALL=C

CAND="${1:-go run .}"
REF="sort"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

check() {
  local name="$1" input="$2"; shift 2
  local got exp
  got=$($CAND "$@" < "$input")
  exp=$($REF  "$@" < "$input")
  if [[ "$got" == "$exp" ]]; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    diff <(printf '%s' "$exp") <(printf '%s' "$got") || true
    exit 1
  fi
}

# Tekstlinjer (entydige -> stabil rekkefølge ikke et problem)
printf 'banana\napple\ncherry\ndate\n' > "$tmp/words"
# Tall
printf '10\n2\n1\n30\n3\n' > "$tmp/nums"
# Med duplikater
printf 'pear\napple\npear\nfig\napple\n' > "$tmp/dups"
# Flere felt, andre felt er entydig
printf 'x 3\ny 1\nz 2\nw 4\n' > "$tmp/fields"

check "standard"        "$tmp/words"
check "-n numerisk"     "$tmp/nums"  -n
check "-r revers"       "$tmp/words" -r
check "-u unik"         "$tmp/dups"  -u
check "-k 2 felt"       "$tmp/fields" -k 2

echo "Alle tester bestått."
