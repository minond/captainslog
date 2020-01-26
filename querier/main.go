package main

import (
	"database/sql"
	"os"

	"github.com/minond/captainslog/querier/repl"
	"github.com/minond/captainslog/querier/repository"

	_ "github.com/lib/pq"
)

func main() {
	db, err := sql.Open("postgres", os.Getenv("QUERIER_DB_CONN"))
	if err != nil {
		panic(err)
	}

	repl.New(repository.New(db)).Run()
}
