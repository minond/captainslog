IN_CLIENT_WEB = cd client-web &&
IN_SERVER = cd server &&

ifndef MODE
	MODE = development
endif

default: build
build: build-proto build-client build-server
lint: lint-client
test: test-server

build-proto:
	protoc \
		-I definitions \
		--go_out=server/proto/ \
		--typescript-definitions_out=client-web/src/definitions \
		definitions/*.proto

build-proto-deps:
	go get github.com/golang/protobuf/protoc-gen-go
	go get github.com/minond/protoc-gen-typescript-definitions

build-client:
	$(IN_CLIENT_WEB) npm run build-$(MODE)

build-server:
	$(IN_SERVER) go build ./...

lint-client:
	$(IN_CLIENT_WEB) npm run lint
	$(IN_SERVER) go vet ./...
	$(IN_SERVER) golint ./...

test-server:
	$(IN_SERVER) go test ./...
