package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	status := 0
	fileLocations, flags := getFilesAndFlags()

	if len(fileLocations) == 0 {
		fileStatus := prosessFile(os.Stdin, flags)
		if fileStatus == 1 {
			status = 1
		}
	} else {
		for _, fileName := range fileLocations {
			if fileName == "-" {
				fileStatus := prosessFile(os.Stdin, flags)
				if fileStatus == 1 {
					status = 1
				}
				continue
			}
			fileStatus, file := readFile(fileName)
			if fileStatus == 1 {
				status = 1
				continue
			}

			fileStatus = prosessFile(file, flags)
			if fileStatus == 1 {
				status = 1
				continue
			}
		}
	}

	os.Exit(status)
}

type Flags struct {
	addLineNumber               bool
	skipLineNumbersOnEmptyLines bool
	markEndOfLine               bool
	compressMultipleEmptyLines  bool
	showTabs                    bool
}

func getFilesAndFlags() ([]string, Flags) {
	args := os.Args[1:]

	flags := Flags{
		addLineNumber:               false,
		skipLineNumbersOnEmptyLines: false,
		markEndOfLine:               false,
		compressMultipleEmptyLines:  false,
		showTabs:                    false,
	}

	rune_n := []rune("n")[0]
	rune_E := []rune("E")[0]
	rune_b := []rune("b")[0]
	rune_s := []rune("s")[0]
	rune_T := []rune("T")[0]

	argindex := 0
notAFlag:
	for len(args) > 1 && len(args) >= argindex {
		flag := args[argindex]
		if !strings.HasPrefix(flag, "-") {
			break notAFlag
		}

		possibleFlags := []rune(flag)
		runeDash := []rune("-")[0]
		pastFirstDash := false
		for _, currentLetter := range possibleFlags {
			if currentLetter == rune_n {
				flags.addLineNumber = true
			} else if currentLetter == rune_E {
				flags.markEndOfLine = true
			} else if currentLetter == rune_b {
				flags.addLineNumber = true
				flags.skipLineNumbersOnEmptyLines = true
			} else if currentLetter == rune_s {
				flags.compressMultipleEmptyLines = true
			} else if currentLetter == rune_T {
				flags.showTabs = true
			} else if currentLetter == runeDash {
				if pastFirstDash {
					fmt.Fprintln(os.Stderr, "ln 88 cat: invalid option -- \"-\"")
					os.Exit(1)
				}
				pastFirstDash = true
				continue
			} else {
				fmt.Fprintf(os.Stderr, "ln 94 cat: invalid option -- \"%v\"\n", currentLetter)
				os.Exit(1)
			}
		}

		argindex++
	}

	return args[argindex:], flags
}

func readFile(fileName string) (int, *os.File) {
	file, err := os.Open(fileName)
	if err != nil {
		fmt.Fprintln(os.Stderr, "ln 108 cat:", err)
		return 1, nil
	}

	return 0, file
}

func prosessFile(file *os.File, flags Flags) int {
	scanner := bufio.NewScanner(file)
	previousLineWasEmpty := false
	currentLineNumber := 0
	defer file.Close()
	for scanner.Scan() {
		line := scanner.Text()

		// handle line collapsing
		if previousLineWasEmpty && line == "" && flags.compressMultipleEmptyLines {
			continue
		}
		if previousLineWasEmpty && line != "" {
			previousLineWasEmpty = false
		}
		if !previousLineWasEmpty && line == "" {
			previousLineWasEmpty = true
		}

		// handle line numbers
		if flags.addLineNumber && line != "" {
			currentLineNumber = currentLineNumber + 1
			lineNumString := getLineNumber(currentLineNumber)
			line = lineNumString + line
		}
		if flags.addLineNumber && !flags.skipLineNumbersOnEmptyLines && line == "" {
			currentLineNumber = currentLineNumber + 1
			lineNumString := getLineNumber(currentLineNumber)
			line = lineNumString + line
		}

		// mark end of line
		if flags.markEndOfLine {
			line = line + "$"
		}

		// show tabs
		if flags.showTabs {
			line = strings.ReplaceAll(line, "\t", "^I")
		}

		fmt.Println(line)
	}

	scannerError := scanner.Err()
	if scannerError != nil {
		fmt.Fprintf(os.Stderr, "ln 159 cat:", scannerError)
		return 1
	}

	return 0
}

func getLineNumber (currentLineNumber int) string {
	lineNumString := strconv.Itoa(currentLineNumber)
	numOfSpace := 6 - len(lineNumString)
	return strings.Repeat(" ", numOfSpace) + lineNumString + "\t"
}