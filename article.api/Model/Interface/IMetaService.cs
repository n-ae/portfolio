using System.Collections.Generic;
using System.Threading.Tasks;
using Model.Data.Interface;

namespace Model.Interface
{
    public interface IMetaService
    {
        Task<IEnumerable<IMeta>> GetAsync();
        Task<IEnumerable<IMeta>> SearchAsync(string pattern);
    }
}