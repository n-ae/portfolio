using System;

namespace Model.Data.Interface
{
    public interface IMeta : IEntity
    {
        public string Title { get; set; }
        public string AuthorFullName { get; set; }
        public DateTime LastEditedTimestamp { get; set; }
        public Context Context { get; set; }
    }
}