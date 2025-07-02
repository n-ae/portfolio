// server.go
package main

import (
	"fmt"
	"io"
	"log"
	"net"
	"sync"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	pb "chat-grpc/generated/chat" // Import the generated Go package
)

// chatServer implements the ChatServiceServer interface
type chatServer struct {
	pb.UnimplementedChatServiceServer
	// Mutex to protect access to the clients map
	mu sync.Mutex
	// Map to store active client streams. Key is client ID, value is the stream.
	clients map[string]pb.ChatService_ChatStreamServer
	// Channel to broadcast messages to all connected clients
	broadcast chan *pb.ChatMessage
}

// NewChatServer creates and initializes a new chatServer
func NewChatServer() *chatServer {
	s := &chatServer{
		clients:   make(map[string]pb.ChatService_ChatStreamServer),
		broadcast: make(chan *pb.ChatMessage, 100), // Buffered channel for broadcasting
	}
	// Start a goroutine to handle broadcasting messages
	go s.runBroadcaster()
	return s
}

// runBroadcaster listens for messages on the broadcast channel and sends them to all connected clients.
func (s *chatServer) runBroadcaster() {
	for msg := range s.broadcast {
		s.mu.Lock()
		for clientID, stream := range s.clients {
			// Send the message to each client's stream
			if err := stream.Send(msg); err != nil {
				log.Printf("Failed to send message to client %s: %v", clientID, err)
				// If sending fails, remove the client from the map
				delete(s.clients, clientID)
			}
		}
		s.mu.Unlock()
	}
}

// ChatStream is the bidirectional streaming RPC method
func (s *chatServer) ChatStream(stream pb.ChatService_ChatStreamServer) error {
	// Generate a unique ID for this client connection
	clientID := fmt.Sprintf("client-%d", time.Now().UnixNano())
	log.Printf("Client %s connected.", clientID)

	// Add the new client stream to the map
	s.mu.Lock()
	s.clients[clientID] = stream
	s.mu.Unlock()

	defer func() {
		// Remove the client when the stream closes or an error occurs
		s.mu.Lock()
		delete(s.clients, clientID)
		s.mu.Unlock()
		log.Printf("Client %s disconnected.", clientID)
	}()

	// Goroutine to receive messages from this client
	go func() {
		for {
			in, err := stream.Recv()
			if err == io.EOF {
				// Client closed the stream
				return
			}
			if err != nil {
				log.Printf("Error receiving message from client %s: %v", clientID, err)
				return
			}
			log.Printf("Received message from %s: %s", in.GetUser(), in.GetText())

			// Add a timestamp to the message before broadcasting
			in.Timestamp = time.Now().Unix()

			// Broadcast the received message to all other clients
			s.broadcast <- in
		}
	}()

	// Keep the stream open indefinitely for sending messages to the client
	// This goroutine will block until the client disconnects or an error occurs.
	// The `runBroadcaster` goroutine will send messages to this stream.
	<-stream.Context().Done() // Wait for the client's context to be cancelled
	return status.Error(codes.Canceled, "Stream closed by client or server")
}

func main() {
	// Listen on TCP port 50051
	lis, err := net.Listen("tcp", ":80")
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}

	// Create a new gRPC server
	s := grpc.NewServer()

	// Register our chatServer implementation with the gRPC server
	pb.RegisterChatServiceServer(s, NewChatServer())

	log.Println("Chat server listening on :80")
	// Start serving gRPC requests
	if err := s.Serve(lis); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}
