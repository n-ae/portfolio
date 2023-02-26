using Microsoft.EntityFrameworkCore;
using Model.Data;

namespace Repository
{
    public class ArticleContext : DbContext
    {
        public ArticleContext(DbContextOptions<ArticleContext> options) : base(options)
        {
            Database.EnsureCreated();
        }

        public DbSet<Meta> Meta { get; set; }
        public DbSet<Context> Context { get; set; }


        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Meta>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Title).IsRequired();
                entity.Property(e => e.AuthorFullName).IsRequired();
                entity.Property(e => e.LastEditedTimestamp).IsRequired();
                entity.HasOne(d => d.Context)
                    .WithOne(m => m.Meta)
                    .HasForeignKey<Context>(c => c.MetaId)
                    .OnDelete(DeleteBehavior.Cascade)
                    ;
            });

            modelBuilder.Entity<Context>(entity =>
            {
                entity.HasKey(e => e.MetaId);
                entity.Property(e => e.Body).IsRequired();
            });
        }
    }
}