#!/usr/bin/env bash
set -euo pipefail

# Golden-test for find-implementasjon.
# CAND = kandidat-kommando, default "go run .".
# Referanse = systemets ekte find.
# find garanterer ikke rekkefølge -> sorter begge sider før diff.
# Bruk relative stier ved å cd inn i fixture-mappen.
# Sanity: ./test.sh find skal gi PASS.
CAND="${1:-go run .}"
export LC_ALL=C

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Katalogtre-fixture.
mkdir -p "$tmp/root/sub/deep"
mkdir -p "$tmp/root/empty"
: >"$tmp/root/a.txt"
: >"$tmp/root/b.go"
: >"$tmp/root/sub/c.txt"
: >"$tmp/root/sub/deep/d.go"

pass() { echo "PASS $1"; }
fail() { echo "FAIL $1"; exit 1; }

# Sammenlign kandidat og referanse, sortert, med relative stier fra $tmp.
run_diff() {
  local name="$1"; local args="$2"
  if diff <(cd "$tmp" && eval "$CAND $args" 2>/dev/null | sort || true) \
          <(cd "$tmp" && eval "find $args" 2>/dev/null | sort || true) >/dev/null; then
    pass "$name"
  else
    fail "$name"
  fi
}

# Basis: hele treet.
run_diff "basis"          "root"
# -name: glob mot filnavn.
run_diff "-name"          "root -name '*.txt'"
# -type f: kun filer.
run_diff "-type f"        "root -type f"
# -type d: kun mapper.
run_diff "-type d"        "root -type d"
# Kombinert: filer med .go-endelse.
run_diff "-type f -name"  "root -type f -name '*.go'"

echo "Alle tester bestått."
