// NBA Fantasy Sports Database - File-Based SQL Query Loader
// This module provides a more advanced SQL query loader that supports individual .sql files
// with proper version control, syntax highlighting, and modular organization.

package main

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// FileSQLLoader manages loading SQL queries from individual .sql files
type FileSQLLoader struct {
	queries map[string]*SQLQuery
	basePath string
}

// SQLQuery represents a loaded SQL query with metadata
type SQLQuery struct {
	Name        string
	Version     string
	SQL         string
	Description string
	Parameters  []string
	Returns     []string
	FilePath    string
}

// NewFileSQLLoader creates a new file-based SQL loader
func NewFileSQLLoader(basePath string) (*FileSQLLoader, error) {
	loader := &FileSQLLoader{
		queries:  make(map[string]*SQLQuery),
		basePath: basePath,
	}

	err := loader.loadAllQueries()
	if err != nil {
		return nil, fmt.Errorf("failed to load SQL queries: %v", err)
	}

	return loader, nil
}

// loadAllQueries recursively loads all .sql files from the base path
func (fsl *FileSQLLoader) loadAllQueries() error {
	return filepath.Walk(fsl.basePath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Only process .sql files
		if !strings.HasSuffix(info.Name(), ".sql") {
			return nil
		}

		query, err := fsl.parseQueryFile(path)
		if err != nil {
			return fmt.Errorf("failed to parse query file %s: %v", path, err)
		}

		fsl.queries[query.Name] = query
		return nil
	})
}

// parseQueryFile parses a single .sql file and extracts metadata
func (fsl *FileSQLLoader) parseQueryFile(filePath string) (*SQLQuery, error) {
	content, err := os.ReadFile(filePath)
	if err != nil {
		return nil, err
	}

	query := &SQLQuery{
		FilePath: filePath,
	}

	lines := strings.Split(string(content), "\n")
	var sqlLines []string
	inSQL := false

	for _, line := range lines {
		trimmed := strings.TrimSpace(line)
		
		// Parse metadata from comments
		if strings.HasPrefix(trimmed, "--") {
			comment := strings.TrimSpace(strings.TrimPrefix(trimmed, "--"))
			fsl.parseMetadata(query, comment)
		} else if trimmed != "" {
			// Start collecting SQL content
			inSQL = true
			sqlLines = append(sqlLines, line)
		} else if inSQL {
			// Preserve empty lines in SQL
			sqlLines = append(sqlLines, line)
		}
	}

	// Extract query name from filename if not in metadata
	if query.Name == "" {
		query.Name = fsl.extractQueryNameFromPath(filePath)
	}

	// Join SQL lines and clean up
	query.SQL = strings.TrimSpace(strings.Join(sqlLines, "\n"))

	return query, nil
}

// parseMetadata extracts metadata from comment lines
func (fsl *FileSQLLoader) parseMetadata(query *SQLQuery, comment string) {
	switch {
	case strings.HasPrefix(comment, "Query: "):
		query.Name = strings.TrimSpace(strings.TrimPrefix(comment, "Query: "))
	case strings.HasPrefix(comment, "Version: "):
		query.Version = strings.TrimSpace(strings.TrimPrefix(comment, "Version: "))
	case strings.HasPrefix(comment, "Description: "):
		query.Description = strings.TrimSpace(strings.TrimPrefix(comment, "Description: "))
	case strings.HasPrefix(comment, "Parameters:"):
		// Parameters will be on following lines
		return
	case strings.HasPrefix(comment, "Returns:"):
		// Returns will be on following lines  
		return
	case strings.Contains(comment, "($"):
		// Parameter line: --   $1 (team_filter): Filter by team abbreviation (optional)
		query.Parameters = append(query.Parameters, comment)
	}
}

// extractQueryNameFromPath extracts query name from file path
func (fsl *FileSQLLoader) extractQueryNameFromPath(filePath string) string {
	filename := filepath.Base(filePath)
	// Remove .sql extension and version (e.g., "get_players.v1.sql" -> "get_players")
	re := regexp.MustCompile(`^(.+?)\.v\d+\.sql$`)
	matches := re.FindStringSubmatch(filename)
	if len(matches) > 1 {
		return matches[1]
	}
	// Fallback: just remove .sql
	return strings.TrimSuffix(filename, ".sql")
}

// GetQuery returns a SQL query by name
func (fsl *FileSQLLoader) GetQuery(name string) (string, error) {
	query, exists := fsl.queries[name]
	if !exists {
		return "", fmt.Errorf("SQL query '%s' not found", name)
	}
	return query.SQL, nil
}

// MustGetQuery returns a SQL query by name, panics if not found
func (fsl *FileSQLLoader) MustGetQuery(name string) string {
	sql, err := fsl.GetQuery(name)
	if err != nil {
		panic(fmt.Sprintf("Critical SQL query missing: %v", err))
	}
	return sql
}

// GetQueryInfo returns complete query information including metadata
func (fsl *FileSQLLoader) GetQueryInfo(name string) (*SQLQuery, error) {
	query, exists := fsl.queries[name]
	if !exists {
		return nil, fmt.Errorf("SQL query '%s' not found", name)
	}
	return query, nil
}

// ListQueries returns all available query names with their versions
func (fsl *FileSQLLoader) ListQueries() map[string]string {
	result := make(map[string]string)
	for name, query := range fsl.queries {
		result[name] = query.Version
	}
	return result
}

// HasQuery checks if a query exists
func (fsl *FileSQLLoader) HasQuery(name string) bool {
	_, exists := fsl.queries[name]
	return exists
}

// GetQueriesByCategory returns queries grouped by directory/category
func (fsl *FileSQLLoader) GetQueriesByCategory() map[string][]string {
	categories := make(map[string][]string)
	
	for name, query := range fsl.queries {
		// Extract category from file path (e.g., "sql/players/get_players.v1.sql" -> "players")
		relPath, _ := filepath.Rel(fsl.basePath, query.FilePath)
		category := strings.Split(relPath, string(filepath.Separator))[0]
		categories[category] = append(categories[category], name)
	}
	
	return categories
}

// ReloadQueries reloads all queries from disk (useful for development)
func (fsl *FileSQLLoader) ReloadQueries() error {
	fsl.queries = make(map[string]*SQLQuery)
	return fsl.loadAllQueries()
}

// Validate performs validation on all loaded queries
func (fsl *FileSQLLoader) Validate() error {
	if len(fsl.queries) == 0 {
		return fmt.Errorf("no SQL queries loaded")
	}

	// Check for required queries
	required := []string{"get_all_players", "get_all_teams", "get_player_count", "get_team_count"}
	for _, name := range required {
		if !fsl.HasQuery(name) {
			return fmt.Errorf("required SQL query '%s' is missing", name)
		}
	}

	// Validate each query has basic metadata
	for name, query := range fsl.queries {
		if query.SQL == "" {
			return fmt.Errorf("query '%s' has no SQL content", name)
		}
		if query.Version == "" {
			return fmt.Errorf("query '%s' missing version information", name)
		}
	}

	return nil
}

// GetStats returns statistics about loaded queries
func (fsl *FileSQLLoader) GetStats() map[string]interface{} {
	categories := fsl.GetQueriesByCategory()
	
	stats := map[string]interface{}{
		"total_queries": len(fsl.queries),
		"categories":    len(categories),
		"base_path":     fsl.basePath,
	}
	
	for category, queries := range categories {
		stats[fmt.Sprintf("category_%s", category)] = len(queries)
	}
	
	return stats
}

// Global file-based SQL loader instance
var FileSQL *FileSQLLoader

// InitializeFileSQL initializes the file-based SQL loader
func InitializeFileSQL(basePath string) error {
	var err error
	FileSQL, err = NewFileSQLLoader(basePath)
	if err != nil {
		return fmt.Errorf("failed to initialize file-based SQL loader: %v", err)
	}

	err = FileSQL.Validate()
	if err != nil {
		return fmt.Errorf("file-based SQL validation failed: %v", err)
	}

	return nil
}