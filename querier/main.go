package main

import (
	"database/sql"
	"flag"
	"log"

	"github.com/minond/captainslog/querier/repl"
	"github.com/minond/captainslog/querier/repository"

	_ "github.com/lib/pq"
)

var (
	replMode = flag.Bool("repl", false, "start repl instead of server")
)

func main() {
	flag.Parse()

	if *replMode {
		runRepl()
	} else {
		runServer()
	}
}

func runServer() {
	server, err := NewServerFromEnv()
	if err != nil {
		panic(err)
	}

	log.Printf("listening on %s", server.Addr())
	go server.Start()
	server.ListenForShutdown()
	log.Print("server shutdown is complete")
}

func runRepl() {
	config := ConfigFromEnv()
	db, err := sql.Open("postgres", config.dbConn)
	if err != nil {
		panic(err)
	}

	repl.New(repository.New(db)).Run()
}
