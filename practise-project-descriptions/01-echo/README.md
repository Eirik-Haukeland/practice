# 01 — echo

## Hva det gjør
`echo` skriver argumentene sine til standard ut, adskilt med mellomrom og avsluttet med et linjeskift. Det er det enkleste Unix-verktøyet og et naturlig startpunkt for å lære Go: lese argumenter, sette dem sammen og skrive til stdout. Med flagg kan man styre om linjeskiftet skal med, og om escape-sekvenser skal tolkes.

| Flagg | Beskrivelse |
| ----- | ----------- |
| `-n`  | Utelat det avsluttende linjeskiftet |
| `-e`  | Tolk escape-sekvenser (`\n`, `\t`, `\\` osv.) |

## Go-læringsmål
- `os.Args` — lese kommandolinje-argumenter (husk at `os.Args[0]` er programnavnet).
- `fmt` — `fmt.Print` / `fmt.Println` for å skrive til stdout.
- `strings.Join` — sette sammen argumenter med mellomrom som skilletegn.
- Iterere over en slice og skille mellom flagg og vanlige argumenter.
- Enkel strengmanipulasjon for å tolke escape-sekvenser når `-e` er satt.

## Test-scenarioer
- Ingen flagg: `echo hei verden` → skriver `hei verden` etterfulgt av linjeskift.
- Flere argumenter: `echo a b c` → argumentene skilles med ett enkelt mellomrom.
- `-n`: `echo -n hei` → skriver `hei` uten avsluttende linjeskift.
- `-e`: `echo -e "a\tb"` → tolker `\t` som tabulator i utskriften.
- Tom input: `echo` → skriver kun et linjeskift.

## Stretch-mål
- Støtt `-E` (eksplisitt deaktiver escape-tolking, som er standard).
- Kombiner flagg, f.eks. `-ne`.
- Støtt flere escape-sekvenser: `\a`, `\b`, `\r`, `\v`, `\f`, `\0NNN` (oktal).

## Kjør testene
`./test.sh "go run ."` — kandidat-kommandoen sendes inn som første argument (default `go run .`).
Testen kjører både din kandidat og systemets ekte `echo` mot samme input og sammenligner utskriften med `diff`. Får du `PASS` på alle case, oppfører verktøyet ditt seg likt det ekte.
