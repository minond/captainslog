NPM_BIN = ./node_modules/.bin

all: lint build

install:
	npm i

lint:
	$(NPM_BIN)/tslint src/*/* *.js

build:
	$(NPM_BIN)/webpack

server:
	$(NPM_BIN)/webpack-dev-server --open
