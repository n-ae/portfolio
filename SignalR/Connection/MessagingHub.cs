using Microsoft.AspNetCore.SignalR;
using Microsoft.AspNetCore.SignalR.Client;
using System.Threading.Tasks;

namespace Connection
{
    public class MessagingHub : Hub
    {
        public async Task Broadcast(object something)
        {
            await Clients.All.SendAsync(Services.HubMethodName, something.ToString());
        }
    }
}
