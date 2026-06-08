#!/usr/bin/env bash
# Oppførsels-test for cd (ikke ren golden-diff: ekte cd er en shell-builtin uten stdout).
# Kandidaten forventes å skrive den oppløste mål-mappa til stdout.
# Referanse beregnes med (cd <arg> && pwd) i en subshell.
set -euo pipefail
CAND="${1:-go run .}"

# Kanoniser temp-mappa først, så symlenker (f.eks. /tmp -> /private/tmp) ikke gir falske avvik.
tmp=$(cd "$(mktemp -d)" && pwd)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/sub"

fail=0
check() { # check <navn> <forventet> <faktisk>
  if [ "$2" = "$3" ]; then echo "PASS $1"; else
    echo "FAIL $1"; echo "  forventet: $2"; echo "  faktisk:   $3"; fail=1
  fi
}

# Absolutt mappe
check absolutt "$tmp/sub" "$($CAND "$tmp/sub")"

# Relativ mappe (kjør med cwd = $tmp)
check relativ "$tmp/sub" "$(cd "$tmp" && $CAND sub)"

# Ingen argument -> $HOME
check no-arg "$tmp" "$(HOME="$tmp" $CAND)"

# Forrige mappe (-) -> $OLDPWD
check oldpwd "$tmp/sub" "$(OLDPWD="$tmp/sub" $CAND -)"

# Tilde-ekspansjon
check tilde "$tmp/sub" "$(HOME="$tmp" $CAND '~/sub')"

# Feil: ikke-eksisterende mappe -> ingen stdout, exit-kode != 0
if out=$($CAND "$tmp/finnes-ikke" 2>/dev/null); then
  echo "FAIL feil-exit (forventet exit != 0)"; fail=1
elif [ -n "$out" ]; then
  echo "FAIL feil-stdout (forventet tom stdout, fikk: $out)"; fail=1
else
  echo "PASS feil"
fi

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Teller IKKE mot bestått/feilet — vises kun som
# STRETCH PASS/FAIL. Samme check-mekanisme som de påkrevde casene
# (sammenlign kandidatens stdout mot en referanse beregnet i bash).
stretch_fail=0
check_stretch() { # check_stretch <navn> <forventet> <faktisk>
  if [ "$2" = "$3" ]; then
    echo "STRETCH PASS $1"
  else
    echo "STRETCH FAIL $1  (valgfritt)"
    echo "  forventet: $2"
    echo "  faktisk:   $3"
    stretch_fail=$((stretch_fail + 1))
  fi
}

echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"

# Symlenke for -P/-L-testene: link -> sub
ln -s "$tmp/sub" "$tmp/link"

# Stretch 1: cd - skal skrive ut mappa den byttet til (gjør det samme som
# ekte `cd -`, som ekko-er målmappa). Referanse: OLDPWD selv.
check_stretch "dash-prints-dir" "$tmp/sub" "$(OLDPWD="$tmp/sub" $CAND -)"

# Stretch 2: -P (fysisk sti) — løs opp symlenker.
# Referanse: (cd -P link && pwd -P).
want_P=$(cd "$tmp/link" && pwd -P)
check_stretch "physical-P" "$want_P" "$($CAND -P "$tmp/link")"

# Stretch 3: -L (logisk sti) — behold symlenke-stien.
check_stretch "logical-L" "$tmp/link" "$($CAND -L "$tmp/link")"

# Stretch 4: CDPATH — finn relativt mål via mappene i $CDPATH.
mkdir -p "$tmp/base/target"
want_cdpath=$(cd "$tmp/base/target" && pwd)
check_stretch "cdpath" "$want_cdpath" "$(cd "$tmp" && CDPATH="$tmp/base" $CAND target)"

if [ $fail -ne 0 ]; then
  exit 1
fi
echo "ALLE TESTER PASS"
if [ "$stretch_fail" -ne 0 ]; then
  echo "STRETCH:  $stretch_fail valgfrie case ikke bestått ennå (greit — ikke påkrevd)"
else
  echo "STRETCH:  alle bestått"
fi
