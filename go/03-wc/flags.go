package main

import (
	"fmt"
	"os"
	"strings"
)

type Flags struct {
	countLines       bool
	countBytes       bool
	countRunes       bool
	countWords       bool
	countLongestLine bool
}

func getFilesAndFlags() ([]string, Flags) {
	args := os.Args[1:]

	flags := Flags{
		countLines:       false,
		countWords:       false,
		countBytes:       false,
		countRunes:       false,
		countLongestLine: false,
	}

	rune_l := []rune("l")[0]
	rune_w := []rune("w")[0]
	rune_c := []rune("c")[0]
	rune_m := []rune("m")[0]
	rune_L := []rune("L")[0]
	rune_dash := []rune("-")[0]

	argindex := 0
notAFlag:
	for len(args)-1 >= argindex {
		flag := args[argindex]
		if !strings.HasPrefix(flag, "-") {
			break notAFlag
		}

		possibleFlags := []rune(flag)
		pastFirstDash := false
		for _, currentLetter := range possibleFlags {
			if currentLetter == rune_l {
				flags.countLines = true
			} else if currentLetter == rune_w {
				flags.countWords = true
			} else if currentLetter == rune_c {
				flags.countBytes = true
			} else if currentLetter == rune_m {
				flags.countRunes = true
			} else if currentLetter == rune_L {
				flags.countLongestLine = true
			} else if currentLetter == rune_dash {
				if pastFirstDash {
					fmt.Fprintln(os.Stderr, "wc: invalid option -- \"-\"")
					os.Exit(1)
				}
				pastFirstDash = true
				continue
			} else {
				fmt.Fprintf(os.Stderr, "wc: invalid option -- \"%v\"\n", currentLetter)
				os.Exit(1)
			}
		}

		argindex++
	}

	if !(flags.countLines ||
		flags.countWords ||
		flags.countBytes ||
		flags.countRunes ||
		flags.countLongestLine) {
		flags.countLines = true
		flags.countWords = true
		flags.countBytes = true
	}

	return args[argindex:], flags
}
