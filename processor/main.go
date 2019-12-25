package main

import (
	"log"
	"os"
)

func main() {
	server, err := NewServer(ServerConfig{
		dbConn:     os.Getenv("PROCESSOR_DB_CONN"),
		httpListen: os.Getenv("PROCESSOR_HTTP_LISTEN"),
	})
	if err != nil {
		panic(err)
	}

	log.Printf("listening on %s", os.Getenv("PROCESSOR_HTTP_LISTEN"))
	go server.Start()
	server.ListenForShutdown()
	log.Print("server shutdown is complete")
}
