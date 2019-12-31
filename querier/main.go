package main

import (
	"database/sql"
	"os"

	_ "github.com/lib/pq"
)

func main() {
	db, err := sql.Open("postgres", os.Getenv("QUERIER_DB_CONN"))
	if err != nil {
		panic(err)
	}

	newRepl(db).run()
}
