# Flutter Chat Example

**Dependencies:**
```
> go get -u github.com/golang/protobuf/protoc-gen-go

# protobuffer files
> cp <protobuffer-installation-dir>/include/google/protobuf/empty.proto third_party/google/protobuf/
> cp <protobuffer-installation-dir>/include/google/protobuf/timestamp.proto third_party/google/protobuf/
> cp <protobuffer-installation-dir>/include/google/protobuf/wrappers.proto third_party/google/protobuf/
```

## Generate protobuf/grpc code from proto API definition

```
protoc chat.proto --proto_path=api/proto/v1 --proto_path=. --go_out=plugins=grpc:go_server/pkg/api/v1
```

## Generate Dart code for protobuf support files and for chat.proto

### Protoc plugin for Dart

```
pub global activate protoc_plugin
```

### Generate files

```
# WINDOWS
protoc empty.proto timestamp.proto wrappers.proto --proto_path=third_party/google/protobuf --plugin=protoc-gen-dart=%USERPROFILE%/AppData/Roaming/Pub/Cache/bin/protoc-gen-dart.bat --dart_out=grpc:flutter_client/lib/api/v1/google/protobuf

protoc chat.proto --proto_path=api/proto/v1 --proto_path=third_party --plugin=protoc-gen-dart=%USERPROFILE%/AppData/Roaming/Pub/Cache/bin/protoc-gen-dart.bat --dart_out=grpc:flutter_client/lib/api/v1

# LINUX
protoc empty.proto timestamp.proto wrappers.proto --proto_path=third_party/google/protobuf --dart_out=grpc:flutter_client/lib/api/v1/google/protobuf

protoc chat.proto --proto_path=api/proto/v1 --proto_path=third_party --dart_out=grpc:flutter_client/lib/api/v1
```