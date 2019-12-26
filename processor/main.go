package main

import (
	"log"
	"os"
)

func main() {
	server, err := NewServerFromEnv()
	if err != nil {
		panic(err)
	}

	log.Printf("listening on %s", os.Getenv("PROCESSOR_HTTP_LISTEN"))
	go server.Start()
	server.ListenForShutdown()
	log.Print("server shutdown is complete")
}
