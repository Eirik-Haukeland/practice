# 12 — grep

## Hva det gjør
`grep` søker etter linjer som matcher et regulært uttrykk i én eller flere filer, eller fra standard input. Hver matchende linje skrives ut. Verktøyet er en av de mest brukte byggeklossene i Unix og kombineres ofte med rør (pipes).

| Flagg | Betydning |
|-------|-----------|
| `-i`  | Ignorer forskjell på store og små bokstaver |
| `-v`  | Inverter: skriv ut linjer som *ikke* matcher |
| `-n`  | Prefiks hver matchende linje med linjenummer |
| `-c`  | Skriv kun ut antall matchende linjer |
| `-r`  | Søk rekursivt i mapper |

## Go-læringsmål
- `regexp`-pakken: `regexp.Compile` for å kompilere mønsteret, `Regexp.MatchString` for å teste hver linje. Bruk `(?i)`-prefiks eller `regexp.Compile` på et lowercaset mønster for `-i`.
- Lesing fra fil og stdin: `os.Open`, `os.Stdin`, og `bufio.Scanner` for linje-for-linje-skanning.
- Argument-parsing: `flag`-pakken (`flag.Bool`) for boolske flagg, og `flag.Args()` for mønster + filnavn.
- Rekursiv traversering for `-r`: `filepath.WalkDir` med `fs.DirEntry`.
- Telling og tilstand: hold en teller for `-c`, et linjenummer for `-n`.
- Riktig exit-kode: `os.Exit(1)` når ingen treff (grep-konvensjon).

## Test-scenarioer
- Basis: `grep mønster fil` → kun linjer som matcher mønsteret.
- `-i`: `grep -i Hei fil` → matcher "hei", "HEI", "Hei".
- `-v`: `grep -v mønster fil` → alle linjer unntatt de som matcher.
- `-n`: `grep -n mønster fil` → matchende linjer prefikset med `linjenr:`.
- `-c`: `grep -c mønster fil` → kun antall matchende linjer som tall.
- `-r`: `grep -r mønster mappe` → søk gjennom alle filer i mappetreet, prefiks med filnavn.
- Stdin: `grep mønster < fil` → leser fra standard input når ingen fil er gitt.

## Stretch-mål
- `-l`: skriv kun ut filnavn som inneholder minst ett treff.
- `-o`: skriv kun ut den matchende delen av linjen.
- `-w`: match kun hele ord.
- `-A`/`-B`/`-C`: vis kontekst-linjer etter/før/rundt treff.
- Fargelegg treffene i terminalen (ANSI-koder).
- Håndter flere filer samtidig med filnavn-prefiks.

## Kjør testene
```
./test.sh "go run ."
```
Kandidat-kommandoen sendes inn som første argument (default `go run .`). Testen bygger små fixtures, kjører både din implementasjon og systemets ekte `grep`, og sammenligner output med `diff`. Sanity-sjekk: `./test.sh grep` skal gi PASS fordi referansen sammenlignes mot seg selv.
