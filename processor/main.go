package main

import "log"

func main() {
	server, err := NewServerFromEnv()
	if err != nil {
		panic(err)
	}

	log.Printf("listening on %s", server.Addr())
	go server.Start()
	server.ListenForShutdown()
	log.Print("server shutdown is complete")
}
