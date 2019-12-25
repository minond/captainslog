package main

import (
	"database/sql"
	"log"
	"net/http"
	"os"
)

func main() {
	dbConn := os.Getenv("PROCESSOR_DB_CONN")
	httpListen := os.Getenv("PROCESSOR_HTTP_LISTEN")

	log.Println("setting up database connection")
	db, err := sql.Open("postgres", dbConn)
	if err != nil {
		log.Fatalf("unable to open database connection: %v", err)
	}

	repo := NewRepository(db)
	serv := NewService(repo)

	log.Printf("listening on %s", httpListen)
	http.Handle("/", serv)
	log.Fatal(http.ListenAndServe(httpListen, nil))
}
