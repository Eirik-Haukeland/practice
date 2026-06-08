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

[ $fail -eq 0 ] || exit 1
echo "ALLE TESTER PASS"
