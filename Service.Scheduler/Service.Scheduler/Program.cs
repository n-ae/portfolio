using AspNetCore.Scheduler.Quartz;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Serilog;
using System;

namespace Service.Scheduler
{
    public class Program
    {
        public static int Main(string[] args)
        {
            Console.WriteLine("This is program.");

            try
            {
                CreateHostBuilder(args).Build().Run();
                return 0;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                Log.Fatal(ex, "Host terminated unexpectedly!");
                return 1;
            }
            finally
            {
                Console.WriteLine("Log.CloseAndFlush();");
                Log.CloseAndFlush();
            }
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
            .UseWindowsService()
            .ConfigureServices(services =>
            {
                var configuration = new ConfigurationBuilder()
                .AddJsonFile("appsettings.json")
                .AddJsonFile("mail.json")
                .AddJsonFile("quartz.json")
                .Build();

                Log.Logger = new LoggerConfiguration()
                    .ReadFrom.Configuration(configuration)
                    .TryAddMail(services, configuration.GetSection("Mail"))
                    .CreateLogger();

                services.AddQuartz(configuration.GetSection("Quartz"));
                services.AddExtraneousTransientJobs();
            })
            .UseSerilog()
            ;

    }
}