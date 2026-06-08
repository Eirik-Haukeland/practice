# 08 — tr

## Hva det gjør
`tr` (translate) leser fra stdin, transformerer tegn, og skriver til stdout. I grunnformen mapper det hvert tegn i sett 1 til det tilsvarende tegnet i sett 2 (f.eks. `tr 'a-z' 'A-Z'` gjør om til store bokstaver). Med flagg kan det også slette eller komprimere tegn.

| Flagg | Beskrivelse |
| --- | --- |
| (ingen) | Oversett tegn i SET1 til tilsvarende tegn i SET2. |
| `-d` | Slett alle tegn som finnes i SET1. |
| `-s` | Komprimer (squeeze) gjentatte forekomster av tegn i SET1 til ett. |
| `-c` | Komplement: opererer på tegn som *ikke* er i SET1. |

## Go-læringsmål
Dette verktøyet trener arbeid med runer og mapping:

- Lesing av rå input fra `os.Stdin`, iterasjon over `rune`-verdier.
- Bygge en `map[rune]rune` fra SET1 til SET2, og bruke `strings.Map` for transformasjonen.
- Ekspandere range-syntaks som `a-z` til en full sekvens av runer.
- `-d`: bruke en `map[rune]bool` (eller sett) og filtrere bort tegn.
- `-s`: sammenligne hver rune med forrige skrevne rune for å hoppe over gjentakelser.

## Test-scenarioer
- **Oversettelse `a-z` → `A-Z`:** input med små bokstaver → store bokstaver.
- **Oversettelse enkelt-tegn:** `tr 'o' '0'` → alle `o` blir `0`.
- **`-d`:** `tr -d 'aeiou'` → alle vokaler fjernes fra input.
- **`-s`:** `tr -s ' '` → flere mellomrom etter hverandre komprimeres til ett.
- **Kombinert range:** `tr 'a-c' 'x-z'` → `a`→`x`, `b`→`y`, `c`→`z`.

## Stretch-mål
- Implementer `-c` (komplement av SET1).
- Støtt forhåndsdefinerte klasser som `[:alpha:]`, `[:digit:]`.
- Håndter at SET2 er kortere enn SET1 (siste tegn i SET2 gjentas).

## Kjør testene
`./test.sh "go run ."`

Argumentet er kandidat-kommandoen som skal testes (default `go run .`). Testen kjører både kandidaten din og systemets ekte `tr` mot samme input via stdin og sammenligner med `diff`. Identisk output gir `PASS`, avvik gir `FAIL`.
