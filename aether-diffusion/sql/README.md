# NBA Fantasy Sports Database - SQL Query Organization

## File-Based SQL Structure

This directory contains all SQL queries organized in individual files for better maintainability, version control, and developer experience.

## Directory Structure

```
sql/
├── players/                    # Player-related queries
│   ├── get_all_players.v1.sql
│   ├── get_players_filtered.v1.sql
│   └── get_player_by_id.v1.sql
├── teams/                      # Team-related queries
│   ├── get_all_teams.v1.sql
│   ├── get_teams_filtered.v1.sql
│   └── get_team_roster.v1.sql
├── stats/                      # Statistics and counting queries
│   ├── get_player_count.v1.sql
│   ├── get_active_player_count.v1.sql
│   ├── get_team_count.v1.sql
│   ├── get_position_assignment_count.v1.sql
│   ├── get_teams_with_players_count.v1.sql
│   └── get_conference_stats.v1.sql
└── health/                     # Health check queries
    └── check_database_health.v1.sql
```

## File Naming Convention

- **Format**: `{query_name}.v{version}.sql`
- **Examples**: 
  - `get_all_players.v1.sql` (version 1.0)
  - `get_players_filtered.v2.sql` (version 2.0)
  - `get_team_roster.v1.sql`

## Query File Format

Each SQL file follows this standardized format:

```sql
-- NBA Fantasy Sports Database
-- Query: query_name_here
-- Version: 1.0
-- Description: Brief description of what this query does
-- Parameters: (if applicable)
--   $1 (param_name): Parameter description
--   $2 (param_name): Parameter description  
-- Returns: column1, column2, column3

SELECT actual_sql_query_here
FROM tables
WHERE conditions;
```

## Benefits of File-Based Organization

### ✅ Developer Experience
- **SQL Syntax Highlighting**: Full IDE support with `.sql` extensions
- **SQL Linting**: Can run `sqlformat`, `sqlfluff`, `pg_format` on individual files
- **Auto-completion**: Database tools can provide schema-aware completion
- **Easy Navigation**: Jump to specific queries quickly in IDE

### ✅ Version Control
- **Granular History**: Each query has independent Git history
- **Clear Diffs**: See exactly what changed in each query
- **Atomic Changes**: Modify one query without affecting others
- **Easy Reviews**: PR reviews focus on specific query changes

### ✅ Individual Versioning
- **Progressive Updates**: `get_players.v1.sql` → `get_players.v2.sql`
- **Backward Compatibility**: Keep old versions during migrations
- **A/B Testing**: Test new query versions alongside existing ones
- **Rollback Safety**: Easy to revert to previous query versions

### ✅ Modular Organization
- **Logical Grouping**: Related queries in same directory
- **Clear Boundaries**: Separate concerns (players vs teams vs stats)
- **Easy Discovery**: Find queries by browsing directory structure
- **Documentation**: Each directory can have specific README files

### ✅ Database Migration Patterns
- **Familiar Workflow**: Similar to database migration file patterns
- **Sequential Versioning**: Clear upgrade paths for query changes
- **Migration Scripts**: Can generate migration scripts from query diffs
- **Schema Evolution**: Track query changes alongside schema changes

## Usage Across Languages

### Go
```go
err := InitializeFileSQL("../sql")
query := FileSQL.MustGetQuery("get_all_players")
rows, err := db.Query(query)
```

### Rust
```rust
let sql_loader = FileSQLLoader::new("../sql")?;
let query = sql_loader.get_query("get_all_players")?;
let players = sqlx::query_as(&query).fetch_all(&pool).await?;
```

### Zig
```zig
var sql_loader = try FileSQLLoader.init(allocator, "../sql");
const query = sql_loader.mustGetQuery("get_all_players");
const result = try db.query(query, .{});
```

### Python
```python
sql_loader = FileSQLLoader("../sql")
query = sql_loader.get_query("get_all_players")
cursor.execute(query)
```

## Query Evolution Examples

### Version 1.0 → 1.1 (Minor Enhancement)
```sql
-- get_players.v1.sql
SELECT p.id, p.name FROM players p;

-- get_players.v1.1.sql  
SELECT p.id, p.name, p.active FROM players p;
```

### Version 1.x → 2.0 (Breaking Change)
```sql
-- get_players.v1.sql
SELECT p.id, p.name FROM players p;

-- get_players.v2.sql (performance optimization)
SELECT p.id, p.full_name, t.abbreviation 
FROM players p 
LEFT JOIN teams t ON p.team_id = t.id
ORDER BY p.full_name;
```

## Comparison: Files vs JSON/YAML

| Aspect | Individual Files | JSON/YAML |
|--------|-----------------|------------|
| **Syntax Highlighting** | ✅ Full SQL support | ❌ SQL as strings |
| **Version Control** | ✅ Granular diffs | ❌ Large file conflicts |
| **SQL Tooling** | ✅ Formatters, linters | ❌ No SQL tooling |
| **Individual Versioning** | ✅ Per-query versions | ❌ Global versioning |
| **Code Review** | ✅ Focus on specific changes | ❌ Large file reviews |
| **IDE Support** | ✅ Database completion | ❌ Limited support |
| **File Size** | ✅ Small, focused files | ❌ Large monolithic files |
| **Query Discovery** | ✅ Browse directories | ❌ Search in large files |

## Migration from JSON/YAML

To migrate from the JSON/YAML approach:

1. ✅ **Created** file structure with proper versioning
2. ✅ **Extracted** all queries to individual `.sql` files  
3. ✅ **Built** file-based loader with metadata parsing
4. **Update** applications to use file-based loader
5. **Deprecate** JSON/YAML files once migration is complete

## SQL Development Workflow

1. **Create Query**: Add new `.v1.sql` file with proper metadata
2. **Test Locally**: Use SQL tools to validate syntax and results
3. **Version Control**: Commit individual query file
4. **Code Review**: Reviewers focus on specific query changes
5. **Deploy**: Application loads updated query automatically
6. **Iterate**: Create `.v2.sql` for breaking changes

This file-based approach provides superior developer experience while maintaining the same cross-language compatibility benefits!