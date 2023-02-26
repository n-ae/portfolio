using Messaging;
using System;

namespace Consumer
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");
            while (true)
            {
                Console.WriteLine("I am the evidence.");
                var message = Queue.Push.Read();
                if (!string.IsNullOrEmpty(message)) Console.WriteLine(message);
            }
        }
    }
}
