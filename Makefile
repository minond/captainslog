IN_MOBILE_CLIENT = cd client/mobile &&
IN_WEB_CLIENT = cd client/web &&

default: build

run: build-web-client build-server
	./captainslog-server

### Builds #####################################################################

build: build-web-client build-server build-tools

build-web-client:
	$(IN_WEB_CLIENT) make build

build-server:
	go build -o captainslog-server cmd/captainslog-server/main.go

build-tools:
	go build -o captainslog-migrate cmd/captainslog-migrate/main.go
	go build -o captainslog-repl cmd/captainslog-repl/main.go


### Linters ####################################################################

lint: lint-mobile-client lint-web-client lint-server

lint-mobile-client:
	$(IN_MOBILE_CLIENT) dartanalyzer ./lib

lint-web-client:
	$(IN_WEB_CLIENT) make lint

lint-server:
	go vet ./...
	golangci-lint run


### Auto formatters ############################################################

fmt: fmt-mobile-client

fmt-mobile-client:
	$(IN_MOBILE_CLIENT) dartfmt -w ./lib


### Tests ######################################################################

test: test-server

test-server:
	go test ./...


### Migrations #################################################################

migrate-up:
	go run cmd/captainslog-migrate/main.go up

migrate-down:
	go run cmd/captainslog-migrate/main.go down

migration:
	GO111MODULE=off kallax migrate --input ./model/ --out ./migrations --name $(NAME)
