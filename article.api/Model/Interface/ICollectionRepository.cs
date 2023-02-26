using System.Collections.Generic;
using System.Threading.Tasks;
using Model.Data.Interface;

namespace Model.Interface
{
    public interface ICollectionRepository<T> where T : IEntity
    {
        Task<IEnumerable<T>> ReadAsync();
        Task<IEnumerable<T>> SearchAsync(string pattern);
    }
}