func finalValueAfterOperations(operations []string) int {
	x := 0
	for i := 0; i < len(operations); i++ {
		switch op := operations[i][1]; op {
		case '+':
			x++
		default:
			x--
		}
	}
	return x
}
