#!/usr/bin/env bash
set -euo pipefail

# Golden-test for grep-implementasjon.
# CAND = kandidat-kommando (din implementasjon), default "go run .".
# Referanse = systemets ekte grep.
# Sanity: ./test.sh grep skal gi PASS (referanse mot referanse).
CAND="${1:-go run .}"
export LC_ALL=C

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Fixture: tekstfil med blandet innhold.
cat >"$tmp/f" <<'EOF'
hei verden
Hei igjen
HEI ROP
ingen treff her
apple banana
banana split
slutt
EOF

# Fixture for rekursivt søk.
mkdir -p "$tmp/tre/under"
printf 'treff a\nikke\n' >"$tmp/tre/a.txt"
printf 'ingenting\ntreff b\n' >"$tmp/tre/under/b.txt"

fail=0
pass() { echo "PASS $1"; }
fail() { echo "FAIL $1"; fail=1; }

check() {
  local name="$1"; shift
  if diff <("$@" 2>/dev/null) /dev/stdin >/dev/null; then
    pass "$name"
  else
    fail "$name"
  fi
}

# Hjelper: kjør kandidat og referanse, diff resultatet.
run_diff() {
  local name="$1"; shift
  # Argumentene før '--' er kandidatens; vi gjenbruker samme for referansen.
  if diff <(eval "$CAND $1" 2>/dev/null || true) <(eval "grep $1" 2>/dev/null || true) >/dev/null; then
    pass "$name"
  else
    fail "$name"
  fi
}

# Basis: enkelt mønster fra fil.
run_diff "basis"   "verden \"$tmp/f\""
# -i: ignorer case.
run_diff "-i"      "-i hei \"$tmp/f\""
# -v: inverter.
run_diff "-v"      "-v banana \"$tmp/f\""
# -n: linjenummer.
run_diff "-n"      "-n banana \"$tmp/f\""
# -c: tell treff.
run_diff "-c"      "-c banana \"$tmp/f\""
# stdin: les fra standard input.
if diff <(eval "$CAND banana" <"$tmp/f" 2>/dev/null || true) \
        <(grep banana <"$tmp/f" 2>/dev/null || true) >/dev/null; then
  pass "stdin"
else
  fail "stdin"
fi
# -r: rekursivt søk (sorter pga. traverserings-rekkefølge).
if diff <(cd "$tmp" && eval "$CAND -r treff tre" 2>/dev/null | sort || true) \
        <(cd "$tmp" && grep -r treff tre 2>/dev/null | sort || true) >/dev/null; then
  pass "-r"
else
  fail "-r"
fi

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Teller IKKE mot bestått/feilet — vises bare som
# STRETCH PASS/FAIL. Samme golden-diff-metode som run_diff (kandidat vs ekte grep).
stretch_fail=0
run_stretch() {
  local name="$1"; shift
  if diff <(eval "$CAND $1" 2>/dev/null || true) <(eval "grep $1" 2>/dev/null || true) >/dev/null; then
    echo "STRETCH PASS $name"
  else
    echo "STRETCH FAIL $name  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi
}
stretch_skip() {
  echo "STRETCH SKIP $1  (ikke deterministisk: $2)"
}

# Andre fil for -l og fler-fil-prefiks (b inneholder ikke "banana").
cat >"$tmp/g" <<'EOF'
apple pie
ingen
EOF

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"
# -l: kun filnavn med minst ett treff (to filer, kun f matcher banana).
run_stretch "-l filnavn"        "-l banana \"$tmp/f\" \"$tmp/g\""
# -o: kun matchende del.
run_stretch "-o kun-treff"      "-o banana \"$tmp/f\""
# -w: kun hele ord (split skal matche som ord, splitter ikke).
run_stretch "-w hele-ord"       "-w banana \"$tmp/f\""
# -A: kontekst etter.
run_stretch "-A etter"          "-A 1 apple \"$tmp/f\""
# -B: kontekst før.
run_stretch "-B foer"           "-B 1 split \"$tmp/f\""
# -C: kontekst rundt.
run_stretch "-C rundt"          "-C 1 banana \"$tmp/f\""
# Flere filer -> filnavn-prefiks foran hver linje.
run_stretch "fler-fil-prefiks"  "apple \"$tmp/f\" \"$tmp/g\""
# Fargelegging: ANSI-koder avhenger av --color/terminal -> ikke deterministisk.
stretch_skip "farge-ansi" "ANSI-fargekoder avhenger av --color/terminal-deteksjon"

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
