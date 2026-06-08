#!/usr/bin/env bash
set -euo pipefail

# Golden-test: sammenligner kandidat mot systemets ekte `cut`.
# Bruk: ./test.sh "go run ."   (default), eller ./test.sh cut for sanity.

CAND="${1:-go run .}"
REF="cut"

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

printf 'root:x:0:0:root:/root:/bin/bash\ndaemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin\n' > "$tmp/passwd"
printf 'abcdefgh\n12345678\n' > "$tmp/chars"

check "-f 1 med -d :"      "$tmp/passwd" -d ':' -f 1
check "-f 1,3 med -d :"    "$tmp/passwd" -d ':' -f 1,3
check "-f 2-3 med -d :"    "$tmp/passwd" -d ':' -f 2-3
check "-c 1-3"             "$tmp/chars"  -c 1-3
check "-c 1-3,5"           "$tmp/chars"  -c 1-3,5

echo "Alle tester bestått."
