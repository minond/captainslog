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
	mig, err := migrate.New("file://migrations/", url)
	if err != nil {
		log.Fatalf("unable to create migration instance: %v", err)
	}
	defer mig.Close()

	switch cmd {
	case "version":
		printVersion(mig)
	case "up":
		printError(mig.Up())
		printVersion(mig)
	case "down":
		printError(mig.Steps(-1))
		printVersion(mig)
	}
}

func printError(err error) {
	if err == migrate.ErrNoChange {
		log.Print("no changes to apply")
	} else if err == migrate.ErrNilVersion {
		log.Print("no migrations to apply")
	} else if err != nil {
		log.Fatalf("error running migration: %v", err)
	}
}

func printVersion(mig *migrate.Migrate) {
	version, dirty, err := mig.Version()
	if err != nil {
		log.Fatalf("error running version command: %v", err)
	}
	log.Printf("version = %d, dirty = %v", version, dirty)
}
