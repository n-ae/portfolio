func fib(n int) int {
	var result [31]int
	result[0] = 0
	result[1] = 1

	if n > 1 {
		result[n] = tailRec(n, [2]int{result[0], result[1]})
	}

	return result[n]
}

func tailRec(n int, window [2]int) int {
	if n == 1 {
		return window[1]
	}

	return tailRec(n-1, [2]int{window[1], window[0] + window[1]})
}
