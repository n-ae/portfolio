using MySql.Data.MySqlClient;
using System.Data;
using System.Data.SqlClient;

namespace Connection.Identifier.Quoting
{
    public static class Extension
    {
        public static char StartCharacter(this IDbConnection connection)
        {
            switch (connection.GetConnectionType())
            {
                case ConnectionType.MsSql:
                    return '[';
                case ConnectionType.MySql:
                    return '`';
                case ConnectionType.Other:
                default:
                    return '"';
            }
        }

        public static char EndCharacter(this IDbConnection connection)
        {
            switch (connection.GetConnectionType())
            {
                case ConnectionType.MsSql:
                    return ']';
                case ConnectionType.MySql:
                case ConnectionType.Other:
                default:
                    return connection.StartCharacter();
            }
        }

        public static string QuoteIdentifier(this IDbConnection connection, string identifier)
        {
            var startChar = connection.StartCharacter();
            var endChar = connection.EndCharacter();

            var escapedIdentifier = identifier
                .EscapeByRepeating(startChar)
                .EscapeByRepeating(endChar)
                ;
            var result = $"{startChar}{escapedIdentifier}{endChar}";
            return result;
        }

        private static string EscapeByRepeating(this string instance, char toBeEscaped)
        {
            return instance.Replace($"{toBeEscaped}", $"{toBeEscaped}{toBeEscaped}");
        }

        private static ConnectionType GetConnectionType(this IDbConnection connection)
        {
            var connectionType = connection.GetType();
            if (connectionType.IsAssignableFrom(typeof(SqlConnection)))
            {
                return ConnectionType.MsSql;
            }
            else if (connectionType.IsAssignableFrom(typeof(MySqlConnection)))
            {
                return ConnectionType.MySql;
            }
            else
            {
                return ConnectionType.Other;
            }
        }
    }
}
