using MailKit.Net.Smtp;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using MimeKit;
using Serilog;
using Serilog.Configuration;
using Serilog.Sinks.Email;
using System;
using System.Collections.Generic;
using System.Net;

namespace Service.Scheduler
{
    internal static class MailService
    {
        private static int port;
        private static bool enableSsl;
        private static IEnumerable<string> toEmails;
        private static string server;
        private static NetworkCredential networkCredentials;
        private static readonly string subject =
            $"[ERROR][{IpService.IPAddress}][{AppDomain.CurrentDomain.BaseDirectory}]"
            .ComplyWithSubjectSMTPCharLength()
            ;

        internal static LoggerConfiguration TryAddMail(
            this LoggerConfiguration loggerConfiguration, IServiceCollection services, IConfigurationSection sec)
        {
            services.Configure<MailConfig>(sec);
            var mailConfig = sec.Get<MailConfig>();
            if (mailConfig == null) return loggerConfiguration;
            return loggerConfiguration.WriteTo.Email(mailConfig);
        }

        internal static LoggerConfiguration Email(this LoggerSinkConfiguration loggerSinkConfiguration, MailConfig mailConfig)
        {
            port = mailConfig.Port;
            enableSsl = mailConfig.EnableSsl;
            toEmails = mailConfig.ToEmails;
            server = mailConfig.Server;
            networkCredentials = mailConfig.NetworkCredentials;


            var emailInfo = new EmailConnectionInfo
            {
                FromEmail = networkCredentials.UserName,
                ToEmail = string.Join(';', toEmails),
                MailServer = server,
                EmailSubject = subject,
                EnableSsl = enableSsl,
                Port = port
            };

            if (!string.IsNullOrEmpty(networkCredentials.Password))
            {
                emailInfo.NetworkCredentials = networkCredentials;
            }
            AddSerilogEmailFailsafe();

            return loggerSinkConfiguration.Email(emailInfo, restrictedToMinimumLevel: Serilog.Events.LogEventLevel.Error);
        }

        private static void AddSerilogEmailFailsafe()
        {
            //Serilog.Debugging.SelfLog.Enable(Console.WriteLine);
            Serilog.Debugging.SelfLog.Enable((errorDump) =>
            {
                try
                {
                    Console.WriteLine(errorDump);

                    var toName = "Arintel Maintenance";
                    var fromName = typeof(Program).FullName;
                    var message = new MimeMessage();
                    message.From.Add(new MailboxAddress(fromName, networkCredentials.UserName));
                    foreach (var email in toEmails)
                    {
                        message.To.Add(new MailboxAddress(toName, email));
                    }
                    message.Subject = subject;

                    message.Body = new TextPart("plain")
                    {
                        Text = errorDump
                    };

                    using var client = new SmtpClient();
                    client.Connect(server, port, enableSsl);
                    // Note: only needed if the SMTP server requires authentication
                    client.Authenticate(networkCredentials);
                    client.Send(message);
                    client.Disconnect(true);
                }
                catch (Exception e)
                {
                    Console.WriteLine(e);
                }
            });
        }

        private static string ComplyWithSubjectSMTPCharLength(this string value)
        {
            if (string.IsNullOrEmpty(value)) { return value; }
            // http://www.faqs.org/rfcs/rfc2822.html
            Console.WriteLine(value.Length);
            return value.Substring(0, Math.Min(value.Length, 78));
        }
    }
}
