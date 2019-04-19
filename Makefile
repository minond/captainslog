IN_MOBILE_CLIENT = cd client/mobile &&
IN_SERVER = cd server &&
IN_WEB_CLIENT = cd client/web &&

ifndef MODE
	MODE = development
endif

default: build

### Builds #####################################################################

build: build-web-client build-server

build-web-client:
	$(IN_WEB_CLIENT) make build

build-server:
	$(IN_SERVER) go build


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
	GO111MODULE=off kallax migrate up --all --dir migrations --dsn "$(DATABASE_URL)"

migrate-down:
	GO111MODULE=off kallax migrate down --steps 1 --dir migrations --dsn "$(DATABASE_URL)"

migration:
	GO111MODULE=off kallax migrate --input ./model/ --out ./migrations --name $(NAME)
