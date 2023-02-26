using System.Threading.Tasks;
using Model.Data.Interface;

namespace Model.Interface
{
    public interface IArticleService
    {
        Task<IArticle> GetAsync(int id);
        Task<int> AddAsync(IArticle model);
        Task<bool> UpdateAsync(IArticle model);
        Task<bool> DeleteAsync(int id);
    }
}