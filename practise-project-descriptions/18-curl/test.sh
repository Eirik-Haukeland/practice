#!/usr/bin/env bash
set -euo pipefail

# OPPFØRSELS-TEST. Antar IKKE nettverkstilgang.
# Starter en lokal HTTP-server og verifiserer at kandidaten henter innhold.
CAND="${1:-go run .}"

tmp=$(mktemp -d)
trap 'cleanup' EXIT

server_pid=""
cleanup() {
  [[ -n "$server_pid" ]] && kill "$server_pid" 2>/dev/null || true
  rm -rf "$tmp"
}

if ! command -v python3 >/dev/null 2>&1; then
  echo "SKIP curl-tester: python3 ikke tilgjengelig (kan ikke starte lokal server)"
  exit 0
fi

fail=0

# Lag fixtur og start server i temp-mappa på en tilfeldig ledig port.
echo "hei fra server" > "$tmp/fil.txt"

# Be OS-et velge en ledig port (port 0), og les den faktiske porten fra loggen.
port=""
serverlog="$tmp/server.log"
( cd "$tmp" && exec python3 -m http.server 0 ) > "$serverlog" 2>&1 &
server_pid=$!

# Vent på at serveren skriver "Serving HTTP on ... port NNNN".
for _ in $(seq 1 50); do
  if grep -qE 'port [0-9]+' "$serverlog" 2>/dev/null; then
    port=$(grep -oE 'port [0-9]+' "$serverlog" | head -n1 | grep -oE '[0-9]+')
    break
  fi
  sleep 0.1
done

if [[ -z "$port" ]]; then
  echo "SKIP curl-tester: klarte ikke starte lokal HTTP-server"
  exit 0
fi

url="http://127.0.0.1:$port/fil.txt"

# --- Test 1: GET til stdout ---
got=$($CAND "$url" 2>/dev/null || true)
if [[ "$got" == "hei fra server" ]]; then
  echo "PASS get-stdout"
else
  echo "FAIL get-stdout"
  echo "  got: $(printf '%q' "$got")"
  fail=1
fi

# --- Test 2: -o skriver til fil ---
$CAND -o "$tmp/ut.txt" "$url" >/dev/null 2>&1 || true
if [[ -f "$tmp/ut.txt" ]] && [[ "$(cat "$tmp/ut.txt")" == "hei fra server" ]]; then
  echo "PASS output-file"
else
  echo "FAIL output-file"
  echo "  innhold: $(cat "$tmp/ut.txt" 2>/dev/null || echo '<ingen fil>')"
  fail=1
fi

# --- Test 3: -i inkluderer responshodet ---
got=$($CAND -i "$url" 2>/dev/null || true)
if printf '%s' "$got" | grep -qiE 'HTTP/.* 200'; then
  echo "PASS include-headers"
else
  echo "FAIL include-headers"
  echo "  utdata: $(printf '%q' "$got")"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi
echo "ALL PASS"
