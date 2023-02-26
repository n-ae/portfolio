using System.Collections.Generic;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using Model.Data;

namespace Repository
{
    internal class Search
    {
        private const string TmpTableName = "tmp_match";
        public const string VariableName = "var_pattern";
        private static readonly string PatternVariableSqlName = $"@{VariableName}";

        private readonly string _charFriendlyPatternVariableName =
            $"CONCAT(UPPER(REPLACE({PatternVariableSqlName}, 'i', 'İ')), ' ', LOWER(REPLACE({PatternVariableSqlName}, 'I', 'ı')))";

        private static readonly List<string> Aliases = new List<string> {"m", "t", "a"};
        private readonly ArticleContext _context;

        public Search(ArticleContext context)
        {
            _context = context;
        }

        public string SearchStatement()
        {
            var staticMetaTableName = TableName<Meta>();
            var staticMetaIdColumn = EntityType<Meta>().FindPrimaryKey().Properties[0].Name;
            var staticBeginningStatements = $@"

-- enforce single field data type while still being agnostic to the data type
DROP TEMPORARY TABLE IF EXISTS {TmpTableName};
CREATE TEMPORARY TABLE {TmpTableName}
SELECT {staticMetaIdColumn} AS {Aliases[2]} FROM {staticMetaTableName} LIMIT 0;

";

            var staticEndStatement = $@"

SELECT {Aliases[0]}.*
FROM {staticMetaTableName} {Aliases[0]}
JOIN {TmpTableName} {Aliases[1]} ON {Aliases[0]}.{staticMetaIdColumn} = {Aliases[1]}.{Aliases[2]}
;
";


            var searchSql =
                $@"
{staticBeginningStatements}


-- if not full word

{StatementForSearchPerTable<Meta>()}
{StatementForSearchPerTable<Context>()}

{staticEndStatement}
";

            return searchSql;
        }

        private string TableName<T>()
        {
            return EntityType<T>().GetTableName();
        }

        private IEntityType EntityType<T>()
        {
            return _context.Model.FindEntityType(typeof(T));
        }

        private string StatementForSearchPerTable<T>()
        {
            ;
            var searchedTableName = TableName<T>();
            var searchedMetaIdColumn = typeof(T).IsAssignableFrom(typeof(Meta))
                ? EntityType<Meta>().FindPrimaryKey().Properties[0].Name
                : EntityType<T>().GetForeignKeys()
                    .Intersect(EntityType<Meta>().FindPrimaryKey().GetReferencingForeignKeys())
                    .FirstOrDefault()
                    ?.Properties[0].Name;

            var tmpTableNameReopened = $"{TmpTableName}_2";


            var stringColumns = EntityType<T>().GetProperties()
                .Where(p => p.ClrType.IsAssignableFrom(typeof(string)))
                .Select(p => p.GetColumnName());

            var preparedMatchColumns = string.Join(", ", stringColumns);

            var insertNewMatches = $@"
INSERT INTO {TmpTableName}
SELECT {Aliases[0]}.{searchedMetaIdColumn}
FROM {searchedTableName} {Aliases[0]}
LEFT JOIN {tmpTableNameReopened} {Aliases[1]} ON {Aliases[0]}.{searchedMetaIdColumn} = {Aliases[1]}.{Aliases[2]}
WHERE TRUE
    -- don't look for already included
    AND {Aliases[1]}.{Aliases[2]} IS NULL
";

            var updateReopened = $@"
-- why: can't reopen a temp table
DROP TEMPORARY TABLE IF EXISTS {tmpTableNameReopened};
CREATE TEMPORARY TABLE {tmpTableNameReopened} LIKE {TmpTableName};
INSERT INTO {tmpTableNameReopened} SELECT * FROM {TmpTableName};
";
            var updateReopenedAndInsert = $@"
{updateReopened}
{insertNewMatches}
";
            var statement = $@"
{updateReopenedAndInsert}
    AND MATCH({preparedMatchColumns}) AGAINST({_charFriendlyPatternVariableName})
;

-- if not full word
";
            statement = stringColumns.Aggregate(statement, (current, stringColumn) => current + $@"
{updateReopenedAndInsert}
    AND {Aliases[0]}.{stringColumn} REGEXP {PatternVariableSqlName}
;
");
            return statement;
        }
    }
}