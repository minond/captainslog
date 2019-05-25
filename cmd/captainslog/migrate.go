package main

import (
	"log"
	"os"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	_ "github.com/lib/pq"
	"github.com/spf13/cobra"
)

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

func migrations() *migrate.Migrate {
	url := os.Getenv("DATABASE_URL")
	mig, err := migrate.New("file://migrations/", url)
	if err != nil {
		log.Fatalf("unable to create migration instance: %v", err)
	}
	return mig
}

var cmdMigrate = &cobra.Command{
	Use:   "migrate",
	Short: "Run database migrations",
}

var cmdMigrateUp = &cobra.Command{
	Use:   "up",
	Short: "Migrate to latest database migration",
	Run: func(cmd *cobra.Command, args []string) {
		mig := migrations()
		defer mig.Close()
		printError(mig.Up())
		printVersion(mig)
	},
}

var cmdMigrateDown = &cobra.Command{
	Use:   "down",
	Short: "Migrate to previous migration version",
	Run: func(cmd *cobra.Command, args []string) {
		mig := migrations()
		defer mig.Close()
		printError(mig.Steps(-1))
		printVersion(mig)
	},
}

var cmdMigrateVersion = &cobra.Command{
	Use:   "version",
	Short: "Print database version",
	Run: func(cmd *cobra.Command, args []string) {
		mig := migrations()
		defer mig.Close()
		printVersion(mig)
	},
}

func init() {
	cmdMigrate.AddCommand(cmdMigrateUp, cmdMigrateDown, cmdMigrateVersion)
}
