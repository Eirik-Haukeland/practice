#!/usr/bin/env bash
set -euo pipefail

# Golden-test: sammenligner kandidat mot systemets ekte `nl`.
# Bruk: ./test.sh "go run ."   (default), eller ./test.sh nl for sanity.
# NB: GNU nl bruker variabel padding -> begge sider normaliseres med `tr -s ' '`.

CAND="${1:-go run .}"
REF="nl"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Sammenlign med whitespace-normalisering (tab -> space, squeeze).
check() {
  local name="$1" input="$2"; shift 2
  local got exp
  got=$($CAND "$@" < "$input" | tr '\t' ' ' | tr -s ' ')
  exp=$($REF  "$@" < "$input" | tr '\t' ' ' | tr -s ' ')
  if [[ "$got" == "$exp" ]]; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    diff <(printf '%s' "$exp") <(printf '%s' "$got") || true
    exit 1
  fi
}

# Fixture: blandede tomme/ikke-tomme linjer
printf 'forste\n\ntredje\n\nfemte\n' > "$tmp/mixed"

check "standard (kun ikke-tomme)" "$tmp/mixed"
check "-b a (alle linjer)"        "$tmp/mixed" -b a
check "-b t (kun ikke-tomme)"     "$tmp/mixed" -b t
check "-b n (ingen)"              "$tmp/mixed" -b n

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Teller IKKE mot bestått/feilet. Samme whitespace-
# normalisering (tab -> space, squeeze) som de påkrevde casene.
stretch_fail=0
run_stretch() {
  local name="$1" input="$2"; shift 2
  local got exp
  got=$($CAND "$@" < "$input" 2>/dev/null | tr '\t' ' ' | tr -s ' ') || true
  exp=$($REF  "$@" < "$input" 2>/dev/null | tr '\t' ' ' | tr -s ' ') || true
  if [[ "$got" == "$exp" ]]; then
    echo "STRETCH PASS $name"
  else
    echo "STRETCH FAIL $name  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi
}

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"
# -w N: egendefinert feltbredde
run_stretch "-w egendefinert bredde"   "$tmp/mixed" -w 3
# -s STR: egendefinert skilletegn
run_stretch "-s egendefinert skille"   "$tmp/mixed" -s ':: '
# -v N: startnummer
run_stretch "-v startnummer"           "$tmp/mixed" -v 5
# -i N: inkrement
run_stretch "-i inkrement"             "$tmp/mixed" -i 10

echo ""
echo "Alle påkrevde tester bestått."
if [ "$stretch_fail" -ne 0 ]; then
  echo "STRETCH:  $stretch_fail valgfrie case ikke bestått ennå (greit — ikke påkrevd)"
else
  echo "STRETCH:  alle bestått"
fi
