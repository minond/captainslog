package main

import (
	"database/sql"
	"flag"
	"os"

	"github.com/minond/captainslog/querier/repl"
	"github.com/minond/captainslog/querier/repository"
	internal "github.com/minond/captainslog/shared/service"

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
	internal.InitGlobalTracer("querier")

	db, err := sql.Open("postgres", os.Getenv("QUERIER_DB_CONN"))
	if err != nil {
		panic(err)
	}

	repo := repository.New(db)
	service := NewService(repo)
	server := internal.NewServer(os.Getenv("QUERIER_HTTP_LISTEN"), service)
	server.Run()
}

func runRepl() {
	config := ConfigFromEnv()
	db, err := sql.Open("postgres", config.dbConn)
	if err != nil {
		panic(err)
	}

	repl.New(repository.New(db)).Run()
}
