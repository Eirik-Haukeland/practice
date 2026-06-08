# 03 — wc

## Hva det gjør
`wc` (word count) teller linjer, ord, bytes og tegn i inndata. Uten flagg skriver den ut antall linjer, ord og bytes i den rekkefølgen. Med flagg kan man velge nøyaktig hvilke tellinger som vises. Verktøyet er en god øvelse i å lese inndata linje for linje og i forskjellen mellom bytes og runer (tegn) i UTF-8.

| Flagg | Beskrivelse |
| ----- | ----------- |
| `-l`  | Tell linjer |
| `-w`  | Tell ord (sekvenser adskilt av blanktegn) |
| `-c`  | Tell bytes |
| `-m`  | Tell tegn (runer) |

## Go-læringsmål
- `bufio.Scanner` — lese inndata effektivt, linje for linje eller ord for ord (`scanner.Split(bufio.ScanWords)`).
- Telle linjer, ord og bytes ved å akkumulere underveis.
- `utf8.RuneCountInString` — telle runer (tegn) i motsetning til bytes, viktig for UTF-8.
- Forskjellen mellom `byte` og `rune` i Go.
- Bygge opp standard-output (linjer, ord, bytes) i riktig rekkefølge når ingen flagg er gitt.

## Test-scenarioer
- Standard (ingen flagg): `wc < f` → skriver `linjer ord bytes` på én linje.
- `-l`: `wc -l < f` → skriver kun antall linjer.
- `-w`: `wc -w < f` → skriver kun antall ord.
- `-c`: `wc -c < f` → skriver kun antall bytes.
- `-m`: `wc -m < f` → skriver antall tegn; for UTF-8-tekst skal dette avvike fra `-c`.
- Tom input: `wc < tomfil` → alle tellinger er 0.

## Stretch-mål
- Implementer `-L` (lengden på den lengste linjen).
- Støtt flere filargumenter med en totalrad til slutt.
- Riktig kolonnejustering/padding som GNU `wc`.

## Kjør testene
`./test.sh "go run ."` — kandidat-kommandoen sendes inn som første argument (default `go run .`).
Testen kjører både din kandidat og systemets ekte `wc` mot samme input og sammenligner utskriften med `diff`.
GNU `wc` justerer tallene med variabelt antall mellomrom (padding). Testen normaliserer derfor begge sider med `tr -s ' '` og fjerner ledende/etterfølgende blanktegn, slik at sammenligningen blir rettferdig. Vi leser fra stdin (`< f`) for å unngå at filnavn-kolonnen havner i output.
