# Go-implementasjoner

Her skriver du dine egne Go-versjoner av CLI-verktøyene. Beskrivelser, test-scenarioer
og golden-tester ligger i [`../practise-project-descriptions/`](../practise-project-descriptions/).

## Konvensjon: én modul per verktøy

Hver verktøy bor i egen mappe med egen `go.mod`, så de er uavhengige og kan bygges/kjøres isolert:

```
go/
  echo/
    go.mod        <- module echo  (go 1.22+)
    main.go       <- package main
  cat/
    go.mod
    main.go
  ...
```

### Sett opp et nytt verktøy

```bash
cd go
mkdir echo && cd echo
go mod init echo
$EDITOR main.go
```

Minimal `main.go`:

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Println(os.Args[1:])
}
```

### Kjør og test

```bash
# Kjør direkte under utvikling
cd /home/eirik/Projects/personal/fag_uke/practice/go/echo
go run . hei verden

# Golden-test: bygg binær til absolutt sti, kjør testen fra repo-rota
cd /home/eirik/Projects/personal/fag_uke/practice
go build -o /tmp/echo ./go/echo
./practise-project-descriptions/01-echo/test.sh /tmp/echo
```

> Bygg til absolutt sti (`/tmp/echo`) i stedet for å sende `go run`-kommando som kandidat:
> `find`- og `ls`-testene `cd`-er internt til en temp-mappe, så en relativ `go run`-sti
> ville knekke. En binær med absolutt sti fungerer uansett.

## Tips

- `go run .` kjører mappa som program — raskt under utvikling.
- `go build -o echo .` lager binær når du vil teste den som ekte verktøy.
- `go doc os.ReadDir` (eller hvilken som helst pakke/funksjon) gir docs i terminalen — bruk det aktivt.
- `gofmt -w .` formaterer; `go vet ./...` fanger vanlige feil.
- Hold deg til stdlib så lenge som mulig. Eneste sannsynlige eksterne avhengighet er
  `fsnotify` i `tail -f` (17) — og selv der kan du klare deg med `os.Stat`-polling først.
