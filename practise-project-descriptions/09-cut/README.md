# 09 — cut

## Hva det gjør
`cut` plukker ut deler av hver linje fra input og skriver dem til stdout. Det kan trekke ut felt adskilt av et skilletegn (`-f` med `-d`) eller posisjoner basert på tegn (`-c`). Hver linje behandles uavhengig. Leser fra stdin eller fra angitte filer.

| Flagg | Beskrivelse |
| --- | --- |
| `-f LIST` | Velg felt (1-indeksert), f.eks. `-f 1,3` eller `-f 2-4`. |
| `-d DELIM` | Skilletegn for felt (standard tab). |
| `-c LIST` | Velg tegnposisjoner, f.eks. `-c 1-3,5`. |
| `-s` | Hopp over linjer uten skilletegn (kun med `-f`). |

## Go-læringsmål
Dette verktøyet trener parsing og string-manipulasjon:

- `bufio.Scanner` for å lese input linje for linje.
- `strings.Split(line, delim)` for å dele en linje i felt.
- Parsing av range-spesifikasjon: dele `"1-3,5"` på komma, så på bindestrek, konvertere med `strconv.Atoi`.
- Indeksering inn i en slice av felt eller en `[]rune` av tegn, med håndtering av åpne ranges (`-3`, `2-`).
- Sette sammen resultatet igjen med riktig skilletegn.

## Test-scenarioer
- **`-f` med `-d`:** kolon-delt linje, `-d ':' -f 1` → første felt.
- **Flere felt:** `-d ':' -f 1,3` → felt 1 og 3 satt sammen med skilletegn.
- **Felt-range:** `-d ':' -f 2-3` → felt 2 til 3.
- **`-c` enkelt-range:** `-c 1-3` → de tre første tegnene per linje.
- **`-c` med komma:** `-c 1-3,5` → tegn 1–3 og tegn 5.

## Stretch-mål
- Implementer `-s` (hopp over linjer uten skilletegn).
- Støtt åpne ranges som `-c 3-` og `-c -3`.
- Implementer `--output-delimiter` for å bytte skilletegn i output.

## Kjør testene
`./test.sh "go run ."`

Argumentet er kandidat-kommandoen som skal testes (default `go run .`). Testen kjører både kandidaten din og systemets ekte `cut` mot samme input via stdin og sammenligner med `diff`. Identisk output gir `PASS`, avvik gir `FAIL`.
