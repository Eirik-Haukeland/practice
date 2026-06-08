#!/usr/bin/env bash
set -euo pipefail

# Golden-test for echo. Sammenligner kandidat mot systemets ekte echo via diff.
# Bruk: ./test.sh "go run ."   (default: go run .)
# Sanity: ./test.sh echo  -> skal gi PASS på alle case.
CAND="${1:-go run .}"
REF="echo"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail=0

# Én test-case per flagg/funksjon. Argumentene sendes likt til kandidat og ekte echo.
run_case() {
  local name="$1"; local args="$2"
  if diff <(eval "$CAND $args") <(eval "$REF $args") >/dev/null; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    fail=1
  fi
}

run_case "no-flags"   'hei verden'
run_case "multi-args" 'a b c'
run_case "no-newline" '-n hei'
run_case "escape-tab" '-e "a\tb"'
run_case "empty"      ''

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "ALLE TESTER PASS"
