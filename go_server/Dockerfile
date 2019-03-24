
FROM golang:alpine as builder

RUN apk update && apk add git && apk add ca-certificates

RUN adduser -D -g '' appuser
COPY . $GOPATH/src/github.com/maxsuelmarinho/flutter-chat-example/chat-server
WORKDIR $GOPATH/src/github.com/maxsuelmarinho/flutter-chat-example/chat-server

RUN go get -d -v
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/chat-server

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /go/bin/chat-server /go/bin/chat-server

EXPOSE 3000
USER appuser
ENTRYPOINT ["/go/bin/chat-server"]
