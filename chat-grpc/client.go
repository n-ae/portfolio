// client.go
package main

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"log"
	"os"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"

	pb "chat-grpc/generated/chat" // Import the generated Go package
)

func main() {
	// Set up a connection to the server.
	conn, err := grpc.Dial("ec2-34-255-160-68.eu-west-1.compute.amazonaws.com:80", grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("Did not connect: %v", err)
	}
	defer conn.Close()

	// Create a new ChatService client
	client := pb.NewChatServiceClient(conn)

	// Get username from command line arguments or prompt
	var username string
	if len(os.Args) > 1 {
		username = os.Args[1]
	} else {
		fmt.Print("Enter your username: ")
		reader := bufio.NewReader(os.Stdin)
		input, _ := reader.ReadString('\n')
		username = "User-" + input[:len(input)-1] // Remove newline character
	}
	log.Printf("Connected as: %s", username)

	// Establish a bidirectional streaming call
	stream, err := client.ChatStream(context.Background())
	if err != nil {
		log.Fatalf("Error opening stream: %v", err)
	}
	defer stream.CloseSend() // Ensure the stream is closed when done

	// Goroutine to receive messages from the server
	go func() {
		for {
			in, err := stream.Recv()
			if err == io.EOF {
				log.Println("Server closed the stream.")
				return
			}
			if err != nil {
				log.Printf("Error receiving message from server: %v", err)
				return
			}
			// Format and print the received message
			t := time.Unix(in.GetTimestamp(), 0)
			fmt.Printf("[%s] %s: %s\n", t.Format("15:04:05"), in.GetUser(), in.GetText())
		}
	}()

	// Read messages from standard input and send them to the server
	scanner := bufio.NewScanner(os.Stdin)
	fmt.Println("Type your messages and press Enter to send. Type 'exit' to quit.")
	for scanner.Scan() {
		text := scanner.Text()
		if text == "exit" {
			break
		}

		// Create a new chat message
		msg := &pb.ChatMessage{
			User: username,
			Text: text,
		}

		// Send the message to the server
		if err := stream.Send(msg); err != nil {
			log.Printf("Error sending message: %v", err)
			break
		}
	}

	if err := scanner.Err(); err != nil {
		log.Printf("Error reading input: %v", err)
	}

	log.Println("Client exiting.")
}
