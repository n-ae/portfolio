using Dapper.Contrib.Extensions.Tablename;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;

namespace Demo
{
    public class Program
    {
        public static int Main(string[] args)
        {
            try
            {
                CreateHostBuilder(args).Build().Run();
                return 0;
            }
            catch
            {
                return 1;
            }
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .UseWindowsService()
                .ConfigureServices(services =>
                {
                    var configuration = new ConfigurationBuilder()
                        .AddJsonFile("appsettings.json")
                        .Build();
                    services.ReadTablenamesFromConfig(configuration.GetSection("Repository"));
                })
                // configuration
                .ConfigureServices(services =>
                {
                });
    }
}