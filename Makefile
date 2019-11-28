# Run `make` to build server and web client, run linterns and autoformatters with
# `make fmt lint`. To start the application server, run `./captainslog server`
# after building project. Run `./captainslog help` to see a list of other
# commands.
#
# Developing on the mobile client can be done with an emulator. To start an iOS
# emulator and run the application:
#
# ```
# cd client/mobile
# flutter emulators --launch apple_ios_simulator
# flutter run
# ```
#
# Make sure to run `go generate` with Go modules disabled -- Kallax's generator
# does not like to be ran with modules enabled:
#
# ```
# GO111MODULE=off go generate ./...
# ```

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

test:
	$(IN_WEB_CLIENT) make test
	go test ./...

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
