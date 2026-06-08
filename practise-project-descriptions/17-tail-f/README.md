# 17 — tail -f

## Hva det gjør
`tail` skriver ut de siste linjene av en fil. Med `-f` ("follow") fortsetter programmet å kjøre etter at filen er lest ut, og skriver fortløpende ut nye linjer som legges til filen — typisk for å overvåke loggfiler i sanntid. Programmet avsluttes med et avbruddssignal (Ctrl-C).

Dette er kjerneprosjektet for samtidighet: følging av en voksende fil håndteres naturlig med goroutines og kanaler.

| Flagg | Beskrivelse |
| ----- | ----------- |
| `-f` | Følg filen: vent på og skriv ut nye linjer etter hvert som de legges til. |
| `-n N` | Start med de siste N linjene (standard 10). |

## Go-læringsmål
- Samtidighet: start en goroutine som overvåker filen, og kommuniser nye linjer tilbake over en `chan string`.
- `select`-mønster: lytt samtidig på datakanalen og en avslutningskanal/`context.Context.Done()`.
- Ren avslutning: fang `SIGINT`/`SIGTERM` med `os/signal` (`signal.NotifyContext` er enklest), og la goroutinen avslutte når `ctx.Done()` lukkes.
- Følg filvekst ved å polle `os.Stat` på filstørrelsen, eller bruk `github.com/fsnotify/fsnotify` for hendelsesdrevet varsling.
- `os.File.Seek` for å hoppe til der du sist leste, og `bufio.Reader.ReadString('\n')` for å lese nye linjer.
- `time.Ticker` for jevn polling uten travel venting.

## Test-scenarioer
- `-n 3` på en fil med 5 linjer → skriv ut de siste 3 linjene og avslutt.
- `-f` på en fil → eksisterende sluttlinjer skrives ut, deretter blokkerer programmet og venter.
- `-f` + append: når nye linjer legges til filen mens programmet kjører, dukker de opp i utdata kort tid etter.
- Avslutning: Ctrl-C (SIGINT) stopper programmet rent uten å henge.
- Standard `-n`: uten `-n` skrives de siste 10 linjene ut.

## Stretch-mål
- Bytt polling-løsning ut med `fsnotify` for hendelsesdrevet følging.
- Håndter fil-truncation/rotasjon (filen krymper eller byttes ut) — oppdag at størrelsen ble mindre og start på nytt.
- Følg flere filer samtidig med en header `==> filnavn <==` per fil (én goroutine per fil, felles utskriftskanal).
- `-F` som tåler at filen ennå ikke finnes og venter på at den opprettes.

## Kjør testene
```
./test.sh "go run ."
```
Standard kandidatkommando er `go run .`. **Dette er en oppførsels-test, ikke en ren golden-diff** — sanntid og timing gjør eksakt diff upraktisk. Testen starter kandidaten i bakgrunnen mot en fixtur-fil, appender nye linjer med små forsinkelser, og verifiserer at de nye linjene dukker opp i utdata. Til slutt drepes prosessen. Testen bruker romslige `sleep`-marginer for å være robust mot timing.
