# 16 — sed

## Hva det gjør
`sed` er en strøm-editor som leser tekst linje for linje og utfører redigeringer underveis. I dette øvingsprosjektet implementerer du kun substitusjonskommandoen `s/mønster/erstatning/`, som bytter ut tekst som matcher et regulært uttrykk. Input leses fra en fil eller fra standard input, og resultatet skrives til standard output.

| Flagg/syntaks | Beskrivelse |
| ------------- | ----------- |
| `s/RE/REPL/` | Erstatt første treff av regex `RE` med `REPL` på hver linje. |
| `s/RE/REPL/g` | Global: erstatt alle treff på linjen, ikke bare det første. |
| `FILE` | Les fra fil i stedet for stdin. |
| `-n` (stretch) | Undertrykk automatisk utskrift; brukes med `p`-flagget. |

## Go-læringsmål
- `regexp`: kompiler mønster med `regexp.Compile` / `regexp.MustCompile`, og bruk `re.ReplaceAll` / `re.ReplaceAllString` for substitusjon.
- `bufio.Scanner` for å lese input linje for linje fra `os.Stdin` eller en `*os.File`.
- `bufio.Writer` / `os.Stdout` for buffret utskrift av redigerte linjer.
- Strengparsing: splitt `s/.../.../`-uttrykket på skilletegnet og håndter `g`-flagget.
- Forskjellen på første-treff vs. global substitusjon (`ReplaceAll` er alltid global — for kun første treff må du bruke `FindStringIndex` eller `ReplaceAllStringFunc` med teller).

## Test-scenarioer
- Enkel substitusjon: `echo "foo bar" | sed 's/foo/baz/'` → `baz bar`.
- Kun første treff: `echo "a a a" | sed 's/a/b/'` → `b a a`.
- Global: `echo "a a a" | sed 's/a/b/g'` → `b b b`.
- Regex-mønster: `echo "x123y" | sed 's/[0-9]\+/N/g'` → `xNy`.
- Les fra fil: `sed 's/cat/dog/g' FILE` → erstatter i filinnholdet.

## Stretch-mål
- Annet skilletegn enn `/`, f.eks. `s|a|b|` (nyttig når mønsteret inneholder skråstrek).
- Backreferanser i erstatningen (`\1`, `\2`) via fanggrupper.
- `-n` kombinert med `p`-flagget (`s/.../.../p`) for å skrive ut kun endrede linjer.
- Flere `-e`-uttrykk kjedet etter hverandre.

## Kjør testene
```
./test.sh "go run ."
```
Standard kandidatkommando er `go run .`. Testen sammenligner kandidatens utdata mot ekte `sed` (golden-diff) for flere `s///`-tilfeller, både fra stdin og fra fil. Kjør `./test.sh sed` for å verifisere at testoppsettet selv er korrekt (skal gi PASS).
