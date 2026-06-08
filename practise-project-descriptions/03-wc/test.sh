#!/usr/bin/env bash
set -euo pipefail

# Golden-test for wc. Sammenligner kandidat mot systemets ekte wc via diff.
# Bruk: ./test.sh "go run ."   (default: go run .)
# Sanity: ./test.sh wc  -> skal gi PASS på alle case.
CAND="${1:-go run .}"
REF="wc"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

printf 'hei verden\nandre linje\ntredje linje her\n' > "$tmp/f"
printf 'blåbær og rødgrøt\næøå\n'                     > "$tmp/utf8"
printf ''                                            > "$tmp/tom"

fail=0

# GNU wc bruker variabel padding/whitespace. Vi normaliserer begge sider:
# tr -s ' ' kollapser gjentatte mellomrom, og sed trimmer ledende/etterflgende.
norm() { tr -s ' ' | sed -e 's/^ *//' -e 's/ *$//'; }

# Vi leser fra stdin (< f) slik at filnavn-kolonnen ikke havner i output.
cmp_case() {
  local name="$1"; local flags="$2"; local file="$3"
  if diff \
      <(eval "$CAND $flags < $file" | norm) \
      <(eval "$REF $flags < $file"  | norm) >/dev/null; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    fail=1
  fi
}

cmp_case "default"   ""    "$tmp/f"
cmp_case "lines"     "-l"  "$tmp/f"
cmp_case "words"     "-w"  "$tmp/f"
cmp_case "bytes"     "-c"  "$tmp/f"
cmp_case "chars"     "-m"  "$tmp/utf8"
cmp_case "bytes-utf8" "-c" "$tmp/utf8"
cmp_case "empty"     ""    "$tmp/tom"

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "ALLE TESTER PASS"
