using System.Net;

namespace Service.Scheduler
{
    internal static class IpService
    {
        internal static string IPAddress
        {
            get
            {
                try
                {
                    return new WebClient().DownloadString("http://icanhazip.com").Trim();
                }
                catch
                {
                    return "0.0.0.0";
                }
            }
        }
    }
}
