# 02 — cat

## Hva det gjør
`cat` leser én eller flere filer og skriver innholdet sammenhengende til standard ut. Uten filargumenter leser den fra standard inn. Verktøyet er en god øvelse i fil-I/O, strømming av data og feilhåndtering når en fil ikke finnes. Med flagg kan utskriften nummereres eller markeres ved linjeslutt.

| Flagg | Beskrivelse |
| ----- | ----------- |
| `-n`  | Nummerer alle utskrevne linjer |
| `-E`  | Vis `$` på slutten av hver linje |

## Go-læringsmål
- `os.Open` — åpne en fil for lesing, og returverdien `(*os.File, error)`.
- `defer file.Close()` — sørge for at filer lukkes uansett hvordan funksjonen avsluttes.
- `io.Copy` — strømme data fra fil til `os.Stdout` uten å lese alt inn i minnet.
- `os.Stdin` — lese fra standard inn når ingen filargumenter er gitt.
- Håndtere flere filargumenter i en løkke.
- Feilhåndtering: rapportere til `os.Stderr` og sette exit-kode når en fil ikke finnes.
- `bufio.Scanner` for linjebasert lesing når flaggene `-n` eller `-E` krever det.

## Test-scenarioer
- Én fil: `cat f` → skriver hele innholdet i filen.
- Flere filer: `cat a b` → skriver innholdet i `a` etterfulgt av `b`.
- Stdin: `cat < f` → leser fra standard inn når ingen filargument er gitt.
- `-n`: `cat -n f` → hver linje nummereres med høyrejustert nummer.
- `-E`: `cat -E f` → `$` legges til på slutten av hver linje.
- Fil finnes ikke: `cat finnesikke` → feilmelding til stderr og exit-kode ulik 0.

## Stretch-mål
- Støtt `-` som filnavn for å lese fra stdin midt i en filliste.
- Implementer `-b` (nummerer kun ikke-tomme linjer).
- Implementer `-s` (komprimer flere tomme linjer til én).
- Implementer `-T` (vis tabulatorer som `^I`).

## Kjør testene
`./test.sh "go run ."` — kandidat-kommandoen sendes inn som første argument (default `go run .`).
Testen kjører både din kandidat og systemets ekte `cat` mot samme input og sammenligner utskriften med `diff`. Får du `PASS` på alle case, oppfører verktøyet ditt seg likt det ekte.
