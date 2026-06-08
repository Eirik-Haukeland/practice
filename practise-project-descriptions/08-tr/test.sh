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

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Teller IKKE mot bestått/feilet. Samme stdin-mønster
# og sammenligning som de påkrevde casene.
stretch_fail=0
run_stretch() {
  local name="$1" input="$2"; shift 2
  local got exp
  got=$($CAND "$@" < "$input" 2>/dev/null) || true
  exp=$($REF  "$@" < "$input" 2>/dev/null) || true
  if [[ "$got" == "$exp" ]]; then
    echo "STRETCH PASS $name"
  else
    echo "STRETCH FAIL $name  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi
}

printf 'hallo123 verden\n' > "$tmp/mix"

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"
# -c: komplement av SET1 (alt som ikke er a-z -> _)
run_stretch "-c komplement"            "$tmp/mix"  -c 'a-z' '_'
# Forhåndsdefinerte klasser
run_stretch "klasse [:alpha:]"         "$tmp/mix"  '[:alpha:]' '_'
run_stretch "klasse [:digit:]"         "$tmp/mix"  '[:digit:]' '_'
# SET2 kortere enn SET1 (siste tegn gjentas)
run_stretch "SET2 kortere enn SET1"    "$tmp/abc"  'a-f' 'xy'

echo ""
echo "Alle påkrevde tester bestått."
if [ "$stretch_fail" -ne 0 ]; then
  echo "STRETCH:  $stretch_fail valgfrie case ikke bestått ennå (greit — ikke påkrevd)"
else
  echo "STRETCH:  alle bestått"
fi
