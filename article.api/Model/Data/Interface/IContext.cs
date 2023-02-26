namespace Model.Data.Interface
{
    public interface IContext
    {
        public long MetaId { get; set; }
        public string Body { get; set; }
        public Meta Meta { get; set; }
    }
}