using Configuration;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.SignalR.Client;
using System;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;

namespace Connection
{
    public static class Services
    {
        public static readonly string HubMethodName = nameof(MessagingHub.Broadcast);

        private static IHubConnectionBuilder Configuration(string hubUrl, bool needsToBeSecure)
        {
            return new HubConnectionBuilder()
            //.WithUrl("http://127.0.0.1:5000/MessagingHub")
            .WithUrl(hubUrl, (opts) =>
            {
                if (needsToBeSecure) return;
                opts.HttpMessageHandlerFactory = (message) =>
                {
                    if (message is HttpClientHandler clientHandler)
                        // bypass SSL certificate
                        clientHandler.ServerCertificateCustomValidationCallback +=
                    (sender, certificate, chain, sslPolicyErrors) => { return true; };
                    return message;
                };
            })
            .WithAutomaticReconnect()
        ;
        }

        public static HubConnection GetConnection(string hubUrl, bool needsToBeSecure)
        {
            var connection = Configuration(hubUrl, needsToBeSecure)
                .Build();
            return connection;
        }

        public static string GetBaseUri(this HttpRequest request)
        {
            var baseUri = $"{request.Scheme}://{request.Host}{request.PathBase}";
            return baseUri;
        }
        
        private static string ToString(this object something)
        {
            var serializedObject = JsonSerializer.Serialize(something);
            //var byteArray = Encoding.UTF8.GetBytes(serializedMessage);
            return serializedObject;
        }

        private static T FromString<T>(this string serializedObject)
        {
            var t = JsonSerializer.Deserialize<T>(serializedObject);
            return t;
        }

        private static async Task<HubConnection> GetConection()
        {

            var configuration = Service<SignalR>.Value;
            var connection = GetConnection(configuration.HubUrl, configuration.NeedsToBeSecure);
            await connection.StartAsync();
            return connection;
        }

        public static async Task Broadcast(this object something)
        {
            var connection = await GetConection();
            await connection.InvokeAsync(nameof(MessagingHub.Broadcast), something);
        }

        public static async Task Listen(Func<string, Task> onMessageReceived)
        {
            var connection = await GetConection();
            connection.On(HubMethodName, onMessageReceived);
        }
    }
}
