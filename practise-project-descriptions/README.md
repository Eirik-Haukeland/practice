# CLI-verktøy læringsløype i Go

Gjenskap klassiske Unix CLI-verktøy fra bunnen i Go. Verktøyene er ordnet i en
progresjon der hvert prosjekt introduserer nye Go-konsepter og bygger på det forrige.
Beskrivelsene og testene ligger her; selve Go-koden skriver du selv i `../go/<verktøy>/`.

## Slik jobber du

1. Velg neste nummererte mappe.
2. Les `README.md` — den har spec, Go-læringsmål, test-scenarioer og stretch-mål.
3. Skriv Go-implementasjonen i `../go/<verktøy>/` (én modul per verktøy — se `../go/README.md`).
4. Bygg en binær og kjør golden-testen. Stå i repo-rota (`practice/`):
   ```bash
   cd /home/eirik/Projects/personal/fag_uke/practice
   go build -o /tmp/echo ./go/echo
   ./practise-project-descriptions/01-echo/test.sh /tmp/echo
   ```
   Testen kjører binæren din og systemets ekte verktøy mot samme input og `diff`-er output.
5. Grønt? Gå videre. Vil du ha mer? Ta stretch-målene.

> **Hvorfor binær og ikke `go run`?** Noen tester (`find`, `ls`) `cd`-er internt til en
> temp-mappe, så en relativ `go run ./go/...`-sti ville knekke. En absolutt binær-sti
> fungerer uansett hvor testen står. `go build -o /tmp/<navn>` er raskt nok i loopen.

> **Sanity-sjekk av testen:** Hver `test.sh` skal gi PASS når du kjører den med det
> ekte verktøyet som kandidat, f.eks. `./03-wc/test.sh wc`. Da vet du at testen selv er
> riktig før du jakter på feil i din egen kode.

## Rekkefølge

### Tier 1 — IO, args, scanning (fundament)
| # | Verktøy | Nye Go-konsepter |
|---|---------|------------------|
| 1 | [echo](01-echo/) | `os.Args`, `fmt`, string-join, flagg `-n` |
| 2 | [cat](02-cat/)  | `os.Open`, `io.Copy`, `os.Stdin`, flere filer, defer/close |
| 3 | [wc](03-wc/)   | `bufio.Scanner`, rune vs byte-telling, `-l -w -c -m` |
| 4 | [head](04-head/) | `flag`-pakken, les N linjer og stopp tidlig, `-n -c` |
| 5 | [tail](05-tail/) | ring-buffer for siste N linjer, `-n -c` |

### Tier 2 — tekstprosessering, flagg, datastrukturer
| # | Verktøy | Nye Go-konsepter |
|---|---------|------------------|
| 6 | [tac](06-tac/)  | les alt, reverser slice |
| 7 | [nl](07-nl/)   | linjenummerering, formatert output (`fmt.Sprintf` bredde) |
| 8 | [tr](08-tr/)   | rune-mapping, sett, `-d -s` |
| 9 | [cut](09-cut/)  | felt/char-uttrekk, delimiter, `strings.Split`, `-f -d -c` |
| 10 | [uniq](10-uniq/) | nabodedup, `-c -d -u` (krever sortert input) |
| 11 | [sort](11-sort/) | `sort`-pakken, `sort.Slice`, interfaces, `-n -r -k -u` |
| 19 | [cd](19-cd/) | `os.Getenv` (HOME/OLDPWD), `filepath.Abs/Clean`, `os.Stat`/`IsDir`, tilde |

> `cd` (19) ligger på Tier 2-nivå konseptuelt, men beholder nummer 19 så de øvrige ikke
> renummereres. Den er en **oppførsels-test**, ikke ren golden-diff (ekte `cd` er en
> shell-builtin). Ta den når som helst etter Tier 1.

### Tier 3 — mønster-matching og tre-traversering
| # | Verktøy | Nye Go-konsepter |
|---|---------|------------------|
| 12 | [grep](12-grep/) | `regexp`-pakken, `-i -v -n -c -r`, rekursivt søk |
| 13 | [find](13-find/) | `filepath.WalkDir`, `fs.DirEntry`, predikater `-name -type` |
| 14 | [ls](14-ls/)   | `os.ReadDir`, `fs.FileInfo`, kolonne-formatering, `-l -a -h`, sortering |

### Tier 4 — komposisjon, samtidighet, nett
| # | Verktøy | Nye Go-konsepter |
|---|---------|------------------|
| 15 | [xargs](15-xargs/)   | `os/exec`, bygg+kjør kommandoer, batching `-n -I` |
| 16 | [sed](16-sed/)     | stream-redigering, `s///`-substitusjon (regexp-subset) |
| 17 | [tail -f](17-tail-f/) | **goroutines + channels**, polling/`fsnotify`, fil-watch |
| 18 | [curl](18-curl/) (mini) | `net/http`, streaming body, `-X -H -d -o` |

Stretch utenfor løypa: mini-shell (pipes via `os/exec`, signaler) — kun hvis tid.

## Hvorfor denne rekkefølgen

- **Tier 1** lærer deg å lese args, åpne filer og scanne input — grunnmuren alt annet hviler på.
- **Tier 2** legger til flag-parsing og data-manipulasjon (slices, maps, `sort`-pakken).
- **Tier 3** tar steget til regex og rekursiv filtre-traversering.
- **Tier 4** introduserer det som gjør Go spennende: `os/exec`, goroutines/channels og `net/http`.

Du kan stoppe etter hvilket som helst tier og likevel sitte igjen med solid Go-grunnlag.
`tail -f` (17) er kjerneprosjektet for samtidighet — ikke hopp over det hvis du vil lære goroutines.
