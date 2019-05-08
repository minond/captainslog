Captain's log is an application for logging anything you want about yourself.

[![Build Status](https://travis-ci.org/minond/captainslog.svg?branch=master)](https://travis-ci.org/minond/captainslog)
[![Go Report Card](https://goreportcard.com/badge/github.com/minond/captainslog)](https://goreportcard.com/report/github.com/minond/captainslog)


### Usage

- Start the server with `go run server/main.go`.
- Build the web client with `cd client/web; make build`.
- Run the mobile client in an emulator with `cd client/mobile; flutter run`.


### Development

Run linterns and autoformatters with `make fmt lint`.

Make sure to run `go generate` with Go modules disabled -- Kallax's generator
does not like to be ran with modules enabled:

    GO111MODULE=off go generate ./...
