package repl

import (
	"bufio"
	"context"
	"database/sql"
	"errors"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"

	"github.com/k0kubun/pp"
	"github.com/minond/captainslog/querier/repository"
	"github.com/minond/captainslog/querier/sqlparse"
	"github.com/minond/captainslog/querier/sqlrewrite"
	"github.com/olekukonko/tablewriter"
)

type repl struct {
	repo   repository.Repository
	buff   strings.Builder
	input  io.Reader
	output io.Writer

	userID  int64
	running bool
	debug   bool
}

func New(repo repository.Repository) *repl {
	return &repl{
		repo:   repo,
		output: os.Stdout,
		input:  os.Stdin,
	}
}

func (r *repl) Run() {
	r.running = true

	for r.running {
		r.prompt()
		r.read()
		if err := r.process(); err != nil {
			r.printf("error handling input: %v\n", err)
		}
	}
}

func (r *repl) prompt() {
	if r.buff.Len() == 0 {
		fmt.Fprintf(r.output, "user(%v)> ", r.userID)
	} else {
		fmt.Fprintf(r.output, "user(%v)* ", r.userID)
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
	input := strings.TrimSpace(r.buff.String())
	if strings.HasPrefix(input, "\\") {
		r.buff.Reset()
		return r.execute(input)
	} else if strings.HasSuffix(input, ";") {
		r.buff.Reset()
		return r.query(strings.TrimSuffix(input, ";"))
	}
	return nil
}

func (r *repl) query(input string) error {
	if r.userID == 0 {
		return errors.New("no active user, set one with `\\user [id]`")
	}

	raw, err := sqlparse.Parse(input)
	if err != nil {
		return err
	}

	sql, err := sqlrewrite.RewriteEntryQuery(raw, r.userID)
	if err != nil {
		return err
	}

	if r.debug {
		pp.Println(sql)
		return nil
	}

	cols, rows, err := r.repo.Execute(context.Background(), sql.String())
	if err != nil {
		return err
	}

	r.printResults(cols, rows)
	r.print("\n")
	return nil
}

func (r *repl) execute(input string) error {
	parts := strings.Split(input, " ")
	switch parts[0] {
	case "\\q":
		fallthrough
	case "\\quit":
		r.print("goodbye\n")
		r.running = false

	case "\\d":
		fallthrough
	case "\\debug":
		r.debug = !r.debug
		r.printf("set debug to %v\n", r.debug)

	case "\\u":
		fallthrough
	case "\\user":
		idStr := parts[1]
		id, err := strconv.Atoi(idStr)
		if err != nil {
			return err
		}
		r.userID = int64(id)
		r.printf("set user to %d\n", r.userID)

	case "\\?":
		r.print(`General:
  \q, \quit				quit repl
  \d, \debug			toggle debug mode
  \u, \user [id]		set the active user id

Help:
  \?					print this help output
`)

	default:
		return fmt.Errorf("invalid command: `%s`, try \\? for help.", parts[0])
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
			case *repository.NullTime:
				if v.Valid {
					ss[i] = fmt.Sprintf("%s", v.Time)
				} else {
					ss[i] = ""
				}
			default:
				ss[i] = fmt.Sprintf("%v", col)
			}
		}
		table.Append(ss)
	}

	table.Render()
}
