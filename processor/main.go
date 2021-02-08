package main

import (
	"database/sql"
	"os"

	internal "github.com/minond/captainslog/shared/service"
)

func main() {
	internal.InitGlobalTracer("processor")

	db, err := sql.Open("postgres", os.Getenv("PROCESSOR_DB_CONN"))
	if err != nil {
		panic(err)
	}

	service := NewService(NewRepository(db), NewProcessor())
	server := internal.NewServer(os.Getenv("PROCESSOR_HTTP_LISTEN"), service)
	server.Run()
}
