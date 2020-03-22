package main

import (
	"database/sql"
	"os"

	"github.com/minond/captainslog/internal"
)

func main() {
	db, err := sql.Open("postgres", os.Getenv("PROCESSOR_DB_CONN"))
	if err != nil {
		panic(err)
	}

	service := NewService(NewRepository(db), NewProcessor())
	server := internal.NewServer(os.Getenv("PROCESSOR_HTTP_LISTEN"), service)
	server.Run()
}
