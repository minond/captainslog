IN_CLIENT_WEB = cd client-web &&
IN_SERVER = cd server &&

default: build
compile: compile-protoc
build: build-client build-server
lint: lint-client
test: test-server

compile-protoc:
	protoc --go_out=server/log/ -I definitions definitions/*.proto

compile-protoc-deps:
	go get github.com/golang/protobuf/protoc-gen-go

build-client:
	$(IN_CLIENT_WEB) make build

build-server:
	$(IN_SERVER) go build

lint-client:
	$(IN_CLIENT_WEB) make lint

test-server:
	$(IN_SERVER) go test ./...
