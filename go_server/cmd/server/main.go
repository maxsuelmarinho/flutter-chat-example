package main

import (
	"context"
	"fmt"
	"os"

	"github.com/maxsuelmarinho/flutter-chat-example/go_server/pkg/protocol/grpc"
	"github.com/maxsuelmarinho/flutter-chat-example/go_server/pkg/service/v1"
)

func main() {
	if err := grpc.RunServer(context.Background(), v1.NewChatServiceServer(), "3000"); err != nil {
		fmt.Fprint(os.Stderr, "%v\n", err)
		os.Exit(1)
	}
}
