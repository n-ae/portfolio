using System.Collections.Generic;
using System.Net;

namespace Service.Scheduler
{
    internal class MailConfig
    {
        public int Port { get; set; }
        public bool EnableSsl { get; set; }
        public IEnumerable<string> ToEmails { get; set; }
        public string Server { get; set; }
        public NetworkCredential NetworkCredentials { get; set; }
    }
}