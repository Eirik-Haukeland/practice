# 15 — xargs

## Hva det gjør
`xargs` leser elementer fra standard input, bygger en kommandolinje av dem og kjører kommandoen med elementene som argumenter. Det brukes typisk sammen med en pipe for å gjøre om en strøm av tekst til argumenter for et annet program. Uten en kommando som argument kjører `xargs` `echo` som standard.

| Flagg | Beskrivelse |
| ----- | ----------- |
| `-n N` | Kjør kommandoen med maksimalt N argumenter per kjøring (batching). |
| `-I {}` | Erstatt forekomster av placeholderen (f.eks. `{}`) med ett inputelement per kjøring. |
| `-d DELIM` | Bruk DELIM som skilletegn mellom elementer i stedet for mellomrom/linjeskift. |
| `-0` | Bruk NUL (`\0`) som skilletegn (nyttig sammen med `find -print0`). |

## Go-læringsmål
- `os/exec`: bygg kommando med `exec.Command(navn, args...)`, kjør med `cmd.Run()` eller `cmd.Start()`/`cmd.Wait()`.
- Videresend utdata ved å sette `cmd.Stdout = os.Stdout` og `cmd.Stderr = os.Stderr`.
- Les fra `os.Stdin` med `bufio.Scanner`; bruk `bufio.ScanWords` som split-funksjon for å dele på blanktegn.
- Bygg argumentlister dynamisk med slices (`append`) og forstå batching med `-n`.
- Strengmanipulasjon med `strings.ReplaceAll` for `-I`-placeholder.
- Parse flagg manuelt eller med `flag`-pakken, og skill kandidatkommandoen fra `xargs`-egne flagg.

## Test-scenarioer
- Ingen flagg: `echo "a b c" | xargs echo` → kjører `echo a b c`, gir ut `a b c`.
- `-n 1`: `printf "a\nb\nc\n" | xargs -n 1 echo` → tre separate kjøringer, hver gir én linje.
- `-n 2`: `echo "1 2 3 4" | xargs -n 2 echo` → to kjøringer: `1 2` og `3 4`.
- `-I {}`: `printf "x\ny\n" | xargs -I {} echo item-{}` → `item-x` og `item-y` på hver sin linje.
- Standardkommando: `echo "hei verden" | xargs` → kjører `echo hei verden`.

## Stretch-mål
- `-d` og `-0` for egendefinerte skilletegn.
- `-P N` for å kjøre flere kommandoer parallelt (goroutines + semafor-kanal).
- `-r` (`--no-run-if-empty`): ikke kjør kommandoen hvis input er tom.
- Korrekt videreføring av exit-kode fra siste/feilende delkommando.

## Kjør testene
```
./test.sh "go run ."
```
Standard kandidatkommando er `go run .`. Testen sammenligner kandidatens utdata mot ekte `xargs` (golden-diff) for flere flaggkombinasjoner. Kjør `./test.sh xargs` for å verifisere at testoppsettet selv er korrekt (skal gi PASS).
