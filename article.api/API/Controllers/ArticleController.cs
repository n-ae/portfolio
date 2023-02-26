using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Model.Data;
using Model.Data.Interface;
using Model.Interface;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ArticleController : ControllerBase
    {
        private readonly ICollectionRepository<IMeta> _metaRepository;
        private readonly ISingleRepository<Article> _articleUnitOfWork;

        public ArticleController(ICollectionRepository<IMeta> metaRepository,
            ISingleRepository<Article> articleUnitOfWork)
        {
            _metaRepository = metaRepository;
            _articleUnitOfWork = articleUnitOfWork;
        }

        [HttpGet]
        public async Task<IActionResult> GetAsync()
        {
            var rows = await _metaRepository.ReadAsync();
            return Ok(rows);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetAsync(long id)
        {
            var row = await _articleUnitOfWork.ReadAsync(id);
            return Ok(row);
        }

        [HttpPost("search")]
        public async Task<IActionResult> SearchAsync(string pattern)
        {
            var rows = await _metaRepository.SearchAsync(pattern);
            return Ok(rows);
        }

        [HttpPost]
        public async Task<IActionResult> AddAsync(Article model)
        {
            var isSuccessful = await _articleUnitOfWork.CreateAsync(model);
            return Ok(isSuccessful);
        }

        [HttpPut]
        public async Task<IActionResult> UpdateAsync(Article model)
        {
            var isSuccessful = await _articleUnitOfWork.UpdateAsync(model);
            return Ok(isSuccessful);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAsync(long id)
        {
            var isSuccessful = await _articleUnitOfWork.DeleteAsync(id);
            return Ok(isSuccessful);
        }
    }
}