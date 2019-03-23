protoc chat.proto \
    --proto_path=api/proto/v1 \
    --proto_path=. \
    --go_out=plugins=grpc:go_server/pkg/api/v1