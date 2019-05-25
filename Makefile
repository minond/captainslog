IN_MOBILE_CLIENT = cd client/mobile &&
IN_WEB_CLIENT = cd client/web &&

default: build

build:
	$(IN_WEB_CLIENT) make build
	go build -o captainslog cmd/captainslog/*

lint:
	$(IN_MOBILE_CLIENT) dartanalyzer ./lib
	$(IN_WEB_CLIENT) make lint
	go vet ./...
	golangci-lint run

fmt:
	$(IN_MOBILE_CLIENT) dartfmt -w ./lib
	gofmt -s -w $(find . -name *.go)

migration:
	GO111MODULE=off kallax migrate --input ./model/ --out ./migrations --name $(NAME)
