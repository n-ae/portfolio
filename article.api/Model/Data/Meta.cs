using System;
using Model.Data.Interface;

namespace Model.Data
{
    public class Meta : IMeta
    {
        public long Id { get; set; }
        public string Title { get; set; }
        public string AuthorFullName { get; set; }
        public DateTime LastEditedTimestamp { get; set; }
        public Context Context { get; set; }
    }
}