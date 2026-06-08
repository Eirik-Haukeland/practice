# 13 — find

## Hva det gjør
`find` traverserer et katalogtre rekursivt og skriver ut stier til oppføringer som matcher gitte predikater. Uten predikater skrives hele treet ut. Det er standardverktøyet for å lokalisere filer basert på navn, type og andre egenskaper.

| Flagg/predikat | Betydning |
|----------------|-----------|
| `-name MØNSTER` | Match filnavn mot glob-mønster (f.eks. `*.go`) |
| `-type f`       | Match kun vanlige filer |
| `-type d`       | Match kun mapper |

## Go-læringsmål
- `filepath.WalkDir`: effektiv rekursiv traversering som gir `fs.DirEntry` per oppføring (unngår unødvendige `Stat`-kall).
- `fs.DirEntry`: `entry.Name()`, `entry.IsDir()`, `entry.Type()` for å avgjøre type uten ekstra syscalls.
- `filepath.Match`: glob-matching for `-name` (`*`, `?`, `[...]`).
- Sti-håndtering: `filepath.Join` og forståelse av rot-argumentet versus relative stier.
- Argument-parsing av predikater (ikke bare boolske flagg): tolk `-name` og `-type` med påfølgende verdi, manuelt eller via `flag`.
- Feilhåndtering i callback: returner riktig verdi fra WalkDir-funksjonen, og bruk `fs.SkipDir` ved behov.

## Test-scenarioer
- Basis: `find mappe` → alle stier i treet, inkludert mapper og rot.
- `-name`: `find mappe -name '*.txt'` → kun stier der filnavnet matcher glob-mønsteret.
- `-type f`: `find mappe -type f` → kun vanlige filer.
- `-type d`: `find mappe -type d` → kun mapper (inkludert rot).
- Kombinert: `find mappe -type f -name '*.go'` → vanlige filer med `.go`-endelse.
- Rekursjon: nøstede undermapper skal traverseres i dybden.

## Stretch-mål
- `-iname`: case-insensitivt navne-mønster.
- `-maxdepth N`: begrens hvor dypt det traverseres.
- `-size`: filtrer på filstørrelse.
- `-mtime`: filtrer på endringstidspunkt.
- `-exec`: kjør en kommando per treff.
- Støtt flere start-stier på kommandolinjen.

## Kjør testene
```
./test.sh "go run ."
```
Kandidat-kommandoen sendes inn som første argument (default `go run .`). Testen bygger et lite katalogtre, kjører både din implementasjon og systemets ekte `find`, og sammenligner output med `diff`. Fordi `find` ikke garanterer rekkefølge, sorteres begge sider før sammenligning. Sanity-sjekk: `./test.sh find` skal gi PASS.
