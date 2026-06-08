#!/usr/bin/env bash
set -euo pipefail

# Golden-test: sammenligner kandidat mot ekte `sed` for s///-tilfeller.
CAND="${1:-go run .}"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail=0

# stdin-test: check <navn> <input> <sed-uttrykk>
check_stdin() {
  local name="$1" input="$2" expr="$3"
  local got want
  got=$(printf '%s' "$input" | $CAND "$expr" 2>/dev/null || true)
  want=$(printf '%s' "$input" | sed "$expr" 2>/dev/null || true)
  if [[ "$got" == "$want" ]]; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    echo "  expr: $expr"
    echo "  got:  $(printf '%q' "$got")"
    echo "  want: $(printf '%q' "$want")"
    fail=1
  fi
}

check_stdin "simple"      $'foo bar\n'  's/foo/baz/'
check_stdin "first-only"  $'a a a\n'    's/a/b/'
check_stdin "global"      $'a a a\n'    's/a/b/g'
check_stdin "regex-digit" $'x123y\n'    's/[0-9]\+/N/g'

# fil-test
echo "cat sat on cat" > "$tmp/in.txt"
got=$($CAND 's/cat/dog/g' "$tmp/in.txt" 2>/dev/null || true)
want=$(sed 's/cat/dog/g' "$tmp/in.txt" 2>/dev/null || true)
if [[ "$got" == "$want" ]]; then
  echo "PASS file-input"
else
  echo "FAIL file-input"
  echo "  got:  $(printf '%q' "$got")"
  echo "  want: $(printf '%q' "$want")"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi
echo "ALL PASS"
