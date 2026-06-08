#!/usr/bin/env bash
set -euo pipefail

# Golden-test for ls-implementasjon.
# CAND = kandidat-kommando, default "go run .".
# Referanse = systemets ekte ls.
# Deterministisk (navn/sortering): full diff for ls og ls -a.
# Ikke-deterministisk (modtid/eier i -l, lesbar størrelse i -h):
#   smoke-test -> sjekk at kommandoen kjører og gir riktig antall linjer.
# Sanity: ./test.sh ls skal gi PASS.
CAND="${1:-go run .}"
export LC_ALL=C

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Mappe-fixture med skjulte og synlige oppføringer.
d="$tmp/d"
mkdir -p "$d"
: >"$d/alpha"
: >"$d/beta"
: >"$d/.skjult"
mkdir -p "$d/zmappe"
# Litt innhold for størrelse i -l/-h.
head -c 2048 /dev/zero >"$d/stor" 2>/dev/null || dd if=/dev/zero of="$d/stor" bs=1 count=2048 2>/dev/null

fail=0
pass() { echo "PASS $1"; }
fail() { echo "FAIL $1"; fail=1; }

# Full diff: ls (kun synlige navn, sortert). ls uten -1 kan kolonne-formatere
# avhengig av om output er en terminal; her er begge sider rør, så ett navn per linje.
if diff <(eval "$CAND \"$d\"" 2>/dev/null | sort || true) \
        <(ls "$d" 2>/dev/null | sort || true) >/dev/null; then
  pass "ls"
else
  fail "ls"
fi

# Full diff: ls -a (inkluderer skjulte).
if diff <(eval "$CAND -a \"$d\"" 2>/dev/null | sort || true) \
        <(ls -a "$d" 2>/dev/null | sort || true) >/dev/null; then
  pass "-a"
else
  fail "-a"
fi

# Smoke-test -l: -l inkluderer modtid og eier som er vanskelig å matche eksakt.
# Sjekk i stedet at kommandoen kjører uten feil og at den lister minst alle
# synlige oppføringer. Ekte ls -l legger til en "total"-linje; din implementasjon
# trenger ikke gjøre det. Vi krever derfor minst like mange linjer som oppføringer.
visible=$(ls "$d" | wc -l)
got=$(eval "$CAND -l \"$d\"" 2>/dev/null | grep -c . || true)
if [ "$got" -ge "$visible" ]; then
  pass "-l (smoke)"
else
  fail "-l (smoke): forventet minst $visible linjer, fikk $got"
fi

# Smoke-test -h: lesbar størrelse, samme begrunnelse som -l.
got=$(eval "$CAND -lh \"$d\"" 2>/dev/null | grep -c . || true)
if [ "$got" -ge "$visible" ]; then
  pass "-h (smoke)"
else
  fail "-h (smoke): forventet minst $visible linjer, fikk $got"
fi

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Teller IKKE mot bestått/feilet — vises bare som
# STRETCH PASS/FAIL. For sorterings-flagg (-r/-t/-S) gir IKKE sortert diff
# mening (det ville skjule rekkefølgen vi tester) -> full diff uten sort.
stretch_fail=0
run_stretch() {
  local name="$1"; local args="$2"
  if diff <(eval "$CAND $args" 2>/dev/null || true) \
          <(eval "ls $args" 2>/dev/null || true) >/dev/null; then
    echo "STRETCH PASS $name"
  else
    echo "STRETCH FAIL $name  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi
}
stretch_skip() {
  echo "STRETCH SKIP $1  (ikke deterministisk: $2)"
}

# Egen fixture med distinkte størrelser og stigende modtid for -S/-t/-r.
s="$tmp/s"
mkdir -p "$s"
head -c 100  /dev/zero >"$s/liten"  2>/dev/null || dd if=/dev/zero of="$s/liten"  bs=1 count=100  2>/dev/null
head -c 5000 /dev/zero >"$s/stor"   2>/dev/null || dd if=/dev/zero of="$s/stor"   bs=1 count=5000 2>/dev/null
head -c 1000 /dev/zero >"$s/medium" 2>/dev/null || dd if=/dev/zero of="$s/medium" bs=1 count=1000 2>/dev/null
# Distinkte modtider (eldst -> nyest): liten, medium, stor.
touch -d '2020-01-01' "$s/liten"
touch -d '2021-01-01' "$s/medium"
touch -d '2022-01-01' "$s/stor"
# Rekursiv fixture.
r="$tmp/r"
mkdir -p "$r/under"
: >"$r/topp"
: >"$r/under/dyp"

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"
# -r: reversér navne-sortering (full diff uten sort -> rekkefølge testes).
run_stretch "-r reversert"   "-r \"$d\""
# -t: sorter etter modtid (distinkte modtider -> deterministisk rekkefølge).
run_stretch "-t modtid"      "-t \"$s\""
# -S: sorter etter størrelse (distinkte størrelser -> deterministisk).
run_stretch "-S storrelse"   "-S \"$s\""
# -tr: nyest sist (kombinasjon).
run_stretch "-tr modtid-rev" "-tr \"$s\""
# -R: rekursiv listing (ls -R-rekkefølge er deterministisk -> full diff).
run_stretch "-R rekursiv"    "-R \"$r\""
# Fargelegging: avhenger av --color/terminal -> ikke deterministisk.
stretch_skip "farge-ansi" "ANSI-fargekoder avhenger av --color/terminal"
# Eier/gruppe i -l: varierer med kjørende bruker/system -> ikke deterministisk.
stretch_skip "-l eier-gruppe" "eier/gruppe/modtid varierer med system og bruker"
# Kolonne-layout: avhenger av terminalbredde -> ikke deterministisk.
stretch_skip "kolonne-layout" "kolonne-bredde avhenger av terminalbredde (COLUMNS)"

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
