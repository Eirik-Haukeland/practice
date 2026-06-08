#!/usr/bin/env bash
set -euo pipefail

# Golden-test for cat. Sammenligner kandidat mot systemets ekte cat via diff.
# Bruk: ./test.sh "go run ."   (default: go run .)
# Sanity: ./test.sh cat  -> skal gi PASS på alle case.
CAND="${1:-go run .}"
REF="cat"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

printf 'linje en\nlinje to\nlinje tre\n' > "$tmp/a"
printf 'foo\nbar\n'                       > "$tmp/b"
printf 'med\ttab\n\ntom over\n'           > "$tmp/c"

fail=0

# Sammenlign kandidat mot ekte cat. cat skriver ikke filnavn i output,
# så vi kan trygt sende filargumenter direkte.
cmp_case() {
  local name="$1"; local args="$2"
  if diff <(eval "$CAND $args") <(eval "$REF $args") >/dev/null; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    fail=1
  fi
}

cmp_case "single-file" "$tmp/a"
cmp_case "multi-file"  "$tmp/a $tmp/b"
cmp_case "stdin"       "< $tmp/a"
cmp_case "number"      "-n $tmp/a"
cmp_case "dollar-eol"  "-E $tmp/c"

# Feilhåndtering: ikke-eksisterende fil skal gi exit-kode ulik 0 i begge.
if "$REF" "$tmp/finnesikke" >/dev/null 2>&1; then
  echo "FAIL missing-file (ref uventet exit 0)"; fail=1
else
  if eval "$CAND $tmp/finnesikke" >/dev/null 2>&1; then
    echo "FAIL missing-file (kandidat ga exit 0)"; fail=1
  else
    echo "PASS missing-file"
  fi
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "ALLE TESTER PASS"
