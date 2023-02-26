using Configuration;
using RabbitMQ.Client;
using System;

namespace Messaging
{
    public class MessageQueue : IDisposable
    {
        private static IConnectionFactory ConnectionFactory
        {
            get
            {
                var configuration = Service<Configuration.RabbitMQ>.Value;
                var cf = new ConnectionFactory
                {
                    UserName = configuration.UserName,
                    Password = configuration.Password,
                    HostName = configuration.HostName,
                    Ssl = new SslOption
                    {
                        ServerName = configuration.ServerName,
                        Enabled = true,
                    }
                };
                return cf;
            }
        }

        public IConnection Connection { get; set; }
        public IModel Channel { get; set; }

        public MessageQueue(Queue queue)
        {
            Connection = ConnectionFactory.CreateConnection();
            Channel = Connection.CreateModel();
            Channel.QueueDeclare(queue.ToString(),
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null
                );
        }

        public void Dispose()
        {
            Channel.Dispose();
            Connection.Dispose();
        }
    }
}
