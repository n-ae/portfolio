using Configuration;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;

namespace Broker.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ConfigurationController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public IEnumerable<RabbitMQ> Get()
        {
            var configuration = Service<RabbitMQ>.Value;
            return new[] { configuration };
        }
    }
}
