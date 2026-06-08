# 18 — curl (mini)

## Hva det gjør
`curl` overfører data til og fra en server med en URL. I denne mini-versjonen utfører du HTTP-forespørsler, sender valgfri metode, headere og body, og strømmer responskroppen til standard output (eller til en fil). Som standard utføres en `GET`-forespørsel og kroppen skrives til stdout.

| Flagg | Beskrivelse |
| ----- | ----------- |
| `-X METODE` | Sett HTTP-metode (GET, POST, PUT, DELETE, …). |
| `-H "Navn: Verdi"` | Legg til en forespørsels-header. Kan gjentas flere ganger. |
| `-d DATA` | Send DATA som request-body (impliserer `POST` hvis `-X` ikke er satt). |
| `-o FIL` | Skriv responskroppen til FIL i stedet for stdout. |
| `-i` | Inkluder responsens statuslinje og headere i utdata. |

## Go-læringsmål
- `net/http`: bygg forespørsel med `http.NewRequest(metode, url, body)`, og utfør med en `*http.Client` via `client.Do(req)`.
- Sett headere på forespørselen med `req.Header.Set` / `req.Header.Add` (gjentatt `-H`).
- Send body fra `-d` ved å pakke strengen i en `strings.NewReader`.
- Strøm responskroppen effektivt med `io.Copy(dst, resp.Body)` i stedet for å lese alt i minnet.
- Skriv til `os.Stdout` eller en `*os.File` opprettet med `os.Create` (`-o`).
- Husk å `defer resp.Body.Close()`; skriv ut `resp.Status` og iterer over `resp.Header` for `-i`.

## Test-scenarioer
- GET (standard): `curl http://localhost:PORT/fil.txt` → skriver filinnholdet til stdout.
- `-o`: `curl -o ut.txt http://localhost:PORT/fil.txt` → lagrer kroppen i `ut.txt`.
- `-i`: `curl -i http://localhost:PORT/fil.txt` → utdata starter med `HTTP/1.1 200 OK` og headere før kroppen.
- `-H`: `curl -H "Accept: text/plain" URL` → forespørselen sendes med den headeren (verifiser mot en server som ekkoer headere).
- `-X` + `-d`: `curl -X POST -d "hei" URL` → sender en POST med body `hei`.

## Stretch-mål
- `-L` for å følge omdirigeringer (3xx + `Location`).
- `-s` (silent) og en fremdriftsindikator/`-#`.
- `-u bruker:passord` for Basic Auth.
- Les `-d @fil` for å sende filinnhold som body, og `--data-urlencode`.
- Sett fornuftig `User-Agent` og støtt `-A` for å overstyre den.

## Kjør testene
```
./test.sh "go run ."
```
Standard kandidatkommando er `go run .`. **Dette er en oppførsels-test og antar ikke nettverkstilgang.** Testen starter en lokal HTTP-server (`python3 -m http.server`) på en ledig port i en temp-mappe og verifiserer at kandidaten henter innholdet (GET, `-o`, `-i`). Finnes ikke `python3`, hopper testen grasiøst over med en melding (SKIP, ikke FAIL).
