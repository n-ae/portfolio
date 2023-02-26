using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Model.Data.Interface;
using Model.Interface;
using MySql.Data.MySqlClient;

namespace Repository
{
    public class MetaRepository : ICollectionRepository<IMeta>
    {
        private readonly ArticleContext _context;

        public MetaRepository(ArticleContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<IMeta>> ReadAsync()
        {
            var rows = await _context.Meta.ToListAsync();
            return rows;
        }

        public async Task<IEnumerable<IMeta>> SearchAsync(string pattern)
        {
            var search = new Search(_context);
            var searchSql = search.SearchStatement();

            await using var transaction = await _context.Database.BeginTransactionAsync();

            var parameter = new MySqlParameter(Search.VariableName, pattern);
            var rows = _context.Meta.FromSqlRaw(searchSql, parameter);

            return rows;
        }
    }
}