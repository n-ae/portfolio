func tribonacci(n int) int {
	var result [38]int
	result[0] = 0
	result[1] = 1
	result[2] = 1

	if n > 2 {
		result[n] = tailRec(n, [3]int{result[0], result[1], result[2]})
	}

	return result[n]
}

func tailRec(n int, window [3]int) int {
	if n == 2 {
		return window[2]
	}

	return tailRec(n-1, [3]int{window[1], window[2], window[0] + window[1] + window[2]})
}
