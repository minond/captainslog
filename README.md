Captain's log is an application for logging anything you want about yourself.

[![Build Status](https://travis-ci.org/minond/captainslog.svg?branch=master)](https://travis-ci.org/minond/captainslog)
[![Go Report Card](https://goreportcard.com/badge/github.com/minond/captainslog)](https://goreportcard.com/report/github.com/minond/captainslog)


## Outline

The intent of this project is to have an application that I can use to log
anything in relatively free form, and still be able to extract (or inject)
important information from the logs. This is done using features like
Extractors that know how to extract and label data from a piece of text.


## Development

Run `make` to build server and web client, `make run` to run the server in
development mode. Run linterns and autoformatters with `make fmt lint`. `make
build` will build everything including the tooling. Here's a breakdown of what
the commands do:

- `captainslog-server` runs the HTTP server process.
- `captainslog-migrate` executes database migrations.
- `captainslog-repl` starts a database client that accepts Captain's Log SQL.

Developing on the mobile client can be done with an emulator. To start an iOS
emulator and run the application:

```
cd client/mobile
flutter emulators --launch apple_ios_simulator
flutter run
```

Make sure to run `go generate` with Go modules disabled -- Kallax's generator
does not like to be ran with modules enabled:

```
GO111MODULE=off go generate ./...
```
