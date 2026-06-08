# 06 — tac

## Hva det gjør
`tac` skriver ut linjene fra input i omvendt rekkefølge — siste linje først, første linje sist. Navnet er `cat` stavet baklengs. Leser fra stdin eller fra angitte filer og sender resultatet til stdout.

| Flagg | Beskrivelse |
| --- | --- |
| `-s SEP` | Bruk `SEP` som skilletegn mellom poster i stedet for newline. |
| `-r` | Tolk skilletegnet som et regulært uttrykk. |
| `-b` | Plasser skilletegnet før (ikke etter) hver post. |

## Go-læringsmål
Dette verktøyet trener grunnleggende lesing og samling av input til en datastruktur:

- `bufio.Scanner` for å lese stdin linje for linje (`scanner.Scan()`, `scanner.Text()`).
- Samle alle linjer i en `[]string`-slice via `append`.
- Slice-manipulasjon: iterere baklengs med `for i := len(lines) - 1; i >= 0; i--`, eventuelt bytte elementer på plass.
- `os.Stdin` og `fmt.Println` / `bufio.Writer` for output.

## Test-scenarioer
- **Reversering av linjer:** flerlinjet input → linjene skrives ut i motsatt rekkefølge.
- **Enkelt-linje input:** én linje → samme linje uendret.
- **Tom input:** ingen input → ingen output.
- **Input uten avsluttende newline:** siste linje uten `\n` → håndteres uten å miste innhold.

## Stretch-mål
- Implementer `-s` for egendefinert skilletegn.
- Støtt flere filargumenter (les og reverser samlet output).
- Implementer `-b` for å plassere skilletegnet foran hver post.

## Kjør testene
`./test.sh "go run ."`

Argumentet er kandidat-kommandoen som skal testes (default `go run .`). Testen kjører både kandidaten din og systemets ekte `tac` mot samme input og sammenligner outputene med `diff`. Identisk output gir `PASS`, avvik gir `FAIL`.
