package main

import (
	"flag"
	"fmt"
	"strings"
)

func main() {
	flag_no_new_line := flag.Bool("n", false, "passing -n will make echo stop adding a new line")
	flag_allow_char_escape := flag.Bool("e", false, "passing -e will enable character escaping")
	flag_disable_char_escape := flag.Bool("E", false, "passing -E will disable character escaping this is default behavior")
	flag.Parse()

	no_new_line := *flag_no_new_line
	var allow_escapes bool
	if !*flag_disable_char_escape && *flag_allow_char_escape {
		allow_escapes = true
	} else {
		allow_escapes = false
	}

	text := strings.Join(flag.Args(), " ")

	if allow_escapes {
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
	if !no_new_line {
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
