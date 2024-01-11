func climbStairs(n int) int {
	var result [46]int
	result[0] = 0
	result[1] = 1
	result[2] = 2
	// result[3] = 3
	// result[4] = 5

	if n >= 3 {
		for i := 3; i <= n; i++ {
			result[i] = result[i-1] + result[i-2]
		}
	}

	return result[n]
}
