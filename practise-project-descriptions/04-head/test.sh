#!/usr/bin/env bash
set -euo pipefail

# Golden-test for head. Sammenligner kandidat mot systemets ekte head via diff.
# Bruk: ./test.sh "go run ."   (default: go run .)
# Sanity: ./test.sh head  -> skal gi PASS på alle case.
CAND="${1:-go run .}"
REF="head"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# 20 nummererte linjer slik at standard (10) og -n 3 gir ulik output.
for i in $(seq 1 20); do printf 'linje %02d\n' "$i"; done > "$tmp/f"
printf 'kort en\nkort to\n' > "$tmp/liten"

fail=0

# Vi leser fra stdin (< f) slik at head ikke skriver filnavn-overskrifter.
cmp_case() {
  local name="$1"; local flags="$2"; local file="$3"
  if diff \
      <(eval "$CAND $flags < $file") \
      <(eval "$REF $flags < $file") >/dev/null; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    fail=1
  fi
}

cmp_case "default"      ""        "$tmp/f"
cmp_case "lines-3"      "-n 3"    "$tmp/f"
cmp_case "lines-over"   "-n 100"  "$tmp/f"
cmp_case "bytes-5"      "-c 5"    "$tmp/f"
cmp_case "fewer-lines"  ""        "$tmp/liten"

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Disse teller IKKE mot bestått/feilet — de vises bare
# som STRETCH PASS/FAIL slik at du ser hva som gjenstår av ekstra-funksjonalitet.
stretch_fail=0
# Golden-stretch via stdin, samme mønster som cmp_case.
run_stretch() {
  local name="$1"; local flags="$2"; local file="$3"
  if diff \
      <(eval "$CAND $flags < $file" 2>/dev/null) \
      <(eval "$REF $flags < $file" 2>/dev/null) >/dev/null 2>&1; then
    echo "STRETCH PASS $name"
  else
    echo "STRETCH FAIL $name  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi
}
# Overskrifter (==> navn <==) trenger filargumenter, ikke stdin.
run_stretch_files() {
  local name="$1"; local flags="$2"; shift 2
  if diff \
      <(eval "$CAND $flags $*" 2>/dev/null) \
      <(eval "$REF $flags $*" 2>/dev/null) >/dev/null 2>&1; then
    echo "STRETCH PASS $name"
  else
    echo "STRETCH FAIL $name  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi
}

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"
# -n -N: alle linjer unntatt de N siste
run_stretch "lines-except-last" "-n -5" "$tmp/f"
# Overskrifter ved flere filer (standard) og -v (tving overskrift) / -q (skjul)
run_stretch_files "headers-multi"  ""    "$tmp/f" "$tmp/liten"
run_stretch_files "verbose-header" "-v"  "$tmp/liten"
run_stretch_files "quiet-headers"  "-q"  "$tmp/f" "$tmp/liten"
# Suffiks på -c: 1K = 1024 byte
run_stretch "bytes-suffix-K" "-c 1K" "$tmp/f"

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
