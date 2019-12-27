package main

import (
	"github.com/k0kubun/pp"
	"github.com/minond/captainslog/querier/query"
)

func main() {
	sql := `select id from users`
	ast, err := query.Parse(sql)
	if err != nil {
		panic(err)
	}
	pp.Println(ast)
}
