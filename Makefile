IN_CLIENT_WEB = cd client/web &&
IN_SERVER = cd server &&

ifndef MODE
	MODE = development
endif

default: build
build: build-client build-server
lint: lint-client lint-server
test: test-server

build-client:
	$(IN_CLIENT_WEB) make build

build-server:
	$(IN_SERVER) go build

lint-client:
	$(IN_CLIENT_WEB) make lint

lint-server:
	go vet ./...
	golint ./...

test-server:
	go test ./...

migrate-up:
	GO111MODULE=off kallax migrate up --all --dir migrations --dsn "$(DATABASE_URL)"

migrate-down:
	GO111MODULE=off kallax migrate down --steps 1 --dir migrations --dsn "$(DATABASE_URL)"

migration:
	GO111MODULE=off kallax migrate --input ./model/ --out ./migrations --name $(NAME)
