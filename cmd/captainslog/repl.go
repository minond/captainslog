package main

import (
	"bufio"
	"database/sql"
	"fmt"
	"io"
	"log"
	"os"
	"strings"

	"github.com/olekukonko/tablewriter"
	"github.com/spf13/cobra"

	"github.com/minond/captainslog/model"
	"github.com/minond/captainslog/query"
)

type repl struct {
	userGuid  string
	debugging bool
	stopped   bool

	db     *sql.DB
	buff   strings.Builder
	input  io.Reader
	output io.Writer
}

func (r *repl) prompt() {
	if r.buff.Len() == 0 {
		fmt.Fprint(r.output, "> ")
	} else {
		fmt.Fprint(r.output, "  ")
	}
}

func (r *repl) read() {
	reader := bufio.NewReader(r.input)
	input, _ := reader.ReadBytes('\n')
	r.buff.WriteString(" ")
	r.buff.Write(input)
}

func (r *repl) printf(f string, args ...interface{}) {
	fmt.Fprintf(r.output, f, args...)
}

func (r *repl) print(str string) {
	fmt.Fprint(r.output, str)
}

func (r *repl) process() error {
	return r.execute(r.buff.String())
}

func (r *repl) query(input string) error {
	if r.debugging {
		ast, err := query.Parse(input)
		if err != nil {
			return fmt.Errorf("syntax error: %v", err)
		}

		ast, err = query.Convert(ast, r.userGuid)
		if err != nil {
			return fmt.Errorf("conversion error: %v", err)
		}

		r.print("\n")
		r.print(ast.Print(true))
		r.print("\n")
	}

	store := model.NewEntryStore(r.db)
	cols, rows, err := query.Exec(store, input, r.userGuid)
	if err != nil {
		return fmt.Errorf("exec error: %v", err)
	}

	r.print("\n")
	r.printResults(cols, rows)
	r.print("\n")
	return nil
}

func (r *repl) execute(input string) error {
	input = strings.TrimSpace(input)

	if strings.HasSuffix(input, ";") {
		r.buff.Reset()
		return r.query(strings.TrimSuffix(input, ";"))
	}

	parts := strings.Split(input, " ")
	switch parts[0] {
	case "\\q":
		fallthrough
	case "\\quit":
		r.buff.Reset()
		r.print("goodbye\n")
		r.stopped = true

	case "\\debug":
		r.buff.Reset()
		r.debugging = !r.debugging
		r.printf("debug mode enabled: %v\n", r.debugging)

	case "\\u":
		fallthrough
	case "\\user":
		r.buff.Reset()
		r.userGuid = parts[1]
		r.printf("running as user: %s\n", r.userGuid)

	case "\\?":
		r.buff.Reset()
		r.print(`
General:
  \q				quit repl
  \d				toggle debug mode
  \u [guid]			set user guid

Help:
  \?				print this help output

`)
	}

	return nil
}

func (r *repl) printResults(cols []string, rows [][]interface{}) {
	switch len(rows) {
	case 0:
		r.print("(0 rows)\n")
	case 1:
		r.printData(cols, rows)
		r.print("(1 row)\n")
	default:
		r.printData(cols, rows)
		r.printf("(%d rows)\n", len(rows))
	}
}

func (r *repl) printData(cols []string, rows [][]interface{}) {
	table := tablewriter.NewWriter(r.output)
	table.SetBorder(false)
	table.SetHeader(cols)

	for _, row := range rows {
		ss := make([]string, len(cols))
		for i, col := range row {
			switch v := col.(type) {
			case *sql.NullString:
				if v.Valid {
					ss[i] = v.String
				} else {
					ss[i] = ""
				}
			case *sql.NullFloat64:
				if v.Valid {
					ss[i] = fmt.Sprintf("%f", v.Float64)
				} else {
					ss[i] = ""
				}
			case *sql.NullInt64:
				if v.Valid {
					ss[i] = fmt.Sprintf("%d", v.Int64)
				} else {
					ss[i] = ""
				}
			case *sql.NullBool:
				if !v.Valid {
					ss[i] = ""
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

var cmdRepl = &cobra.Command{
	Use:   "repl",
	Short: "Start database repl",
	Run: func(cmd *cobra.Command, args []string) {
		db, err := database()
		if err != nil {
			log.Fatalf("unable get database connection: %v", err)
		}
		defer db.Close()

		r := repl{
			output: os.Stdout,
			input:  os.Stdin,
			db:     db,
		}

		if err := r.execute("\\user e26e269c-0587-4094-bf01-108c61b0fa8a"); err != nil {
			r.printf("\nerror setting user: %v\n\n", err)
		}

		for !r.stopped {
			r.prompt()
			r.read()
			if err := r.process(); err != nil {
				r.printf("\nerror handling input: %v\n\n", err)
			}

		}
	},
}
