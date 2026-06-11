package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	status := 0
	files, flags := getFilesAndFlags()

	countsList := []FileCounts{}
	if len(files) == 0 {
		prosessStatus, counts := prosessFile(os.Stdin, "")

		countsList = append(countsList, counts)

		if status != 1 {
			status = prosessStatus
		}
	} else {
		totalCounts := FileCounts{
			fileName:    "total",
			lineCount:   0,
			wordCount:   0,
			byteCount:   0,
			runeCount:   0,
			longestLine: 0,
		}

		for _, fileName := range files {
			readStatus, file := readFile(fileName)
			if readStatus == 1 {
				status = readStatus
				continue
			}

			prosessStatus, counts := prosessFile(file, fileName)
			if prosessStatus == 1 {
				status = prosessStatus
				continue
			}

			countsList = append(countsList, counts)

			if len(files) > 1 {
				totalCounts.lineCount = totalCounts.lineCount + counts.lineCount
				totalCounts.wordCount = totalCounts.wordCount + counts.wordCount
				totalCounts.byteCount = totalCounts.byteCount + counts.byteCount
				totalCounts.runeCount = totalCounts.runeCount + counts.runeCount
				if totalCounts.longestLine < counts.longestLine {
					totalCounts.longestLine = counts.longestLine
				}
			}
		}

		if len(files) > 1 {
			countsList = append(countsList, totalCounts)
		}
	}

	largestDigitCount := getLargestDigitCount(countsList, flags)

	for _, count := range countsList {
		text := ""
		if flags.countLines {
			text = text + addCount(count.lineCount, largestDigitCount)
		}
		if flags.countWords {
			text = text + addCount(count.wordCount, largestDigitCount)
		}
		if flags.countBytes {
			text = text + addCount(count.byteCount, largestDigitCount)
		}
		if flags.countRunes {
			text = text + addCount(count.runeCount, largestDigitCount)
		}
		if flags.countLongestLine {
			text = text + addCount(count.longestLine, largestDigitCount)
		}
		if len(files) != 0 {
			text = text + count.fileName
		}

		fmt.Println(text)
	}

	os.Exit(status)
}

func addCount(currentCount int, totalNumberOfRunes int) string {
	currentWordCountString := strconv.Itoa(currentCount)
	extraWhiteSpace := strings.Repeat(" ", totalNumberOfRunes-len(currentWordCountString))
	return extraWhiteSpace + currentWordCountString + " "
}

func getLargestDigitCount(countsList []FileCounts, flags Flags) int {
	largestDigitCount := 0
	lastItem := countsList[len(countsList)-1]

	lineCountDigitCount := len(strconv.Itoa(lastItem.lineCount))
	if flags.countLines && lineCountDigitCount > largestDigitCount {
		largestDigitCount = lineCountDigitCount
	}
	wordCountDigitCount := len(strconv.Itoa(lastItem.wordCount))
	if flags.countWords && wordCountDigitCount > largestDigitCount {
		largestDigitCount = wordCountDigitCount
	}
	byteCountDigitCount := len(strconv.Itoa(lastItem.byteCount))
	if flags.countBytes && byteCountDigitCount > largestDigitCount {
		largestDigitCount = byteCountDigitCount
	}
	runeCountDigitCount := len(strconv.Itoa(lastItem.runeCount))
	if flags.countRunes && runeCountDigitCount > largestDigitCount {
		largestDigitCount = runeCountDigitCount
	}
	longestLineCountDigitCount := len(strconv.Itoa(lastItem.longestLine))
	if flags.countLongestLine && longestLineCountDigitCount > largestDigitCount {
		largestDigitCount = longestLineCountDigitCount
	}

	return largestDigitCount
}
