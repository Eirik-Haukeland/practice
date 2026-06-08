#!/usr/bin/env bash
set -euo pipefail

# Golden-test for wc. Sammenligner kandidat mot systemets ekte wc via diff.
# Bruk: ./test.sh "go run ."   (default: go run .)
# Sanity: ./test.sh wc  -> skal gi PASS på alle case.
CAND="${1:-go run .}"
REF="wc"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

printf 'hei verden\nandre linje\ntredje linje her\n' > "$tmp/f"
printf 'blåbær og rødgrøt\næøå\n'                     > "$tmp/utf8"
printf ''                                            > "$tmp/tom"

fail=0

# GNU wc bruker variabel padding/whitespace. Vi normaliserer begge sider:
# tr -s ' ' kollapser gjentatte mellomrom, og sed trimmer ledende/etterflgende.
norm() { tr -s ' ' | sed -e 's/^ *//' -e 's/ *$//'; }

# Vi leser fra stdin (< f) slik at filnavn-kolonnen ikke havner i output.
cmp_case() {
  local name="$1"; local flags="$2"; local file="$3"
  if diff \
      <(eval "$CAND $flags < $file" | norm) \
      <(eval "$REF $flags < $file"  | norm) >/dev/null; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    fail=1
  fi
}

cmp_case "default"   ""    "$tmp/f"
cmp_case "lines"     "-l"  "$tmp/f"
cmp_case "words"     "-w"  "$tmp/f"
cmp_case "bytes"     "-c"  "$tmp/f"
cmp_case "chars"     "-m"  "$tmp/utf8"
cmp_case "bytes-utf8" "-c" "$tmp/utf8"
cmp_case "empty"     ""    "$tmp/tom"

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Disse teller IKKE mot bestått/feilet — de vises bare
# som STRETCH PASS/FAIL slik at du ser hva som gjenstår av ekstra-funksjonalitet.
# Gjenbruker samme norm() / stdin-mønster som de påkrevde casene.
stretch_fail=0
# Golden-stretch: les fra stdin (< f) og normaliser begge sider, som cmp_case.
run_stretch() {
  local name="$1"; local flags="$2"; local file="$3"
  if diff \
      <(eval "$CAND $flags < $file" | norm) \
      <(eval "$REF $flags < $file"  | norm) >/dev/null 2>&1; then
    echo "STRETCH PASS $name"
  else
    echo "STRETCH FAIL $name  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi
}
# Multi-fil med totalrad: filargumenter direkte (totalrad skrives av begge).
run_stretch_files() {
  local name="$1"; local flags="$2"; shift 2
  if diff \
      <(eval "$CAND $flags $*" | norm) \
      <(eval "$REF $flags $*"  | norm) >/dev/null 2>&1; then
    echo "STRETCH PASS $name"
  else
    echo "STRETCH FAIL $name  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi
}

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"
# -L: lengden på den lengste linjen
run_stretch "max-line-length" "-L" "$tmp/f"
# Flere filargumenter med en totalrad til slutt
run_stretch_files "multi-file-total" "" "$tmp/f" "$tmp/utf8"
# Riktig kolonnejustering/padding: testen normaliserer bort padding (tr -s ' '),
# så dette kan ikke golden-testes deterministisk her.
echo "STRETCH SKIP padding-alignment  (ikke deterministisk: norm() kollapser padding bort)"

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
