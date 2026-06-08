# 19 — cd

## Hva det gjør

`cd` endrer arbeidsmappe. Den er egentlig en **shell-builtin**: en frittstående prosess
kan ikke endre foreldreprosessens (shellens) arbeidsmappe — `os.Chdir` påvirker bare
ditt eget program. Derfor lar dette prosjektet `cd` skrive den **oppløste mål-mappa til
stdout**, slik man i praksis wrapper den i en shell-funksjon (`cd() { builtin cd "$(mycd "$@")"; }`).
Læringen ligger i sti- og env-oppløsningen, ikke i selve mappebyttet.

| Argument | Betydning |
|----------|-----------|
| `<dir>`  | Oppløs til absolutt sti og skriv ut (relativ → mot cwd) |
| _(ingen)_ | Gå til `$HOME` |
| `-`      | Gå til forrige mappe (`$OLDPWD`) |
| `~`, `~/x` | Ekspander til `$HOME` |
| ikke-eksisterende / ikke-mappe | Feilmelding til stderr, exit-kode ≠ 0 |

## Go-læringsmål

- `os.Getenv` — les `HOME`, `OLDPWD`, `PWD`.
- `filepath.Abs`, `filepath.Clean`, `filepath.Join` — gjør relativ sti om til kanonisk absolutt sti.
- `os.Stat` + `FileInfo.IsDir` — valider at målet finnes og er en mappe.
- `os.Chdir` — det ekte mappebyttet (poeng: påvirker kun egen prosess; demonstrer at
  cwd er tilbake som før når programmet avslutter).
- `strings.HasPrefix` / tilde-ekspansjon — håndter `~`.
- Skriv feil til `os.Stderr` og sett exit-kode med `os.Exit(1)`.

## Test-scenarioer

- **Absolutt mappe:** `mycd /eksisterende/mappe` → skriver den absolutte stien.
- **Relativ mappe:** stå i `X`, kjør `mycd sub` → skriver `X/sub`.
- **Ingen argument:** `mycd` → skriver `$HOME`.
- **Forrige mappe:** `mycd -` → skriver `$OLDPWD`.
- **Tilde:** `mycd ~` → skriver `$HOME`; `mycd ~/x` → `$HOME/x`.
- **Feil:** `mycd /finnes/ikke` → ingenting på stdout, melding på stderr, exit-kode ≠ 0.

## Stretch-mål

- `cd -` skal også skrive ut mappa den byttet til (slik ekte `cd -` gjør).
- Oppdater `OLDPWD`/`PWD`-semantikk korrekt (krever wrapper-tankegang).
- `-P` (fysisk sti — løs opp symlenker med `filepath.EvalSymlinks`) vs `-L` (logisk).
- `CDPATH`-støtte: søk i mappene i `$CDPATH` for relative mål.

## Kjør testene

Dette er en **oppførsels-test** (ikke ren diff mot ekte verktøy — `cd` er en shell-builtin
uten stdout). Testen sammenligner din utskrift mot `(cd <arg> && pwd)` beregnet i bash.

```bash
# bygg fra modulmappa (subshell holder cwd i rota), kjør testen fra rota
(cd go/19-cd && go build -o /tmp/cd .)
./practise-project-descriptions/19-cd/test.sh /tmp/cd
```

Default kandidat er `go run .` om du dropper argumentet og står i `go/19-cd/`.
