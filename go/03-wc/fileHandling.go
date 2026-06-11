package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"unicode"
	"unicode/utf8"
)

type FileCounts struct {
	fileName    string
	lineCount   int
	wordCount   int
	byteCount   int
	runeCount   int
	longestLine int
}

func readFile(fileName string) (int, *os.File) {
	file, err := os.Open(fileName)
	if err != nil {
		fmt.Fprintln(os.Stderr, "wc:", err)
		return 1, nil
	}

	return 0, file
}

func prosessFile(file *os.File, fileName string) (int, FileCounts) {
	reader := bufio.NewReader(file)
	counts := FileCounts{
		fileName:    fileName,
		lineCount:   0,
		wordCount:   0,
		byteCount:   0,
		runeCount:   0,
		longestLine: 0,
	}

	defer file.Close()

	eofReached := false
	for !eofReached {
		lineAsBytes, err := reader.ReadBytes('\n')
		if err == io.EOF {
			eofReached = true
		} else if err != nil {
			fmt.Fprintln(os.Stderr, "wc:", err)
			return 1, counts
		}

		counts.byteCount = counts.byteCount + len(lineAsBytes)
		counts.runeCount = counts.runeCount + utf8.RuneCount(lineAsBytes)
		lineAsString := string(lineAsBytes)
		lastRuneWasWhitespace := true
		for _, rune := range lineAsString {
			currentRuneIsWhitespace := unicode.IsSpace(rune)
			
			if lastRuneWasWhitespace && !currentRuneIsWhitespace {
				counts.wordCount++
			}
			
			lastRuneWasWhitespace = currentRuneIsWhitespace
		}
		if !eofReached {
			counts.lineCount++
		}
		// handle longest line both for files with new line as \r\n and \n also handle end of file
		if !eofReached && len(lineAsBytes) > 1 && counts.longestLine < len(lineAsBytes) -2 {
			if lineAsBytes[len(lineAsBytes)-2] == '\r' {
				counts.longestLine = len(lineAsBytes[:len(lineAsBytes)-2])
			} else if !eofReached && counts.longestLine < len(lineAsBytes) -1 {
				counts.longestLine = len(lineAsBytes[:len(lineAsBytes)-1])
			} else if counts.longestLine < len(lineAsBytes) {
				counts.longestLine = len(lineAsBytes)
			}
		}
	}
	
	return 0, counts
}
