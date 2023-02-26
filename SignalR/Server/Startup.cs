using Connection;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Configuration;
using System.Text.Json;

namespace Server
{
    public class Startup
    {
        // This method gets called by the runtime. Use this method to add services to the container.
        // For more information on how to configure your application, visit https://go.microsoft.com/fwlink/?LinkID=398940
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddSignalR(o => o.EnableDetailedErrors = true)
            ;
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseRouting();

            // app.UseAuthentication();
            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                var path = typeof(MessagingHub).Name;
                endpoints.MapGet("/", async context =>
                {
                    // suggested configuration for consumer & producer
                    var needsToBeSecure = !env.IsDevelopment();
                    var url = context.Request.GetBaseUri();
                    url += $"/{typeof(MessagingHub).Name}";

                    var suggestedConfig = new SignalR
                    {
                        HubUrl = url,
                        NeedsToBeSecure = needsToBeSecure
                    };

                    var serialized = JsonSerializer.Serialize(suggestedConfig);

                    await context.Response.WriteAsync($"{serialized}\n");

                    //var connection = MessagingHub.GetConnection(url, needsToBeSecure);
                    //await connection.StartAsync();
                    //var mySerializedObject = new
                    //{
                    //    ServerTime = DateTime.Now,
                    //    ServerSays = message
                    //};
                    //await connection.InvokeAsync(nameof(MessagingHub.Broadcast), mySerializedObject);
                });
                endpoints.MapHub<MessagingHub>(path);
            });
        }
    }
}
