using Model.Data.Interface;

namespace Model.Data
{
    public class Context : IContext
    {
        public long MetaId { get; set; }
        public string Body { get; set; }
        public Meta Meta { get; set; }
    }
}