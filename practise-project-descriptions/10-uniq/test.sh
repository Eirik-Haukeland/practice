#!/usr/bin/env bash
set -euo pipefail

# Golden-test: sammenligner kandidat mot systemets ekte `uniq`.
# Bruk: ./test.sh "go run ."   (default), eller ./test.sh uniq for sanity.
# NB: locale-følsomt -> LC_ALL=C. -c har variabel padding -> normaliser med tr -s ' '.

export LC_ALL=C

CAND="${1:-go run .}"
REF="uniq"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Normaliser ledende/mellomliggende whitespace (for -c) med awk: trim + squeeze.
norm() { awk '{$1=$1};1'; }

check() {
  local name="$1" input="$2"; shift 2
  local got exp
  got=$($CAND "$@" < "$input" | norm)
  exp=$($REF  "$@" < "$input" | norm)
  if [[ "$got" == "$exp" ]]; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    diff <(printf '%s' "$exp") <(printf '%s' "$got") || true
    exit 1
  fi
}

# Sortert input med tilstøtende duplikater
printf 'apple\napple\nbanana\ncherry\ncherry\ncherry\n' > "$tmp/sorted"

check "standard"          "$tmp/sorted"
check "-c (tell)"         "$tmp/sorted" -c
check "-d (kun dupl.)"    "$tmp/sorted" -d
check "-u (kun unike)"    "$tmp/sorted" -u

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Teller IKKE mot bestått/feilet. Samme LC_ALL=C og
# norm()-normalisering som de påkrevde casene.
stretch_fail=0
run_stretch() {
  local name="$1" input="$2"; shift 2
  local got exp
  got=$($CAND "$@" < "$input" 2>/dev/null | norm) || true
  exp=$($REF  "$@" < "$input" 2>/dev/null | norm) || true
  if [[ "$got" == "$exp" ]]; then
    echo "STRETCH PASS $name"
  else
    echo "STRETCH FAIL $name  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi
}

# Fixture: case-varianter (for -i)
printf 'Apple\napple\nBanana\nbanana\n' > "$tmp/case"
# Fixture: ledende felt/tegn (for -f / -s)
printf 'x apple\ny apple\nz banana\n' > "$tmp/fields"
printf 'Xapple\nYapple\nZbanana\n'    > "$tmp/skipchars"

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"
# -i: ignorer bokstavstørrelse
run_stretch "-i ignorer case"          "$tmp/case"      -i
# -f N: hopp over N felt før sammenligning
run_stretch "-f hopp over felt"        "$tmp/fields"    -f 1
# -s N: hopp over N tegn før sammenligning
run_stretch "-s hopp over tegn"        "$tmp/skipchars" -s 1

echo ""
echo "Alle påkrevde tester bestått."
if [ "$stretch_fail" -ne 0 ]; then
  echo "STRETCH:  $stretch_fail valgfrie case ikke bestått ennå (greit — ikke påkrevd)"
else
  echo "STRETCH:  alle bestått"
fi
