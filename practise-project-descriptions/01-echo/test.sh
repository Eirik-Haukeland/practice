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

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Disse teller IKKE mot bestått/feilet — de vises bare
# som STRETCH PASS/FAIL slik at du ser hva som gjenstår av ekstra-funksjonalitet.
stretch_fail=0
run_stretch() {
  local name="$1"; local args="$2"
  if diff <(eval "$CAND $args") <(eval "$REF $args") >/dev/null 2>&1; then
    echo "STRETCH PASS $name"
  else
    echo "STRETCH FAIL $name  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi
}

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"
# -E: deaktiver escape eksplisitt -> skal skrive \t literalt
run_stretch "E-disable-escapes" '-E "a\tb"'
# Kombinerte flagg
run_stretch "combined-ne"       '-ne "a\tb"'
run_stretch "combined-nE"       '-nE "a\tb"'
# Rekkefølge avgjør: siste av -e/-E vinner
run_stretch "order-eE-E-wins"   '-eE "a\tb"'
run_stretch "order-Ee-e-wins"   '-Ee "a\tb"'
# Flere escape-sekvenser
run_stretch "escape-alert"      '-e "a\ab"'
run_stretch "escape-backspace"  '-e "a\bb"'
run_stretch "escape-cr"         '-e "a\rb"'
run_stretch "escape-vtab"       '-e "a\vb"'
run_stretch "escape-formfeed"   '-e "a\fb"'
# Oktal: \0NNN  (\0101 -> 'A')
run_stretch "escape-octal"      '-e "\0101"'

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
