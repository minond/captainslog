package main

import (
	"fmt"

	"github.com/k0kubun/pp"
	"github.com/minond/captainslog/querier/query"
)

func main() {
	sql := `
select cast(created_at as integer) as x,
  cast(weight as float) as y
from workouts
where exercise ilike 'Bench Press'
and weight is not null
order by created_at asc`

	ast, err := query.Parse(sql)
	if err != nil {
		panic(err)
	}
	pp.Println(ast)
	fmt.Println(ast.Print(true))
}
