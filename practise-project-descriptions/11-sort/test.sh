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

fail=0
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
    fail=1
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

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Teller IKKE mot bestått/feilet — vises bare som
# STRETCH PASS/FAIL. Samme metode som check (golden-diff mot ekte sort, LC_ALL=C).
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

# Fixture med blandet bokstavstørrelse for -f.
printf 'Banana\napple\nCherry\ndate\n' > "$tmp/mixedcase"
# Fixture med ':' som feltskilletegn for -t.
printf 'a:3\nb:1\nc:2\nd:4\n' > "$tmp/colon"

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"
# -f: ignorer bokstavstørrelse.
run_stretch "-f ignorer-case"     "$tmp/mixedcase" -f
# Kombinert -nr: numerisk omvendt.
run_stretch "-nr kombinert"       "$tmp/nums" -nr
# -t med -k: egendefinert feltskilletegn.
run_stretch "-t felt-skille"      "$tmp/colon" -t : -k 2
# -t kombinert med numerisk på felt 2.
run_stretch "-t -k -n felt-num"   "$tmp/colon" -t : -k 2 -n

echo ""
if [ "$fail" -ne 0 ]; then
  echo "PÅKREVD: FEILET (se FAIL over)"
  exit 1
fi
echo "PÅKREVD: alle bestått"
if [ "$stretch_fail" -ne 0 ]; then
  echo "STRETCH:  $stretch_fail valgfrie case ikke bestått ennå (greit — ikke påkrevd)"
else
  echo "STRETCH:  alle bestått"
fi
