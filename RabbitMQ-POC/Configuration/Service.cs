using Microsoft.Extensions.Configuration;
using System;
using System.IO;
using System.Reflection;

namespace Configuration
{
    public static class Service<T>
    {
        public static readonly T Value;

        private static string AssemblyDirectory
        {
            get
            {
                var codeBase = Assembly.GetExecutingAssembly().Location;
                //var codeBase = AppContext.BaseDirectory;
                var uri = new UriBuilder(codeBase);
                var path = Uri.UnescapeDataString(uri.Path);
                return Path.GetDirectoryName(path);
            }
        }

        static Service()
        {
            var assemblyConfigFile = $"{AssemblyDirectory}{Path.DirectorySeparatorChar}{typeof(T).Name}.json";
            var configuration = new ConfigurationBuilder()
                // current dll config
                .AddJsonFile(assemblyConfigFile)
                .Build()
                ;
            Value = configuration.Get<T>();
        }
    }
}
