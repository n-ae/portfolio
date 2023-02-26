package main

import (
	"log"
	"runtime"
	"strconv"
	"sync"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/lambda"

	"encoding/json"
	"fmt"
	"os"
)

type configuration struct {
	Type            string
	RestaurantCount uint64
	RPSCount        uint64
	Duration        uint64
	LuaConfig       uint64
}

func main() {
	defer elapsed(trace())() // <-- The trailing () is the deferred call
	// Create Lambda service client
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	region := "eu-west-1"
	client := lambda.New(sess, &aws.Config{Region: aws.String(region)})

	// os.Setenv("RESTAURANT_COUNT", "26")
	// os.Setenv("RPS", "194")
	// os.Setenv("DURATION", "9")
	// os.Setenv("IS_MANUAL", "true")
	// os.Setenv("TYPE", "random")
	// os.Setenv("LUA_CONFIG", "1")
	resto_count, _ := strconv.ParseUint(os.Getenv("RESTAURANT_COUNT"), 10, 64)
	rps, _ := strconv.ParseUint(os.Getenv("RPS"), 10, 64)
	duration, _ := strconv.ParseUint(os.Getenv("DURATION"), 10, 64)
	op := os.Getenv("TYPE")
	luaConfig, _ := strconv.ParseUint(os.Getenv("LUA_CONFIG"), 10, 64)

	config := configuration{op, resto_count, rps, duration, luaConfig}
	fmt.Printf("%+v\n", config)

	functionName := fmt.Sprintf("arn:aws:lambda:%s:<aws_account_id>:function:RedisLoadTest", region)
	fmt.Printf("functionName: %s\n", functionName)

	payload, err := json.Marshal(&config)
	if err != nil {
		_ = fmt.Errorf("failed marshaling config: %v", err)
		os.Exit(0)
	}

	var wgCallConcurrently sync.WaitGroup
	defer wgCallConcurrently.Wait()

	ticker := time.NewTicker(time.Second)
	for i := uint64(0); i < duration; i++ {
		<-ticker.C
		wgCallConcurrently.Add(1)
		go callConcurrently(&payload, &config.RPSCount, client, aws.String(functionName), &wgCallConcurrently)
	}
}

func callConcurrently(payload *[]byte, rps *uint64, client *lambda.Lambda, functionName *string, wg *sync.WaitGroup) {
	defer elapsed(trace())() // <-- The trailing () is the deferred call
	defer wg.Done()
	var wgInvoke sync.WaitGroup
	defer wgInvoke.Wait()

	for i := uint64(0); i < *rps; i++ {
		wgInvoke.Add(1)
		go invoke(payload, client, functionName, &wgInvoke)
	}
}

func elapsed(functionName string) func() {
	start := time.Now()
	return func() {
		log.Printf("Elapsed: %v (%s)\n", time.Since(start), functionName)
	}
}

func invoke(payload *[]byte, client *lambda.Lambda, functionName *string, wg *sync.WaitGroup) {
	defer wg.Done()

	_, err := client.Invoke(&lambda.InvokeInput{FunctionName: functionName, Payload: *payload})
	if err != nil {
		log.Printf("failed invoking lambda: %v", err)
	}
}

func trace() string {
	pc := make([]uintptr, 10) // at least 1 entry needed
	runtime.Callers(2, pc)
	f := runtime.FuncForPC(pc[0])
	return f.Name()
	// file, line := f.FileLine(pc[0])
	// fmt.Printf("%s:%d %s\n", file, line, f.Name())
}
