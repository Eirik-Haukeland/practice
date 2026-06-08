#!/usr/bin/env bash
set -euo pipefail

# Golden-test: sammenligner kandidat mot systemets ekte `tac`.
# Bruk: ./test.sh "go run ."   (default), eller ./test.sh tac for sanity.

CAND="${1:-go run .}"
REF="tac"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail=0
check() {
  local name="$1" input="$2"
  local got exp
  got=$($CAND < "$input")
  exp=$($REF < "$input")
  if [[ "$got" == "$exp" ]]; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    diff <(printf '%s' "$exp") <(printf '%s' "$got") || true
    exit 1
  fi
}

# Fixture: flere linjer
printf 'alpha\nbeta\ngamma\ndelta\n' > "$tmp/multi"
check "reverser flere linjer" "$tmp/multi"

# Fixture: én linje
printf 'kun en linje\n' > "$tmp/single"
check "enkelt-linje" "$tmp/single"

# Fixture: tom input
printf '' > "$tmp/empty"
check "tom input" "$tmp/empty"

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Teller IKKE mot bestått/feilet — vises bare som
# STRETCH PASS/FAIL slik at du ser hva som gjenstår. Samme stdin-mønster og
# sammenligning som de påkrevde casene.
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

# Fixture: poster adskilt av ';' (uten avsluttende newline)
printf 'a;b;c;' > "$tmp/sep"
# Fixture: flere filer
printf 'en\nto\n' > "$tmp/f1"
printf 'tre\nfire\n' > "$tmp/f2"

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"
# -s SEP: egendefinert skilletegn
run_stretch "-s egendefinert skilletegn" "$tmp/sep" -s ';'
# -b: skilletegn foran hver post
run_stretch "-b skilletegn foran"        "$tmp/sep" -s ';' -b
# Flere filargumenter (reverser samlet output)
if diff <($CAND "$tmp/f1" "$tmp/f2" 2>/dev/null) <($REF "$tmp/f1" "$tmp/f2" 2>/dev/null) >/dev/null 2>&1; then
  echo "STRETCH PASS flere filargumenter"
else
  echo "STRETCH FAIL flere filargumenter  (valgfritt)"
  stretch_fail=$((stretch_fail + 1))
fi

echo ""
echo "Alle påkrevde tester bestått."
if [ "$stretch_fail" -ne 0 ]; then
  echo "STRETCH:  $stretch_fail valgfrie case ikke bestått ennå (greit — ikke påkrevd)"
else
  echo "STRETCH:  alle bestått"
fi
