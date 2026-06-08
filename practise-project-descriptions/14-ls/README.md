# 14 — ls

## Hva det gjør
`ls` lister innholdet i en mappe. Som standard vises ikke-skjulte oppføringer, sortert alfabetisk, ofte i kolonner. Med flagg kan man vise skjulte filer, detaljert metadata og lesbare størrelser.

| Flagg | Betydning |
|-------|-----------|
| `-a`  | Vis også skjulte oppføringer (de som starter med `.`) |
| `-l`  | Lang form: rettigheter, størrelse, endringsdato, navn |
| `-h`  | Lesbare størrelser (f.eks. `1.5K`, `2.3M`) sammen med `-l` |

## Go-læringsmål
- `os.ReadDir`: les mappeinnhold som `[]fs.DirEntry`, sortert på navn av standardbiblioteket.
- `fs.FileInfo` via `entry.Info()` eller `os.Stat`: hent størrelse (`Size()`), endringstid (`ModTime()`) og modus (`Mode()`).
- `os.FileMode`-formatering: `Mode().String()` gir `drwxr-xr-x`-lignende streng; forstå type-bitene.
- Kolonne- og tabell-formatering: `text/tabwriter` eller manuell padding med `fmt.Sprintf`-bredder.
- Tids-formatering: `time.Time.Format` med et referanse-layout for dato/klokkeslett.
- Sortering: `sort.Slice` ved behov for egendefinert rekkefølge; filtrering av skjulte filer for default-visning.
- Lesbare størrelser for `-h`: heltallsdeling/avrunding mot enheter (K, M, G).

## Test-scenarioer
- Basis: `ls mappe` → ikke-skjulte navn, alfabetisk sortert.
- `-a`: `ls -a mappe` → inkluderer skjulte oppføringer (`.`-prefiks).
- `-l`: `ls -l mappe` → én oppføring per linje med modus, størrelse, dato og navn (smoke-test: kommandoen kjører uten feil og gir riktig antall linjer).
- `-h`: `ls -lh mappe` → størrelser i lesbar form (smoke-test, ikke full diff pga. tidspunkt/eier).
- Sortering: oppføringer skal komme i samme alfabetiske rekkefølge som ekte `ls`.

## Stretch-mål
- `-R`: rekursiv listing av undermapper.
- `-t`: sorter etter endringstid.
- `-r`: reversér sorteringen.
- `-S`: sorter etter størrelse.
- Fargelegg etter filtype (ANSI), som `ls --color`.
- Vis eier/gruppe i `-l` (via `syscall`/`os/user`).
- Ekte kolonne-layout for terminalbredde (default `ls` uten `-l`).

## Kjør testene
```
./test.sh "go run ."
```
Kandidat-kommandoen sendes inn som første argument (default `go run .`). Testen bygger en mappe-fixture og sammenligner med systemets ekte `ls` via `diff`. Kun det deterministiske diffes fullt ut (`ls` og `ls -a` — navn og sortering). For `-l` og `-h` er det smoke-tester (kommandoen kjører, riktig antall linjer), fordi endringstid og eier er vanskelig å matche eksakt på tvers av implementasjoner. Sanity-sjekk: `./test.sh ls` skal gi PASS.
