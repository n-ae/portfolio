using System;
using Model.Data.Interface;

namespace Model.Data
{
    public class Article : IArticle
    {
        public long Id { get; set; }

        public string Title { get; set; }

        // TODO: add relational author table
        public string AuthorFullName { get; set; }

        public string Body { get; set; }
        public long MetaId { get; set; }
        public Meta Meta { get; set; }

        // TODO: add version control instead maybe as future work
        public DateTime LastEditedTimestamp { get; set; }

        public Context Context { get; set; }
    }
}