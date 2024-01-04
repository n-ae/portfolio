public class Solution {
    public int EliminateMaximum(int[] dist, int[] speed) {
        var cnt = 0;
        var roundsLeftCount = new Dictionary<int, int>();
        for (var i = 0; i < dist.Length; ++i)
        {
            var requiredRounds = (int)Math.Ceiling((double)dist[i] / speed[i]);
            roundsLeftCount.TryAdd(requiredRounds, 0);
            ++roundsLeftCount[requiredRounds];
        }
        for (var i = 0; roundsLeftCount.Count > 0; ++i)
        {
            if (roundsLeftCount.TryGetValue(i, out var val))
            {
                var rndsLft = i - cnt;
                if (rndsLft < val) return cnt + rndsLft;
                cnt += val;
                roundsLeftCount.Remove(i);
            }
        }
        return cnt;
    }
}
