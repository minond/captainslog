package main

import (
	"github.com/spf13/cobra"
)

func main() {
	var app = &cobra.Command{Use: "captainslog"}
	app.AddCommand(cmdServer, cmdRepl, cmdMigrate)
	_ = app.Execute()
}
