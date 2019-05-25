IN_MOBILE_CLIENT = cd client/mobile &&
IN_WEB_CLIENT = cd client/web &&

default: build

build:
	$(IN_WEB_CLIENT) make build
	packr2 build ./cmd/captainslog-server/main.go
	go build -o captainslog-server cmd/captainslog-server/main.go
	go build -o captainslog-migrate cmd/captainslog-migrate/main.go
	go build -o captainslog-repl cmd/captainslog-repl/main.go

lint:
	$(IN_MOBILE_CLIENT) dartanalyzer ./lib
	$(IN_WEB_CLIENT) make lint
	go vet ./...
	golangci-lint run

fmt:
	$(IN_MOBILE_CLIENT) dartfmt -w ./lib
	gofmt -s -w $(find . -name *.go)

test:
	go test ./...

migration:
	GO111MODULE=off kallax migrate --input ./model/ --out ./migrations --name $(NAME)
