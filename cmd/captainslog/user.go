package main

import (
	"bufio"
	"context"
	"fmt"
	"log"
	"os"
	"strings"
	"syscall"

	"github.com/spf13/cobra"
	"golang.org/x/crypto/ssh/terminal"

	"github.com/minond/captainslog/service"
)

func init() {
	cmdUser.AddCommand(cmdUserCreate)
}

var cmdUser = &cobra.Command{
	Use:   "user",
	Short: "Manage users",
}

var cmdUserCreate = &cobra.Command{
	Use:   "create",
	Short: "Create a user",
	Run: func(cmd *cobra.Command, args []string) {
		db, err := database()
		if err != nil {
			log.Fatalf("[ERROR] error opening database connection: %v", err)
		}
		defer db.Close()

		name := read("name: ")
		email := read("email: ")
		plainPassword := readPassword("password: ")

		ctx := context.Background()
		req := &service.UserCreateRequest{
			Name:          name,
			Email:         email,
			PlainPassword: plainPassword,
		}

		userService := service.NewUserService(db)
		user, err := userService.Create(ctx, req)
		if err != nil {
			fmt.Printf("error: %v\n", err)
		} else {
			fmt.Printf("guid: %s\n", user.GUID)
		}
	},
}

func read(question string) string {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print(question)
	text, _ := reader.ReadString('\n')
	return strings.TrimSpace(text)
}

func readPassword(question string) string {
	fmt.Print(question)
	bs, _ := terminal.ReadPassword(int(syscall.Stdin))
	fmt.Print("*****\n")
	return strings.TrimSpace(string(bs))
}
