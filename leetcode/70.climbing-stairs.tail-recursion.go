func climbStairs(n int) int {
	var result [46]int
	result[0] = 0
	result[1] = 1
	result[2] = 2

	if n > 2 {
		result[n] = tailRec(n, [2]int{result[1], result[2]})
	}

	return result[n]
}

func tailRec(n int, window [2]int) int {
	var w [2]int
	w[0] = window[1]
	w[1] = window[0] + window[1]
	if n == 2 {
		return w[0]
	}
	return tailRec(n-1, w)
}
