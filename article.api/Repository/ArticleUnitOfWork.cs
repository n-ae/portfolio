using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Model.Data;
using Model.Interface;

namespace Repository
{
    public class ArticleUnitOfWork : ISingleRepository<Article>
    {
        private readonly ArticleContext _context;

        public ArticleUnitOfWork(ArticleContext context)
        {
            _context = context;
        }

        public async Task<Article> ReadAsync(long id)
        {
            var item = (await (from m in _context.Meta
                    join c in _context.Context on m.Id equals c.MetaId
                    where m.Id == id
                    select new Article
                    {
                        Id = m.Id,
                        Title = m.Title,
                        AuthorFullName = m.AuthorFullName,
                        LastEditedTimestamp = m.LastEditedTimestamp,
                        Body = c.Body
                    }).ToListAsync()).Single()
                ;
            return item;
        }

        public async Task<Article> CreateAsync(Article model)
        {
            var now = DateTime.Now;
            var meta = new Meta
            {
                AuthorFullName = model.AuthorFullName,
                Title = model.Title,
                LastEditedTimestamp = now
            };

            await using var transaction = await _context.Database.BeginTransactionAsync();
            var createEntry = await _context.Meta.AddAsync(meta);
            await _context.SaveChangesAsync();
            var insertedMetaId = createEntry.Property(t => t.Id).CurrentValue;


            var context = new Context
            {
                MetaId = insertedMetaId,
                Body = model.Body
            };
            await _context.Context.AddAsync(context);
            await transaction.CommitAsync();
            await _context.SaveChangesAsync();

            var created = await ReadAsync(insertedMetaId);
            return created;
        }

        public async Task<bool> UpdateAsync(Article model)
        {
            await using var transaction = await _context.Database.BeginTransactionAsync();
            var now = DateTime.Now;

            var meta = await _context.Meta.SingleAsync(t => t.Id == model.Id);
            meta.AuthorFullName = model.AuthorFullName;
            meta.Title = model.Title;
            meta.LastEditedTimestamp = now;
            var stateEntryCount = await _context.SaveChangesAsync();

            var context = _context.Context.Single(r => r.MetaId == model.Id);
            context.MetaId = model.Id;
            context.Body = model.Body;

            stateEntryCount += await _context.SaveChangesAsync();
            await transaction.CommitAsync();
            return (stateEntryCount > 0);
        }

        public async Task<bool> DeleteAsync(long id)
        {
            // TODO: make on delete cascade work
            var context = _context.Context.Single(t => t.MetaId == id);
            _context.Context.Attach(context);
            _context.Context.Remove(context);
            var meta = new Meta {Id = id};
            _context.Meta.Attach(meta);
            _context.Meta.Remove(meta);
            var stateEntryCount = await _context.SaveChangesAsync();
            return (stateEntryCount > 0);
        }
    }
}