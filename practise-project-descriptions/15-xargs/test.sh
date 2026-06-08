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

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Teller IKKE mot bestått/feilet — vises kun som
# STRETCH PASS/FAIL slik at du ser hva som gjenstår. Samme golden-diff-
# mekanisme som de påkrevde casene (kandidat vs. ekte xargs).
stretch_fail=0
run_stretch() {
  local name="$1"; shift
  local input="$1"; shift
  local got want
  got=$(printf '%s' "$input" | $CAND "$@" 2>/dev/null || true)
  want=$(printf '%s' "$input" | xargs "$@" 2>/dev/null || true)
  if [[ "$got" == "$want" ]]; then
    echo "STRETCH PASS $name"
  else
    echo "STRETCH FAIL $name  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi
}

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"
# -d: egendefinert skilletegn
run_stretch "d-colon"        $'a:b:c\n'   -d : echo
# -0: NUL som skilletegn
run_stretch "null-delim"     $'x\0y\0'    -0 echo
# -r: ikke kjør kommandoen hvis input er tom
run_stretch "r-empty"        ''           -r echo
run_stretch "r-blank"        $'   \n'     -r echo
# -P N: parallell kjøring — ikke-deterministisk utdatarekkefølge, kan ikke
# golden-diffes pålitelig.
echo "STRETCH SKIP P-parallel  (ikke-deterministisk utdatarekkefølge)"

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi
echo "ALL PASS"
if [[ "$stretch_fail" -ne 0 ]]; then
  echo "STRETCH:  $stretch_fail valgfrie case ikke bestått ennå (greit — ikke påkrevd)"
else
  echo "STRETCH:  alle bestått"
fi
