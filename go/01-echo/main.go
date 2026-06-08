package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	args := os.Args

	noNewLine := false
	allowEscapes := false
	index := 1
itsText:
	for len(args) >= index {
		flag := args[index]
		if !strings.HasPrefix(flag, "-") {
			break itsText
		}

		possibleNoNewLine := noNewLine
		possibleAllowEscapes := allowEscapes
		possibleFlags := []rune(flag)
		runeDash := []rune("-")[0]
		runen := []rune("n")[0]
		runee := []rune("e")[0]
		runeE := []rune("E")[0]
		pastFirstDash := false
		for _, currentLetter := range possibleFlags {
			if currentLetter == runen {
				possibleNoNewLine = true
			} else if currentLetter == runee {
				possibleAllowEscapes = true
			} else if currentLetter == runeE {
				possibleAllowEscapes = false
			} else if currentLetter == runeDash {
				if pastFirstDash {
					break itsText
				}
				pastFirstDash = true
				continue
			} else {
				break itsText
			}
		}

		noNewLine = possibleNoNewLine
		allowEscapes = possibleAllowEscapes
		index++
	}

	var text string
	if len(args) > index {
		text = strings.Join(args[index:], " ")
	} else {
		text = ""
	}

	if allowEscapes {
		segments := []string{"\\t", "\\\\", "\\n", "\\a", "\\b", "\\r", "\\v", "\\f"}
		segmentDictionary := map[string]string{
			"\\t":  "\t",
			"\\\\": "\\",
			"\\n":  "\n",
			"\\a":  "\a",
			"\\b":  "\b",
			"\\r":  "\r",
			"\\v":  "\v",
			"\\f":  "\f",
		}
		escape(text, segments, segmentDictionary)
	} else {
		fmt.Print(text)
	}
	if !noNewLine {
		fmt.Print("\n")
	}
}

func escape(text string, sequences []string, segmentDictionary map[string]string) {
	var currentSequence string
	var remainingSequences []string
	if len(sequences) > 1 {
		currentSequence, remainingSequences = sequences[0], sequences[1:]
	} else {
		currentSequence = sequences[0]
	}

	if strings.Contains(text, currentSequence) {
		i := 0
		splitText := strings.Split(text, currentSequence)
		for len(splitText) >= i+1 {
			currentTextSegment := splitText[i]
			escape(currentTextSegment, remainingSequences, segmentDictionary)
			if len(splitText) > i+1 {
				fmt.Print(segmentDictionary[currentSequence])
			}
			i = i + 1
		}
	} else if len(remainingSequences) >= 1 {
		escape(text, remainingSequences, segmentDictionary)
	} else {
		fmt.Print(text)
	}
}
