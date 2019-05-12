package main

import (
	"log"
	"os"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	_ "github.com/lib/pq"
)

func main() {
	if len(os.Args) == 1 {
		log.Fatalf("missing command, must be one of: up, down, version")
	}
	cmd := os.Args[1]

	url := os.Getenv("DATABASE_URL")
	mig, err := migrate.New("file:///Users/marcosmindon/code/captainslog/migrations/", url)
	if err != nil {
		log.Fatalf("unable to create migration instance: %v", err)
	}
	defer mig.Close()

	switch cmd {
	case "version":
		version, dirty, err := mig.Version()
		if err != nil {
			log.Fatalf("error running version command: %v", err)
		}
		log.Printf("version = %d, dirty = %v", version, dirty)
	case "up":
		log.Print("migrating up...")
		err := mig.Up()
		if err == migrate.ErrNoChange {
			log.Print("no changes to apply")
		} else if err == migrate.ErrNilVersion {
			log.Print("no migrations to apply")
		} else {
			log.Fatalf("error running migration: %v", err)
		}
		log.Print("done")
	}
}
