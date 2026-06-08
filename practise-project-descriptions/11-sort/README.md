# 11 — sort

## Hva det gjør
`sort` leser alle linjer fra input, sorterer dem og skriver resultatet til stdout. Som standard sorteres det leksikografisk (byte-for-byte). Flagg endrer sorteringsrekkefølge, behandling av tall, og hvilket felt det sorteres på. Leser fra stdin eller fra angitte filer.

| Flagg | Beskrivelse |
| --- | --- |
| `-n` | Numerisk sortering (tolk linjene som tall). |
| `-r` | Omvendt rekkefølge. |
| `-u` | Fjern duplikater (behold kun unike linjer). |
| `-k N` | Sorter på felt nummer `N` (whitespace-delt). |

## Go-læringsmål
Dette verktøyet trener bruk av `sort`-pakken og sammenligningsfunksjoner:

- `bufio.Scanner` for å lese alle linjer inn i en `[]string`.
- `sort.Strings` for enkel leksikografisk sortering, eller `sort.Slice(lines, func(i, j int) bool { ... })` for egendefinert sammenligning.
- `-n`: konvertere med `strconv.ParseFloat`/`Atoi` i sammenligningsfunksjonen.
- `-r`: snu sammenligningen (eller reversere etterpå).
- `-u`: filtrere bort duplikater etter sortering.
- `-k N`: `strings.Fields` for å hente felt og sortere på det.

## Test-scenarioer
- **Standard:** usorterte tekstlinjer → leksikografisk sortert.
- **`-n`:** linjer med tall (f.eks. `10`, `2`, `1`) → numerisk sortert (`1`, `2`, `10`).
- **`-r`:** tekstlinjer → omvendt leksikografisk rekkefølge.
- **`-u`:** input med duplikater → sortert uten duplikater.
- **`-k 2`:** linjer med flere felt → sortert på andre felt.

## Stretch-mål
- Implementer `-f` (ignorer bokstavstørrelse).
- Kombiner flagg, f.eks. `-nr` (numerisk omvendt).
- Implementer `-t` for egendefinert feltskilletegn sammen med `-k`.

## Kjør testene
`./test.sh "go run ."`

Argumentet er kandidat-kommandoen som skal testes (default `go run .`). Testen kjører både kandidaten din og systemets ekte `sort` mot samme input via stdin og sammenligner med `diff`. NB: `sort` er locale-følsomt, så scriptet setter `LC_ALL=C` for deterministisk byte-sortering. Identisk output gir `PASS`.
