using System;
using System.Threading.Tasks;
using Connection;

namespace Consumer
{
    static class Program
    {
        static async Task Main()
        {
            await Services.Listen(OnMessageArrival);
            while (true) Console.ReadLine();
        }

        static async Task OnMessageArrival(string message)
        {
            await Task.Delay(0);
            Console.WriteLine(message);
        }
    }
}
