using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Collections.Concurrent;
using System.Text;
using System.Text.Json;

namespace Messaging
{
    public static class Message
    {
        // TODO: [0] ensure multithread safety
        private static readonly ConcurrentQueue<string> Messages = new ConcurrentQueue<string>();
        private static bool Listening = false;
        public static void Send(this Queue queue, object message)
        {
            using var messageQueue = new MessageQueue(queue);
            var serializedMessage = JsonSerializer.Serialize(message);
            var body = Encoding.UTF8.GetBytes(serializedMessage);
            messageQueue.Channel.BasicPublish(string.Empty, queue.ToString(), null, body);
        }

        private static void Listen(this Queue queue)
        {
            using var messageQueue = new MessageQueue(queue);
            var consumer = new EventingBasicConsumer(messageQueue.Channel);
            consumer.Received += OnMessageArrival;
            messageQueue.Channel.BasicConsume(queue.ToString(), true, consumer);
            // TODO: [0]
            Listening = true;
        }

        private static void OnMessageArrival(dynamic sender, BasicDeliverEventArgs e)
        {
            var body = e.Body.ToArray();
            var message = Encoding.UTF8.GetString(body);
            Messages.Enqueue(message);
        }

        public static string Read(this Queue queue)
        {
            // TODO: [0]
            if (!Listening) queue.Listen();
            Messages.TryDequeue(out var message);
            return message;
        }
    }
}
