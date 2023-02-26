public static class TasksExtensions
{
    public static async Task ThrowAllThatFailed(this IEnumerable<Task> tasks)
    {
        var exceptions = new List<Exception>();
        foreach (var task in tasks)
        {
            try
            {
                await task;
            }
            catch (Exception e)
            {
                exceptions.Add(e);
            }
        }
        if (!exceptions.Any()) return;

        throw new AggregateException("At least one of the tasks have failed", exceptions);
    }
}
