func callConcurrently(callback func(), times uint) {
	var wg sync.WaitGroup
	for i := uint(0); i < times; i++ {
		wg.Add(1)
		go func() {
			callback()
			defer wg.Done()
		}()
	}
	defer wg.Wait()
}
