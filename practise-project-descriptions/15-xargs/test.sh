#!/usr/bin/env bash
set -euo pipefail

# Golden-test: sammenligner kandidat mot ekte `xargs`.
CAND="${1:-go run .}"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail=0

check() {
  local name="$1"; shift
  local input="$1"; shift
  # Resten av argumentene er xargs-argumentene (flagg + kommando).
  local got want
  got=$(printf '%s' "$input" | $CAND "$@" 2>/dev/null || true)
  want=$(printf '%s' "$input" | xargs "$@" 2>/dev/null || true)
  if [[ "$got" == "$want" ]]; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    echo "  input:   $(printf '%q' "$input")"
    echo "  args:    $*"
    echo "  got:     $(printf '%q' "$got")"
    echo "  want:    $(printf '%q' "$want")"
    fail=1
  fi
}

check "default-echo"   $'a b c\n'        echo
check "n1"             $'a\nb\nc\n'       -n 1 echo
check "n2"             $'1 2 3 4\n'       -n 2 echo
check "replace-I"      $'x\ny\n'          -I {} echo item-{}
check "default-noargs" $'hei verden\n'

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi
echo "ALL PASS"
