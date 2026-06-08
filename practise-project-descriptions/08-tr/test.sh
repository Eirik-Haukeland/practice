#!/usr/bin/env bash
set -euo pipefail

# Golden-test: sammenligner kandidat mot systemets ekte `tr`.
# Bruk: ./test.sh "go run ."   (default), eller ./test.sh tr for sanity.

CAND="${1:-go run .}"
REF="tr"

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

printf 'hallo verden\n' > "$tmp/lower"
printf 'foo bar baz\n'  > "$tmp/words"
printf 'a  b    c\n'    > "$tmp/spaces"
printf 'abcdef\n'       > "$tmp/abc"

check "a-z til A-Z"        "$tmp/lower"  'a-z' 'A-Z'
check "enkelt-tegn o til 0" "$tmp/words"  'o' '0'
check "-d vokaler"         "$tmp/lower"  -d 'aeiou'
check "-s mellomrom"       "$tmp/spaces" -s ' '
check "range a-c til x-z"  "$tmp/abc"    'a-c' 'x-z'

echo "Alle tester bestått."
