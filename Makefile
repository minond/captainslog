IN_CLIENT_WEB = cd client-web &&
IN_SERVER = cd server &&

ifndef MODE
	MODE = development
endif

default: build
build: build-client build-server
lint: lint-client lint-server
test: test-server

build-client:
	$(IN_CLIENT_WEB) npm run build-$(MODE)

build-server:
	$(IN_SERVER) go build

lint-client:
	$(IN_CLIENT_WEB) npm run lint

lint-server:
	go vet ./...
	golint ./...

test-server:
	go test ./...

migrate-up:
	GO111MODULE=off kallax migrate up --all --dir migrations --dsn "$(DATABASE_URL)"

migration:
	GO111MODULE=off kallax migrate --input ./model/ --out ./migrations --name $(NAME)
