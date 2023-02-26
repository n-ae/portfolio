using System;
using Messaging;

namespace Producer
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");
            var message = new { Name = "NameValue", Message = "MessageValue" };
            Queue.Push.Send(message);
        }
    }
}
