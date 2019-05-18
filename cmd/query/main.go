package main

import (
	"bufio"
	"database/sql"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/olekukonko/tablewriter"

	"github.com/minond/captainslog/model"
	"github.com/minond/captainslog/query"
)

func main() {
	// XXX
	userGUID := "e26e269c-0587-4094-bf01-108c61b0fa8a"
	db, err := sql.Open(os.Getenv("DATABASE_DRIVER"), os.Getenv("DATABASE_CONN"))
	if err != nil {
		log.Fatalf("unable get database connection: %v", err)
	}
	defer db.Close()

	var buff string

	reader := bufio.NewReader(os.Stdin)
	store := model.NewEntryStore(db)

	for {
		if buff == "" {
			fmt.Print("> ")
		} else {
			fmt.Print("  ")
		}

		input, _ := reader.ReadString('\n')
		buff = strings.TrimSpace(buff + " " + input)
		if buff == "exit" {
			fmt.Println("goodbye")
			break
		}
		if !strings.HasSuffix(buff, ";") {
			continue
		}
		buff = strings.TrimSuffix(buff, ";")
		cols, rows, err := query.Exec(store, buff, userGUID)
		buff = ""
		if err != nil {
			fmt.Printf("error: %v\n\n", err)
			continue
		}
		fmt.Println("")
		printData(cols, rows)
		fmt.Println("")
	}
}

func printData(cols []string, rows [][]interface{}) {
	table := tablewriter.NewWriter(os.Stdout)
	table.SetBorder(false)
	table.SetHeader(cols)
	for _, row := range rows {
		ss := make([]string, len(cols))
		for i, col := range row {
			ss[i] = fmt.Sprintf("%v", col)
		}
		table.Append(ss)
	}
	table.Render()
}
