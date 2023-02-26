using Connection;
using System;
using System.Threading.Tasks;

namespace Producer
{
    static class Program
    {
        static async Task Main()
        {
            Console.WriteLine("Hello World!");
            var myObject = new
            {
                ProducerTime = DateTime.Now,
                ProducerSays = "Memoria"
            };
            await myObject.Broadcast();
        }
    }
}
