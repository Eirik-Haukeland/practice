package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
)

func main() {
	fileLocations := os.Args[1:]

	var data []byte
	if len(fileLocations) < 1 {
		bytes, err := io.ReadAll(os.Stdin)
		if err != nil {
			fmt.Print("error occurred when opening file \n")
			os.Exit(1)
		}
		data = bytes
	} else {
		data = ReadAllFiles(fileLocations)
	}

	fmt.Print(string(data))
}

func ReadAllFiles(fileLocations []string) []byte {
	var files []byte
	for _, currentFileLocation := range fileLocations {
		currentFileBuffer, err := os.ReadFile(currentFileLocation)
		if err != nil {
			fmt.Printf("error occurred when opening file %q\n", currentFileLocation)
			os.Exit(1)
		}

		for _, bite := range currentFileBuffer {
			files = append(files, bite)
		}
	}

	return files
}
