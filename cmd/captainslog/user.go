package main

import (
	"bufio"
	"context"
	"fmt"
	"log"
	"math/rand"
	"os"
	"strconv"
	"strings"
	"syscall"

	"github.com/spf13/cobra"
	"golang.org/x/crypto/ssh/terminal"
	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/model"
	"github.com/minond/captainslog/service"
)

func init() {
	cmdUser.AddCommand(cmdUserCreate, cmdUserDummy)
}

var cmdUser = &cobra.Command{
	Use:   "user",
	Short: "Manage users",
}

// TODO Once authentication is complete remove this
var cmdUserDummy = &cobra.Command{
	Use:   "dummy",
	Short: "Create a dummy test user",
	Run: func(cmd *cobra.Command, args []string) {
		db, err := database()
		if err != nil {
			log.Fatalf("[ERROR] error opening database connection: %v", err)
		}
		defer db.Close()

		guid, _ := kallax.NewULIDFromText("e26e269c-0587-4094-bf01-108c61b0fa8a")
		name := "Test User"
		email := "test@testing.co"
		password := strconv.Itoa(rand.Int())

		user, err := model.NewUser(name, email, password)
		if err != nil {
			log.Fatalf("error: %v", err)
		}
		user.GUID = guid

		userStore := model.NewUserStore(db)
		if err = userStore.Insert(user); err != nil {
			log.Fatalf("error: %v", err)
		} else {
			fmt.Println("done")
		}
	},
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
