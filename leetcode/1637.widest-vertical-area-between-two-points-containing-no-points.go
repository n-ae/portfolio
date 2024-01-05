func maxWidthOfVerticalArea(points [][]int) int {
	var xs []int
	for i := 0; i < len(points); i++ {
		xs = append(xs, points[i][0])
	}

	sort.Ints(xs[:])

	maxDiff := 0
	for i := 0; i < len(xs)-1; i++ {
		diff := xs[i+1] - xs[i]
		if diff > maxDiff {
			maxDiff = diff
		}
	}

	return maxDiff
}
