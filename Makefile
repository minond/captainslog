IN_MOBILE_CLIENT = cd client/mobile &&
IN_WEB_CLIENT = cd client/web &&

default: build

build: build-web build-server

build-web:
	$(IN_WEB_CLIENT) make build

build-server:
	go build -o captainslog cmd/captainslog/*

build-server-prod: build-web
	go run generator/assets/main.go -input ./client/web/dist/ -output ./cmd/captainslog/tmp-assets.go -package main
	make build-server GOOS=linux GOARCH=amd64
	rm ./cmd/captainslog/tmp-assets.go

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
