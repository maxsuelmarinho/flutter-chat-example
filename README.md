# Flutter Chat Example

**Dependencies:**
```
> go get -u github.com/golang/protobuf/protoc-gen-go

# protoc plugin for Dart
> pub global activate protoc_plugin

# protobuffer files
> cp <protobuffer-installation-dir>/include/google/protobuf/empty.proto third_party/google/protobuf/
> cp <protobuffer-installation-dir>/include/google/protobuf/timestamp.proto third_party/google/protobuf/
> cp <protobuffer-installation-dir>/include/google/protobuf/wrappers.proto third_party/google/protobuf/
```

```
protoc chat.proto --proto_path=api/proto/v1 --proto_path=. --go_out=plugins=grpc:go_server/pkg/api/v1
```