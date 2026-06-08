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
# -u: ubufret stdio så "Serving HTTP on ... port NNNN" dukker opp med en gang
# (Python 3.14 bufrer ellers stderr ved omdirigering).
( cd "$tmp" && exec python3 -u -m http.server 0 ) > "$serverlog" 2>&1 &
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

# --- STRETCH-MÅL ---------------------------------------------------------
# Valgfrie mål fra README. Teller IKKE mot bestått/feilet — vises kun som
# STRETCH PASS/FAIL. Oppførsels-baserte (samme stil som de påkrevde casene):
# starter en liten ekko/redirect/auth-server og verifiserer kandidatens utdata.
stretch_fail=0
echo ""
echo "--- STRETCH-MÅL (valgfritt — påvirker ikke om testen består) ---"

# -s (silent): ren GET skal fortsatt gi body på stdout (ingen ekstra støy der).
got=$($CAND -s "$url" 2>/dev/null || true)
if [[ "$got" == "hei fra server" ]]; then
  echo "STRETCH PASS silent-get"
else
  echo "STRETCH FAIL silent-get  (valgfritt)"
  stretch_fail=$((stretch_fail + 1))
fi

# Resten krever en server som ekko-er headere, gjør redirect og krever auth.
# python3 -m http.server kan ingen av delene, så vi starter en liten egen.
# Liten ekko/redirect/auth-server som skriver porten den binder seg til, til stdout.
helper="$tmp/srv.py"
cat > "$helper" <<'PY'
import base64
from http.server import BaseHTTPRequestHandler, HTTPServer

class H(BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def _send(self, code, body=b"", headers=None):
        self.send_response(code)
        for k, v in (headers or {}).items():
            self.send_header(k, v)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)
    def do_GET(self):
        if self.path == "/redirect":
            self._send(302, headers={"Location": "/final"}); return
        if self.path == "/final":
            self._send(200, b"omdirigert-ok"); return
        if self.path == "/agent":
            self._send(200, ("UA=" + self.headers.get("User-Agent", "")).encode()); return
        if self.path == "/secret":
            want = "Basic " + base64.b64encode(b"bruker:passord").decode()
            if self.headers.get("Authorization", "") == want:
                self._send(200, b"auth-ok")
            else:
                self._send(401, b"nei", {"WWW-Authenticate": "Basic"})
            return
        self._send(404, b"nope")
    def do_POST(self):
        n = int(self.headers.get("Content-Length", 0))
        self._send(200, b"BODY=" + self.rfile.read(n))

srv = HTTPServer(("127.0.0.1", 0), H)
print(srv.server_address[1], flush=True)
srv.serve_forever()
PY

helperlog="$tmp/helper.log"
python3 "$helper" > "$helperlog" 2>&1 &
helper_pid=$!
hport=""
for _ in $(seq 1 50); do
  hport=$(head -n1 "$helperlog" 2>/dev/null | grep -oE '^[0-9]+' || true)
  [[ -n "$hport" ]] && break
  sleep 0.1
done

if [[ -z "$hport" ]]; then
  echo "STRETCH SKIP redirect       (klarte ikke starte ekko-server)"
  echo "STRETCH SKIP user-agent     (klarte ikke starte ekko-server)"
  echo "STRETCH SKIP basic-auth     (klarte ikke starte ekko-server)"
  echo "STRETCH SKIP data-from-file (klarte ikke starte ekko-server)"
else
  base="http://127.0.0.1:$hport"

  # -L: følg omdirigeringer
  got=$($CAND -L "$base/redirect" 2>/dev/null || true)
  if [[ "$got" == "omdirigert-ok" ]]; then
    echo "STRETCH PASS redirect"
  else
    echo "STRETCH FAIL redirect  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi

  # -A: overstyr User-Agent
  got=$($CAND -A "min-agent/9" "$base/agent" 2>/dev/null || true)
  if [[ "$got" == "UA=min-agent/9" ]]; then
    echo "STRETCH PASS user-agent"
  else
    echo "STRETCH FAIL user-agent  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi

  # -u bruker:passord: Basic Auth
  got=$($CAND -u "bruker:passord" "$base/secret" 2>/dev/null || true)
  if [[ "$got" == "auth-ok" ]]; then
    echo "STRETCH PASS basic-auth"
  else
    echo "STRETCH FAIL basic-auth  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi

  # -d @fil: send filinnhold som body
  printf 'fra-fil' > "$tmp/body.txt"
  got=$($CAND -d "@$tmp/body.txt" "$base/echo" 2>/dev/null || true)
  if [[ "$got" == "BODY=fra-fil" ]]; then
    echo "STRETCH PASS data-from-file"
  else
    echo "STRETCH FAIL data-from-file  (valgfritt)"
    stretch_fail=$((stretch_fail + 1))
  fi
fi
kill "$helper_pid" 2>/dev/null || true

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi
echo "ALL PASS"
if [[ "$stretch_fail" -ne 0 ]]; then
  echo "STRETCH:  $stretch_fail valgfrie case ikke bestått ennå (greit — ikke påkrevd)"
else
  echo "STRETCH:  alle bestått"
fi
