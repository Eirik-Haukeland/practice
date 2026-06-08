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

fail=0
pass() { echo "PASS $1"; }
fail() { echo "FAIL $1"; fail=1; }

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

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Teller IKKE mot bestått/feilet — vises bare som
# STRETCH PASS/FAIL. Samme metode som run_diff: sortert, relative stier fra $tmp.
stretch_fail=0
run_stretch() {
  local name="$1"; local args="$2"
  if diff <(cd "$tmp" && eval "$CAND $args" 2>/dev/null | sort || true) \
          <(cd "$tmp" && eval "find $args" 2>/dev/null | sort || true) >/dev/null; then
    echo "STRETCH PASS $name"
  else
    echo "STRETCH FAIL $name  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi
}

# Ekstra fixture for -iname (blandet case) og -size (kjent størrelse).
: >"$tmp/root/UPPER.TXT"
head -c 2048 /dev/zero >"$tmp/root/big.bin" 2>/dev/null || dd if=/dev/zero of="$tmp/root/big.bin" bs=1 count=2048 2>/dev/null
# Andre start-sti for fler-sti-test.
mkdir -p "$tmp/root2"
: >"$tmp/root2/e.txt"

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"
# -iname: case-insensitivt navne-mønster.
run_stretch "-iname"          "root -iname '*.txt'"
# -maxdepth: begrens dybde.
run_stretch "-maxdepth 1"     "root -maxdepth 1"
# -size: filer over en grense (big.bin = 2048 byte = 4 blokker -> +1k matcher).
run_stretch "-size +1k"       "root -type f -size +1k"
# -mtime: endret de siste N dager (alt nylig laget -> -mtime -1 matcher alt).
run_stretch "-mtime -1"       "root -type f -mtime -1"
# -exec: kjør kommando per treff (echo er deterministisk; sorteres uansett).
run_stretch "-exec echo"      "root -type f -name '*.go' -exec echo {} ;"
# Flere start-stier.
run_stretch "fler-sti"        "root root2 -type f -name '*.txt'"

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
