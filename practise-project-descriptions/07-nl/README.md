# 07 — nl

## Hva det gjør
`nl` nummererer linjer fra input og skriver dem til stdout. Som standard nummereres kun ikke-tomme linjer, og tallet skrives høyrejustert med et tabulatortegn foran selve linjeteksten. Leser fra stdin eller fra angitte filer.

| Flagg | Beskrivelse |
| --- | --- |
| `-b a` | Nummerer alle linjer (også tomme). |
| `-b t` | Nummerer kun ikke-tomme linjer (standard). |
| `-b n` | Ikke nummerer noen linjer. |
| `-w N` | Bredde på linjenummer-feltet. |
| `-s STR` | Skilletegn mellom nummer og tekst (standard tab). |

## Go-læringsmål
Dette verktøyet trener formatert output og betinget logikk:

- `bufio.Scanner` for å lese input linje for linje.
- `fmt.Sprintf` med bredde/padding-verb, f.eks. `fmt.Sprintf("%6d\t%s", n, line)` for høyrejustert nummer.
- Betinget telling: en separat teller som kun øker for linjer som faktisk skal nummereres.
- Skille mellom `-b a` (alle linjer) og `-b t` (kun ikke-tomme), der tomme linjer skrives ut uten nummer men med innrykk.

## Test-scenarioer
- **Standard (`-b t`):** input med blandede tomme/ikke-tomme linjer → kun ikke-tomme linjer får nummer, tomme linjer skrives uten nummer.
- **`-b a`:** samme input → alle linjer nummereres inkludert tomme.
- **`-b n`:** input → ingen linjer nummereres.
- **Telleren hopper over tomme linjer i `-b t`:** to ikke-tomme linjer adskilt av tom linje → nummereres 1 og 2, ikke 1 og 3.

## Stretch-mål
- Implementer `-w N` for egendefinert feltbredde.
- Implementer `-s STR` for egendefinert skilletegn.
- Støtt `-v N` (startnummer) og `-i N` (inkrement).

## Kjør testene
`./test.sh "go run ."`

Argumentet er kandidat-kommandoen som skal testes (default `go run .`). Testen kjører både kandidaten din og systemets ekte `nl` mot samme input og sammenligner med `diff`. NB: GNU `nl` bruker variabel innrykk/padding, så testen normaliserer whitespace på begge sider med `tr -s ' '` før sammenligning. Identisk normalisert output gir `PASS`.
