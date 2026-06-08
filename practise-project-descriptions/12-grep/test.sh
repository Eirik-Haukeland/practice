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

pass() { echo "PASS $1"; }
fail() { echo "FAIL $1"; exit 1; }

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

echo "Alle tester bestått."
