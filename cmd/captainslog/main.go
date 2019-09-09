package main

import (
	"github.com/spf13/cobra"
)

func main() {
	var app = &cobra.Command{Use: "captainslog"}
	app.AddCommand(
		cmdMigrate,
		cmdRepl,
		cmdServer,
		cmdUser,
	)
	_ = app.Execute()
}
