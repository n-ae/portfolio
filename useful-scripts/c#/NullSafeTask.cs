public static class TaskExtensions
{
    public static async Task<T> NullSafe<T>(this Task<T> task)
    {
        return task != default(Task) ? await task : default(T);
    }
}

// usage
// var myFallbackfulValue = await (object?.MethodAsync()).NullSafe() ?? fallbackValue;
