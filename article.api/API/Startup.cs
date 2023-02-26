using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Model.Data;
using Model.Data.Interface;
using Model.Interface;
using Repository;

namespace API
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        private void ConfigureIoC(IServiceCollection services)
        {
            services.AddDbContext<ArticleContext>(o =>
                o.UseMySQL(Configuration.GetConnectionString("maria")).EnableSensitiveDataLogging());
            services.AddTransient<ICollectionRepository<IMeta>, MetaRepository>();
            services.AddTransient<ISingleRepository<Article>, ArticleUnitOfWork>();
        }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddMemoryCache();

            services.AddOptions();

            services.AddSingleton(Configuration);

            ConfigureIoC(services);
            services.AddControllers();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseHttpsRedirection();

            app.UseRouting();

            app.UseAuthorization();

            app.UseEndpoints(endpoints => { endpoints.MapControllers(); });
        }
    }
}