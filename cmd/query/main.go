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
	var userGUID string
	setUserGUID := func(s string) {
		fmt.Printf("running as %s\n", s)
		userGUID = s
	}
	db, err := sql.Open(os.Getenv("DATABASE_DRIVER"), os.Getenv("DATABASE_CONN"))
	if err != nil {
		log.Fatalf("unable get database connection: %v", err)
	}
	defer db.Close()

	var buff string
	var debugging bool

	reader := bufio.NewReader(os.Stdin)
	store := model.NewEntryStore(db)

	setUserGUID("e26e269c-0587-4094-bf01-108c61b0fa8a")

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
		} else if buff == "debug" {
			buff = ""
			debugging = !debugging
			if debugging {
				fmt.Println("debug on")
			} else {
				fmt.Println("debug off")
			}
			continue
		} else if strings.HasPrefix(buff, "set user") {
			setUserGUID(strings.TrimSpace(strings.TrimPrefix(buff, "set user")))
			buff = ""
			continue
		} else if !strings.HasSuffix(buff, ";") {
			continue
		}
		buff = strings.TrimSuffix(buff, ";")

		if debugging {
			ast, err := query.Parse(buff)
			if err != nil {
				fmt.Printf("\nsyntax error: %v\n", err)
				buff = ""
				continue
			}

			ast, err = query.Convert(ast, userGUID)
			if err != nil {
				fmt.Printf("\nconversion error: %v\n", err)
				buff = ""
				continue
			}

			fmt.Println("\ngenerated query:")
			fmt.Println(ast.Print(true))
		}

		cols, rows, err := query.Exec(store, buff, userGUID)
		if err != nil {
			fmt.Printf("\nerror: %v\n\n", err)
			buff = ""
			continue
		}
		fmt.Println("")
		printData(cols, rows)
		fmt.Println("")
		buff = ""
	}
}

func printData(cols []string, rows [][]interface{}) {
	table := tablewriter.NewWriter(os.Stdout)
	table.SetBorder(true)
	table.SetHeader(cols)
	for _, row := range rows {
		ss := make([]string, len(cols))
		for i, col := range row {
			switch v := col.(type) {
			case *sql.NullString:
				if v.Valid {
					ss[i] = v.String
				} else {
					ss[i] = "NULL"
				}
			case *sql.NullFloat64:
				if v.Valid {
					ss[i] = fmt.Sprintf("%f", v.Float64)
				} else {
					ss[i] = "NULL"
				}
			case *sql.NullInt64:
				if v.Valid {
					ss[i] = fmt.Sprintf("%d", v.Int64)
				} else {
					ss[i] = "NULL"
				}
			case *sql.NullBool:
				if !v.Valid {
					ss[i] = "NULL"
				} else if v.Bool {
					ss[i] = "t"
				} else {
					ss[i] = "f"
				}
			default:
				ss[i] = fmt.Sprintf("%v", col)
			}
		}
		table.Append(ss)
	}
	table.Render()
}
