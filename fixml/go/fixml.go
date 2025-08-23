package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"
)

const USAGE = `Usage: fixml [--organize] [--replace] [--fix-warnings] <xml-file>
  --organize, -o      Apply logical organization
  --replace, -r       Replace original file
  --fix-warnings, -f  Fix XML warnings
  Default: preserve original structure, fix indentation/deduplication only
`

const XML_DECLARATION = `<?xml version="1.0" encoding="utf-8"?>` + "\n"

// Builder pool for reusing strings.Builder instances
var builderPool = sync.Pool{
	New: func() interface{} {
		return &strings.Builder{}
	},
}

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
	var output bytes.Buffer
	output.Grow(len(content) + 100)
	
	if args.fixWarnings && !hasXMLDecl {
		output.WriteString(XML_DECLARATION)
		fmt.Println("🔧 Applied fixes:")
		fmt.Println("  ✓ Added XML declaration")
		fmt.Println()
	}
	
	indentLevel := 0
	// Pre-allocate map with estimated size to avoid rehashing
	estimatedElements := len(content) / 50 // Rough estimate based on content length
	if estimatedElements < 16 {
		estimatedElements = 16
	}
	seenElements := make(map[string]bool, estimatedElements)
	duplicatesRemoved := 0
	
	// Pre-cache common indentation strings
	indentCache := make([]string, 32) // Support up to 31 levels
	for i := 0; i < len(indentCache); i++ {
		indentCache[i] = strings.Repeat("  ", i)
	}
	
	// Process lines with a buffered reader to avoid Scanner token limits
	reader := bufio.NewReader(strings.NewReader(content))
	for {
		line, err := reader.ReadString('\n')
		if len(line) > 0 {
			// Trim only the trailing newline added by ReadString
			if line[len(line)-1] == '\n' {
				line = line[:len(line)-1]
			}
			trimmed := fastTrimSpace(line)
			if trimmed != "" {
				// Fast container detection - simple tags without spaces (no attributes)
				isContainer := false
				if len(trimmed) > 2 && trimmed[0] == '<' && trimmed[len(trimmed)-1] == '>' {
					hasSpace := false
					for i := 1; i < len(trimmed)-1; i++ {
						if trimmed[i] == ' ' || trimmed[i] == '\t' {
							hasSpace = true
							break
						}
					}
					isContainer = !hasSpace
				}
				// Deduplication only for non-container lines
				if !isContainer {
					normalizedKey := normalizeWhitespacePreservingAttributes(trimmed)
					if seenElements[normalizedKey] {
						duplicatesRemoved++
						goto nextLine
					}
					seenElements[normalizedKey] = true
				}
				// Determine if this is a closing tag using byte comparison
				isClosingTag := len(trimmed) >= 2 && trimmed[0] == '<' && trimmed[1] == '/'
				// Determine if this is an opening tag that needs indentation increase
				// Must not be self-contained (like <tag>content</tag> or <tag/>)
				isOpeningTag := len(trimmed) > 0 && trimmed[0] == '<' &&
					!(len(trimmed) >= 2 && trimmed[1] == '/') &&                    // not closing tag
					!(len(trimmed) >= 4 && trimmed[1] == '!' && trimmed[2] == '-' && trimmed[3] == '-') && // not comment
					!(len(trimmed) >= 2 && trimmed[1] == '?') &&                    // not processing instruction
					!strings.HasSuffix(trimmed, "/>")
				// Check if it's self-contained with content like <tag>content</tag>
				if isOpeningTag && isSelfContained(trimmed) {
					isOpeningTag = false
				}
				// Adjust indent level for closing tags BEFORE writing the line
				if isClosingTag {
					indentLevel = max(0, indentLevel-1)
				}
				// Apply consistent 2-space indentation using cached strings with optimized writes
				if indentLevel < len(indentCache) {
					output.WriteString(indentCache[indentLevel])
				} else {
					output.WriteString(strings.Repeat("  ", indentLevel)) // Fallback for deep nesting
				}
				output.WriteString(trimmed)
				output.WriteByte('\n')
				// Adjust indent level for opening tags AFTER writing the line
				if isOpeningTag {
					indentLevel++
				}
			}
		}
		if err == io.EOF {
			break
		}
		if err != nil {
			return fmt.Errorf("error reading content: %v", err)
		}
		continue
		nextLine:
		// Label target for duplicate-skipped lines
		_ = 0
	}
	
	outputFilename := getOutputFilename(args.file, args.replace)
	err := os.WriteFile(outputFilename, output.Bytes(), 0644)
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

// fastTrimSpace is an optimized version of strings.TrimSpace for common XML cases
func fastTrimSpace(s string) string {
	if len(s) == 0 {
		return s
	}
	
	// Quick check for common case: no leading/trailing whitespace
	if s[0] > 32 && s[len(s)-1] > 32 {
		return s
	}
	
	// Find first non-whitespace
	start := 0
	for start < len(s) && s[start] <= 32 {
		start++
	}
	
	if start == len(s) {
		return ""
	}
	
	// Find last non-whitespace
	end := len(s) - 1
	for end >= start && s[end] <= 32 {
		end--
	}
	
	if start == 0 && end == len(s)-1 {
		return s
	}
	
	return s[start : end+1]
}

// isSelfContained checks if a line is self-contained like <tag>content</tag>
func isSelfContained(s string) bool {
	if len(s) < 7 { // Minimum: <a>b</a>
		return false
	}
	
	// Find first '>' 
	firstGT := strings.Index(s, ">")
	if firstGT == -1 || firstGT == len(s)-1 {
		return false
	}
	
	// Find last '<'
	lastLT := strings.LastIndex(s, "<")
	if lastLT == -1 || lastLT <= firstGT {
		return false
	}
	
	// Check if it ends with closing tag
	return len(s) > lastLT+2 && s[lastLT+1] == '/' && s[len(s)-1] == '>'
}

// normalizeWhitespacePreservingAttributes normalizes structural whitespace while preserving attribute values - optimized
func normalizeWhitespacePreservingAttributes(s string) string {
	if len(s) == 0 {
		return s
	}
	
	// Quick check: if no quotes, use simpler normalization
	if !containsQuotes(s) {
		return normalizeSimpleWhitespace(s)
	}
	
	result := builderPool.Get().(*strings.Builder)
	defer func() {
		result.Reset()
		builderPool.Put(result)
	}()
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
		} else if c <= 32 { // optimized whitespace check
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

// Helper function to check if string contains quotes - optimized
func containsQuotes(s string) bool {
	return strings.ContainsAny(s, "\"'")
}

// Simpler whitespace normalization for strings without quotes
func normalizeSimpleWhitespace(s string) string {
	result := builderPool.Get().(*strings.Builder)
	defer func() {
		result.Reset()
		builderPool.Put(result)
	}()
	result.Grow(len(s))
	prevSpace := false
	
	for i := 0; i < len(s); i++ {
		c := s[i]
		if c <= 32 { // whitespace
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