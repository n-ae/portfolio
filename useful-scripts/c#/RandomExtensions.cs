public static class RandomExtensions
{
    // maximum number of uniform bits is 30 according to:
    // https://stackoverflow.com/a/17080161/7032856
    const int MaxNoOfUniformBitSize = 30;
    const int UintBitSize = 32;
    const int RemainderBitSize = UintBitSize - MaxNoOfUniformBitSize;
    private static Random Random = new Random();

    public static uint GetNextUint()
    {
        var maxAvailableUniformBits = (uint)Random.Next(1 << MaxNoOfUniformBitSize);
        var remainderBitsToComplete = (uint)Random.Next(1 << RemainderBitSize);
        return (maxAvailableUniformBits << RemainderBitSize) | remainderBitsToComplete;
    }

    public static T GetRandom<T>() where T : struct, Enum
    {
        var v = Enum.GetValues<T>();
        return (T)v.GetValue(Random.Next(v.Length));
    }


    static class RandomExtensions
    {
        /// <summary>
        /// Returns an Int32 with a random value across the entire range of
        /// possible values.
        /// </summary>
        public static int NextInt32(this Random rng, byte bitCount)
        {
            const byte maxBitPossible = 32;
            if (bitCount > maxBitPossible) throw new ArgumentOutOfRangeException();

            var halfWay = bitCount / 2;
            var upToHalfway = bitCount - halfWay;
            var firstBits = rng.Next(0, 1 << halfWay) << upToHalfway;
            var lastBits = rng.Next(0, 1 << upToHalfway);
            return firstBits | lastBits;
        }

        // example
        private static decimal GetRandomWeight(Random rng)
        {
            const decimal maxWeight = 10;
            const int maxScale = 11;
            const int bitsRequiredFor10withScale11 = 40;
            const int maxBitsInInt = 32;
            const int leftOverBits = bitsRequiredFor10withScale11 - maxBitsInInt;

            var randNum = new decimal(rng.NextInt32(maxBitsInInt), rng.NextInt32(leftOverBits), 0, false, maxScale);
            return randNum < maxWeight ? randNum : maxWeight;
        }
    }
}
