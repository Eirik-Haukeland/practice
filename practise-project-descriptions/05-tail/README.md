# 05 — tail

## Hva det gjør
`tail` skriver ut slutten av en eller flere filer — som standard de 10 siste linjene. Med flagg kan man velge antall linjer eller antall bytes. I motsetning til `head` må `tail` ofte lese hele inndata før den vet hva slutten er, særlig fra standard inn der filslutten ikke er kjent på forhånd. En ring-buffer er en elegant måte å holde kun de N siste linjene på.

| Flagg     | Beskrivelse |
| --------- | ----------- |
| `-n N`    | Skriv ut de N siste linjene (standard 10) |
| `-c N`    | Skriv ut de N siste bytene |

## Go-læringsmål
- Ring-buffer / sirkulær buffer — lagre kun de N siste linjene mens man strømmer gjennom inndata (man kan ikke vite filslutt på forhånd ved stdin).
- `flag`-pakken — `flag.Int` for `-n` og `-c`.
- `bufio.Scanner` — lese inndata linje for linje.
- Indeksregning med modulo (`%`) for å skrive over eldste element i bufferen.
- For `-c`: holde de N siste bytene, f.eks. i en byte-slice.
- Feilhåndtering for filer som ikke finnes.

## Test-scenarioer
- Standard: `tail < f` → skriver de 10 siste linjene.
- `-n N`: `tail -n 3 < f` → skriver kun de 3 siste linjene.
- `-n` større enn antall linjer: `tail -n 100 < f` → skriver hele filen uten feil.
- `-c N`: `tail -c 5 < f` → skriver kun de 5 siste bytene.
- Færre linjer enn standard: liten fil → skriver alle linjene uten feil.

## Stretch-mål
- Støtt `-n +N` (start utskrift fra linje N i stedet for fra slutten).
- Implementer overskrifter (`==> navn <==`) ved flere filer.
- (`tail -f` — følg filen mens den vokser — kommer i et senere prosjekt og er ikke med her.)

## Kjør testene
`./test.sh "go run ."` — kandidat-kommandoen sendes inn som første argument (default `go run .`).
Testen kjører både din kandidat og systemets ekte `tail` mot samme input og sammenligner utskriften med `diff`. Vi leser fra stdin (`< f`) for å unngå filnavn-overskrifter i output, slik at sammenligningen blir rettferdig. Får du `PASS` på alle case, oppfører verktøyet ditt seg likt det ekte.
