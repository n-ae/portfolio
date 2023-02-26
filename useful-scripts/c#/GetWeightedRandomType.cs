public static T GetRandomly<T>(this System.Random random, IDictionary<T, double> itemWeights)
{
    var weightsTotal = itemWeights.Sum(x => x.Value);
    var val = random.NextDouble();

    var subtotal = 0.0;
    foreach (var requestWeight in itemWeights)
    {
        subtotal += requestWeight.Value;
        if (val >= (weightsTotal - subtotal) / weightsTotal) return requestWeight.Key;
    }
    return default(T);
}
