IN_MOBILE_CLIENT = cd client/mobile &&
IN_WEB_CLIENT = cd client/web &&

default: build

### Builds #####################################################################

build: build-web-client build-server

build-web-client:
	$(IN_WEB_CLIENT) make build

build-server:
	go build server/main.go
	go build cmd/migrate/main.go


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
	go run cmd/migrate/main.go up

migrate-down:
	go run cmd/migrate/main.go down

migration:
	GO111MODULE=off kallax migrate --input ./model/ --out ./migrations --name $(NAME)
