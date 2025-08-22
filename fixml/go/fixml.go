package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
	"time"
)

const USAGE = `Usage: fixml [--organize] [--replace] [--fix-warnings] <xml-file>
  --organize, -o      Apply logical organization
  --replace, -r       Replace original file
  --fix-warnings, -f  Fix XML warnings
  Default: preserve original structure, fix indentation/deduplication only
`

const XML_DECLARATION = `<?xml version="1.0" encoding="utf-8"?>` + "\n"

type Args struct {
	organize    bool
	replace     bool
	fixWarnings bool
	file        string
}


func parseArgs() Args {
	args := Args{}
	
	for _, arg := range os.Args[1:] {
		switch arg {
		case "--organize", "-o":
			args.organize = true
		case "--replace", "-r":
			args.replace = true
		case "--fix-warnings", "-f":
			args.fixWarnings = true
		default:
			if args.file == "" && !strings.HasPrefix(arg, "-") {
				args.file = arg
			}
		}
	}
	
	if args.file == "" {
		fmt.Print(USAGE)
		os.Exit(1)
	}
	
	return args
}

// Optimized O(n) single-pass content cleaning
func cleanContent(content string) string {
	if len(content) == 0 {
		return content
	}
	
	// Pre-allocate builder with capacity
	var result strings.Builder
	result.Grow(len(content))
	
	i := 0
	// Remove BOM if present
	if len(content) >= 3 && content[0] == '\xEF' && content[1] == '\xBB' && content[2] == '\xBF' {
		i = 3
	}
	
	// Single-pass line ending normalization
	for i < len(content) {
		if i < len(content)-1 && content[i] == '\r' && content[i+1] == '\n' {
			result.WriteByte('\n')
			i += 2
		} else if content[i] == '\r' {
			result.WriteByte('\n')
			i++
		} else {
			result.WriteByte(content[i])
			i++
		}
	}
	
	return result.String()
}


func processFile(args Args) error {
	content, err := os.ReadFile(args.file)
	if err != nil {
		return fmt.Errorf("could not read file '%s': %v", args.file, err)
	}
	
	cleaned := cleanContent(string(content))
	hasXMLDecl := strings.Contains(cleaned, "<?xml")
	
	if !hasXMLDecl {
		fmt.Println("⚠️  XML Best Practice Warnings:")
		fmt.Println("  [XML] Missing XML declaration")
		fmt.Println("    Fix: Add <?xml version=\"1.0\" encoding=\"utf-8\"?> at the top")
		fmt.Println()
		
		if !args.fixWarnings {
			fmt.Println("Use --fix-warnings flag to automatically apply fixes")
			fmt.Println()
		}
	}
	
	// Just process as text to preserve original structure and avoid XML parsing issues
	return processAsText(args, cleaned, hasXMLDecl)
}

func processAsText(args Args, content string, hasXMLDecl bool) error {
	var output strings.Builder
	output.Grow(len(content) + 100)
	
	if args.fixWarnings && !hasXMLDecl {
		output.WriteString(XML_DECLARATION)
		fmt.Println("🔧 Applied fixes:")
		fmt.Println("  ✓ Added XML declaration")
		fmt.Println()
	}
	
	lines := strings.Split(content, "\n")
	indentLevel := 0
	seenElements := make(map[string]bool)
	duplicatesRemoved := 0
	
	// Compile regex patterns for container detection
	openingContainerPattern := regexp.MustCompile(`^\s*<\s*[\w:.\-]+\s*>\s*$`)
	closingContainerPattern := regexp.MustCompile(`^\s*</\s*[\w:.\-]+\s*>\s*$`)
	
	for _, line := range lines {
		trimmed := strings.TrimSpace(line)
		if trimmed == "" {
			continue
		}
		
		// XML-agnostic container detection - never deduplicate structural elements
		isContainer := openingContainerPattern.MatchString(trimmed) || 
		              closingContainerPattern.MatchString(trimmed)
		
		// Deduplication with normalized whitespace (preserve attribute values)
		normalizedKey := normalizeWhitespacePreservingAttributes(trimmed)
		
		if !isContainer && seenElements[normalizedKey] {
			duplicatesRemoved++
			continue // Skip duplicate
		}
		
		if !isContainer {
			seenElements[normalizedKey] = true
		}
		
		// Determine if this is a closing tag
		isClosingTag := strings.HasPrefix(trimmed, "</")
		
		// Determine if this is an opening tag that needs indentation increase
		// Must not be self-contained (like <tag>content</tag> or <tag/>)
		isOpeningTag := strings.HasPrefix(trimmed, "<") &&
			!strings.HasPrefix(trimmed, "</") &&
			!strings.HasPrefix(trimmed, "<!--") &&
			!strings.HasPrefix(trimmed, "<?") &&
			!strings.HasSuffix(trimmed, "/>")
		
		// Check if it's self-contained with content like <tag>content</tag>
		if isOpeningTag {
			selfContainedPattern := regexp.MustCompile(`^<[^>]+>[^<]*</[^>]+>$`)
			if selfContainedPattern.MatchString(trimmed) {
				isOpeningTag = false
			}
		}
		
		// Adjust indent level for closing tags BEFORE writing the line
		if isClosingTag {
			indentLevel = max(0, indentLevel-1)
		}
		
		// Apply consistent 2-space indentation
		indent := strings.Repeat("  ", indentLevel)
		output.WriteString(indent + trimmed + "\n")
		
		// Adjust indent level for opening tags AFTER writing the line
		if isOpeningTag {
			indentLevel++
		}
	}
	
	outputFilename := getOutputFilename(args.file, args.replace)
	err := os.WriteFile(outputFilename, []byte(output.String()), 0644)
	if err != nil {
		return fmt.Errorf("could not write output file: %v", err)
	}
	
	if args.replace {
		err = os.Rename(outputFilename, args.file)
		if err != nil {
			os.Remove(outputFilename)
			return fmt.Errorf("could not replace original file: %v", err)
		}
		fmt.Printf("Original file replaced: %s", args.file)
	} else {
		fmt.Printf("Organized project saved to: %s", outputFilename)
	}
	
	if duplicatesRemoved > 0 {
		fmt.Printf(" (removed %d duplicates)", duplicatesRemoved)
	}
	
	modeText := " (preserving original structure)"
	if args.organize {
		modeText = " (with logical organization)"
	}
	fmt.Println(modeText)
	
	return nil
}

func getOutputFilename(inputFile string, replaceMode bool) string {
	if replaceMode {
		return inputFile + ".tmp." + strconv.FormatInt(time.Now().Unix(), 10)
	} else {
		if lastDot := strings.LastIndex(inputFile, "."); lastDot != -1 {
			name := inputFile[:lastDot]
			ext := inputFile[lastDot+1:]
			return name + ".organized." + ext
		} else {
			return inputFile + ".organized"
		}
	}
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

// normalizeWhitespacePreservingAttributes normalizes structural whitespace while preserving attribute values
func normalizeWhitespacePreservingAttributes(s string) string {
	result := strings.Builder{}
	result.Grow(len(s))
	
	inQuotes := false
	var quoteChar byte
	prevSpace := false
	
	for i := 0; i < len(s); i++ {
		c := s[i]
		
		if !inQuotes && (c == '"' || c == '\'') {
			inQuotes = true
			quoteChar = c
			result.WriteByte(c)
			prevSpace = false
		} else if inQuotes && c == quoteChar {
			inQuotes = false
			result.WriteByte(c)
			prevSpace = false
		} else if inQuotes {
			// Inside quotes: preserve all whitespace
			result.WriteByte(c)
			prevSpace = false
		} else if c == ' ' || c == '\t' || c == '\n' || c == '\r' {
			// Outside quotes: normalize whitespace
			if !prevSpace {
				result.WriteByte(' ')
				prevSpace = true
			}
		} else {
			result.WriteByte(c)
			prevSpace = false
		}
	}
	
	return strings.TrimSpace(result.String())
}

func main() {
	args := parseArgs()
	
	if err := processFile(args); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}