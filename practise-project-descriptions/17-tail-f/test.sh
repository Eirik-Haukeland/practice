#!/usr/bin/env bash
set -euo pipefail

# OPPFØRSELS-TEST (ikke ren golden-diff).
# tail -f er sanntids/timing-avhengig, så vi tester funksjonelt:
# start kandidaten i bakgrunnen, append linjer med forsinkelse,
# og sjekk at de nye linjene dukker opp i utdata.
CAND="${1:-go run .}"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail=0

# --- Test 1: -n N (statisk, kan diffes) ---
log="$tmp/static.log"
printf 'l1\nl2\nl3\nl4\nl5\n' > "$log"
got=$($CAND -n 3 "$log" 2>/dev/null || true)
want=$'l3\nl4\nl5'
if [[ "$got" == "$want" ]]; then
  echo "PASS n3-static"
else
  echo "FAIL n3-static"
  echo "  got:  $(printf '%q' "$got")"
  echo "  want: $(printf '%q' "$want")"
  fail=1
fi

# --- Test 2: -f følger nye linjer (oppførsels-test) ---
flog="$tmp/follow.log"
out="$tmp/follow.out"
printf 'start\n' > "$flog"

# Start kandidaten i bakgrunnen; samle stdout i en fil.
$CAND -f "$flog" > "$out" 2>/dev/null &
pid=$!

# Gi programmet tid til å starte og lese eksisterende innhold.
sleep 1.5

# Append nye linjer med forsinkelse.
printf 'appended-1\n' >> "$flog"
sleep 1
printf 'appended-2\n' >> "$flog"
sleep 1.5

# Drep kandidaten rent.
kill "$pid" 2>/dev/null || true
wait "$pid" 2>/dev/null || true

if grep -q 'appended-1' "$out" && grep -q 'appended-2' "$out"; then
  echo "PASS follow-appends"
else
  echo "FAIL follow-appends"
  echo "  utdata var:"
  sed 's/^/    /' "$out" || true
  fail=1
fi

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Teller IKKE mot bestått/feilet — vises kun som
# STRETCH PASS/FAIL. Oppførsels-baserte (samme stil som -f-casen over):
# start kandidaten i bakgrunnen, manipuler filer, sjekk utdata.
stretch_fail=0

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"

# fsnotify er en intern impl-detalj (polling vs. hendelsesdrevet) som ikke er
# eksternt observerbar — kan ikke testes deterministisk via stdout.
echo "STRETCH SKIP fsnotify-backend  (intern impl-detalj, ikke eksternt observerbar)"

# Stretch 1: truncation/rotasjon — filen krymper, så vokser igjen.
tlog="$tmp/trunc.log"
tout="$tmp/trunc.out"
printf 'gammel-1\ngammel-2\n' > "$tlog"
$CAND -f "$tlog" > "$tout" 2>/dev/null &
tpid=$!
sleep 1.5
: > "$tlog"            # truncate
sleep 0.5
printf 'etter-trunc\n' >> "$tlog"
sleep 1.5
kill "$tpid" 2>/dev/null || true
wait "$tpid" 2>/dev/null || true
if grep -q 'etter-trunc' "$tout"; then
  echo "STRETCH PASS truncation"
else
  echo "STRETCH FAIL truncation  (valgfritt)"
  stretch_fail=$((stretch_fail + 1))
fi

# Stretch 2: følg flere filer med "==> filnavn <==" header per fil.
flog1="$tmp/multi1.log"; flog2="$tmp/multi2.log"
mout="$tmp/multi.out"
printf 'fil1-start\n' > "$flog1"
printf 'fil2-start\n' > "$flog2"
$CAND -f "$flog1" "$flog2" > "$mout" 2>/dev/null &
mpid=$!
sleep 1.5
printf 'fil1-ny\n' >> "$flog1"
printf 'fil2-ny\n' >> "$flog2"
sleep 1.5
kill "$mpid" 2>/dev/null || true
wait "$mpid" 2>/dev/null || true
if grep -q 'fil1-ny' "$mout" && grep -q 'fil2-ny' "$mout" \
   && grep -qE '==>.*multi1\.log.*<==' "$mout" \
   && grep -qE '==>.*multi2\.log.*<==' "$mout"; then
  echo "STRETCH PASS multi-file-header"
else
  echo "STRETCH FAIL multi-file-header  (valgfritt)"
  stretch_fail=$((stretch_fail + 1))
fi

# Stretch 3: -F tåler at filen ennå ikke finnes og venter på opprettelse.
Flog="$tmp/late.log"   # finnes ikke ennå
Fout="$tmp/late.out"
$CAND -F "$Flog" > "$Fout" 2>/dev/null &
Fpid=$!
sleep 1.5
printf 'opprettet-senere\n' > "$Flog"
sleep 1.5
kill "$Fpid" 2>/dev/null || true
wait "$Fpid" 2>/dev/null || true
if grep -q 'opprettet-senere' "$Fout"; then
  echo "STRETCH PASS F-wait-for-create"
else
  echo "STRETCH FAIL F-wait-for-create  (valgfritt)"
  stretch_fail=$((stretch_fail + 1))
fi

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi
echo "ALL PASS"
if [[ "$stretch_fail" -ne 0 ]]; then
  echo "STRETCH:  $stretch_fail valgfrie case ikke bestått ennå (greit — ikke påkrevd)"
else
  echo "STRETCH:  alle bestått"
fi
