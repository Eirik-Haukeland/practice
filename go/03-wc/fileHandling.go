package main

import (
	"bufio"
	"fmt"
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
	scanner := bufio.NewScanner(file)
	counts := FileCounts{
		fileName:    fileName,
		lineCount:   0,
		wordCount:   0,
		byteCount:   0,
		runeCount:   0,
		longestLine: 0,
	}

	defer file.Close()
	for scanner.Scan() {
		lineAsBytes := scanner.Bytes()

		counts.lineCount++
		counts.byteCount = counts.byteCount + len(lineAsBytes)
		counts.runeCount = counts.runeCount + utf8.RuneCount(lineAsBytes)
		if counts.longestLine < len(lineAsBytes) {
			counts.longestLine = len(lineAsBytes)
		}
		lineAsString := string(lineAsBytes)
		lastRuneWasWhitespace := true
		for _, rune := range lineAsString {
			currentRuneIsWhitespace := unicode.IsSpace(rune)

			if lastRuneWasWhitespace && !currentRuneIsWhitespace {
				counts.wordCount++
			}

			lastRuneWasWhitespace = currentRuneIsWhitespace
		}
	}

	scannerError := scanner.Err()
	if scannerError != nil {
		fmt.Fprintf(os.Stderr, "wc:", scannerError)
		return 1, counts
	}

	return 0, counts
}
