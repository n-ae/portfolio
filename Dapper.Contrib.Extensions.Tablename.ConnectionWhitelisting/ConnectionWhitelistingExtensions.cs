using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Connection.Identifier.Quoting;

namespace Dapper.Contrib.Extensions.Tablename.ConnectionWhitelisting
{
    public static class ConnectionWhitelistingExtensions
    {
        public static async Task WhitelistDatabaseTablesAsync(this IDbConnection connection)
        {
            const string sql = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES";
            var tableNamesIEnumerable = await connection.QueryAsync<string>(sql);
            var tableNames = tableNamesIEnumerable.AsList().ToArray()
                .Quote(connection)
                ;
            var whitelist = new HashSet<string>(tableNames);

            var preExistingDelegate = SqlMapperExtensions.TableNameMapper;

            SqlMapperExtensions.TableNameMapper = (Type t) =>
            {
                string tableName;
                if (preExistingDelegate == null)
                {
                    tableName = TablenameExtensions.UnquotedTablename(t);
                }
                else
                {
                    tableName = preExistingDelegate(t);
                }
                if (whitelist != null)
                {
                    return whitelist.Contains(tableName.QuoteIdentifier(connection)) ? tableName : throw new Exception($"The tablename {tableName} is not whitelisted!");
                }
                else
                {
                    return tableName;
                }
            };
        }

        private static string[] Quote(this string[] identifiers, IDbConnection connection)
        {
            for (int i = 0; i < identifiers.Length; i++)
            {
                identifiers[i] = identifiers[i].QuoteIdentifier(connection);
            }

            return identifiers;
        }
    }
}
