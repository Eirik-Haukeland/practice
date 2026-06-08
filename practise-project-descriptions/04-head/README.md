# 04 — head

## Hva det gjør
`head` skriver ut begynnelsen av en eller flere filer — som standard de 10 første linjene. Med flagg kan man velge antall linjer eller antall bytes. Ved flere filer skrives det ut en overskrift med filnavnet før hver fil. Verktøyet er en god øvelse i å bruke `flag`-pakken og i å lese kun en del av en strøm og stoppe tidlig.

| Flagg     | Beskrivelse |
| --------- | ----------- |
| `-n N`    | Skriv ut de N første linjene (standard 10) |
| `-c N`    | Skriv ut de N første bytene |

## Go-læringsmål
- `flag`-pakken — `flag.Int` for `-n` og `-c`, og `flag.Parse()` for å lese flagg.
- `flag.Args()` — hente de gjenværende filargumentene etter flaggene.
- `bufio.Scanner` — lese linjer og stoppe tidlig når N linjer er nådd (ikke les hele filen).
- Lese et fast antall bytes med `io.ReadFull` eller en buffer for `-c`.
- Skrive ut overskrift (`==> filnavn <==`) ved flere filargumenter.
- Feilhåndtering for filer som ikke finnes.

## Test-scenarioer
- Standard: `head < f` → skriver de 10 første linjene.
- `-n N`: `head -n 3 < f` → skriver kun de 3 første linjene.
- `-n` større enn antall linjer: `head -n 100 < f` → skriver hele filen uten feil.
- `-c N`: `head -c 5 < f` → skriver kun de 5 første bytene.
- Færre linjer enn standard: liten fil → skriver alle linjene uten feil.

## Stretch-mål
- Støtt `-n -N` (alle linjer unntatt de N siste).
- Implementer overskrifter (`==> navn <==`) og `-q` / `-v` for å styre dem.
- Støtt suffikser på `-c` (`-c 1K`, `-c 1M`).

## Kjør testene
`./test.sh "go run ."` — kandidat-kommandoen sendes inn som første argument (default `go run .`).
Testen kjører både din kandidat og systemets ekte `head` mot samme input og sammenligner utskriften med `diff`. Vi leser fra stdin (`< f`) for å unngå filnavn-overskrifter i output, slik at sammenligningen blir rettferdig. Får du `PASS` på alle case, oppfører verktøyet ditt seg likt det ekte.
