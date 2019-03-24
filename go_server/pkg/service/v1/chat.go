package v1

import (
	"context"
	"fmt"
	"log"

	"github.com/golang/protobuf/ptypes/empty"
	"github.com/golang/protobuf/ptypes/wrappers"
	v1 "github.com/maxsuelmarinho/flutter-chat-example/go_server/pkg/api/v1"
)

type chatServiceServer struct {
	msg chan string
}

func NewChatServiceServer() v1.ChatServiceServer {
	return &chatServiceServer{msg: make(chan string, 1000)}
}

func (s *chatServiceServer) Send(ctx context.Context, message *wrappers.StringValue) (*empty.Empty, error) {
	if message != nil {
		log.Printf("Send requested: message=%v", *message)
		s.msg <- message.Value
	} else {
		log.Printf("Send requested: message=<empty>")
	}

	return &empty.Empty{}, nil
}

func (s *chatServiceServer) Subscribe(e *empty.Empty, stream v1.ChatService_SubscribeServer) error {
	log.Print("Subscribe requested")
	for {
		m := <-s.msg
		n := v1.Message{Text: fmt.Sprintf("I have received from you: %s. Thanks!", m)}
		if err := stream.Send(&n); err != nil {
			s.msg <- m
			log.Printf("Stream connection failed: %v", err)
			return nil
		}
		log.Printf("Message sent: %+v", n)
	}
}
