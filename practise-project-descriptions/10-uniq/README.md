# 10 — uniq

## Hva det gjør
`uniq` filtrerer ut tilstøtende, identiske linjer fra input og skriver resultatet til stdout. Det sammenligner kun nabolinjer, så input bør være sortert for å fjerne alle duplikater. Med flagg kan det telle, eller vise kun dupliserte eller kun unike linjer.

| Flagg | Beskrivelse |
| --- | --- |
| (ingen) | Slå sammen tilstøtende like linjer til én. |
| `-c` | Sett antall forekomster foran hver linje. |
| `-d` | Skriv kun ut linjer som forekommer mer enn én gang. |
| `-u` | Skriv kun ut linjer som forekommer nøyaktig én gang. |

## Go-læringsmål
Dette verktøyet trener tilstandshåndtering under iterasjon:

- `bufio.Scanner` for å lese input linje for linje.
- Holde forrige linje i en variabel og sammenligne med gjeldende (`if line == prev`).
- Telle påfølgende like linjer med en teller som nullstilles ved endring.
- `fmt.Sprintf("%7d %s", count, line)` for `-c`-output med padding.
- Betinget utskrift basert på telleren for `-d` (count > 1) og `-u` (count == 1).

## Test-scenarioer
- **Standard:** sortert input med tilstøtende duplikater → hver gruppe reduseres til én linje.
- **`-c`:** samme input → hver unik linje med antall foran.
- **`-d`:** kun linjer som forekommer mer enn én gang skrives ut.
- **`-u`:** kun linjer som forekommer nøyaktig én gang skrives ut.
- **Ikke-tilstøtende duplikater:** usortert input → kun nabo-duplikater fjernes (resten beholdes).

## Stretch-mål
- Implementer `-i` (ignorer bokstavstørrelse ved sammenligning).
- Implementer `-f N` (hopp over de første N feltene før sammenligning).
- Implementer `-s N` (hopp over de første N tegnene).

## Kjør testene
`./test.sh "go run ."`

Argumentet er kandidat-kommandoen som skal testes (default `go run .`). Testen kjører både kandidaten din og systemets ekte `uniq` mot samme input via stdin og sammenligner med `diff`. NB: `-c`-output har variabel padding, så testen normaliserer whitespace på begge sider med `tr -s ' '`. Scriptet setter `LC_ALL=C` for deterministisk oppførsel. Identisk output gir `PASS`.
