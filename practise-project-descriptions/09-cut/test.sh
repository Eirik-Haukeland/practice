#!/usr/bin/env bash
set -euo pipefail

# Golden-test: sammenligner kandidat mot systemets ekte `cut`.
# Bruk: ./test.sh "go run ."   (default), eller ./test.sh cut for sanity.

CAND="${1:-go run .}"
REF="cut"

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

printf 'root:x:0:0:root:/root:/bin/bash\ndaemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin\n' > "$tmp/passwd"
printf 'abcdefgh\n12345678\n' > "$tmp/chars"

check "-f 1 med -d :"      "$tmp/passwd" -d ':' -f 1
check "-f 1,3 med -d :"    "$tmp/passwd" -d ':' -f 1,3
check "-f 2-3 med -d :"    "$tmp/passwd" -d ':' -f 2-3
check "-c 1-3"             "$tmp/chars"  -c 1-3
check "-c 1-3,5"           "$tmp/chars"  -c 1-3,5

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

# Fixture: linjer med og uten skilletegn
printf 'a:b:c\nnodelim\nx:y:z\n' > "$tmp/mixed"

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"
# -s: hopp over linjer uten skilletegn
run_stretch "-s hopp over uten skille"  "$tmp/mixed" -d ':' -f 2 -s
# Åpne ranges
run_stretch "-c åpen range 3-"          "$tmp/chars" -c 3-
run_stretch "-c åpen range -3"          "$tmp/chars" -c -3
# --output-delimiter
run_stretch "--output-delimiter"        "$tmp/passwd" -d ':' -f 1,3 --output-delimiter='|'

echo ""
echo "Alle påkrevde tester bestått."
if [ "$stretch_fail" -ne 0 ]; then
  echo "STRETCH:  $stretch_fail valgfrie case ikke bestått ennå (greit — ikke påkrevd)"
else
  echo "STRETCH:  alle bestått"
fi
