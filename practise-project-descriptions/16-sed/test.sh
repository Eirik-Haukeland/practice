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

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Teller IKKE mot bestått/feilet — vises kun som
# STRETCH PASS/FAIL. Samme golden-diff-mekanisme som de påkrevde casene
# (kandidat vs. ekte sed), men tar vilkårlige sed-argumenter for å dekke
# flere skilletegn, backreferanser, -n/p og flere -e.
stretch_fail=0
run_stretch() { # run_stretch <navn> <input> [sed-args...]
  local name="$1"; shift
  local input="$1"; shift
  local got want
  got=$(printf '%s' "$input" | $CAND "$@" 2>/dev/null || true)
  want=$(printf '%s' "$input" | sed "$@" 2>/dev/null || true)
  if [[ "$got" == "$want" ]]; then
    echo "STRETCH PASS $name"
  else
    echo "STRETCH FAIL $name  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi
}

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"
# Annet skilletegn enn /
run_stretch "alt-delim-pipe"   $'a/b\n'        's|/|-|'
# Backreferanser i erstatningen
run_stretch "backref-swap"     $'John Smith\n' 's/\(\w\+\) \(\w\+\)/\2 \1/'
# -n + p: skriv kun ut endrede linjer
run_stretch "n-p-print"        $'a a a\nxyz\n' -n 's/a/b/p'
# Flere -e-uttrykk kjedet
run_stretch "multi-e"          $'foo\n'        -e 's/foo/bar/' -e 's/bar/baz/'

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi
echo "ALL PASS"
if [[ "$stretch_fail" -ne 0 ]]; then
  echo "STRETCH:  $stretch_fail valgfrie case ikke bestått ennå (greit — ikke påkrevd)"
else
  echo "STRETCH:  alle bestått"
fi
