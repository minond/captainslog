NPM_BIN = ./node_modules/.bin

all: lint

install:
	npm i

lint:
	$(NPM_BIN)/tslint src/*/* *.js

server:
	$(NPM_BIN)/webpack-dev-server --open
