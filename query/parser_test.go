package query

import (
	"fmt"
	"testing"
)

// var _ = `
//
// select reps, sets, weight
// from workouts
// where exercise like 'bicep'
// or exercise like 'bench press'
//
// select min(weight), max(weight)
// from workouts
// group by exercise
//
// select data ->> 'exercise', min(data ->> 'weight'), max(data ->> 'weight')
// from entries
// where (data ->> 'weight') is not null
// group by data ->> 'exercise'
// ;
//
// `

func queryMismatchMessage(expected Ast, got string) string {
	return fmt.Sprintf(`error wth query parser.

      expected: %s

           got: %s`, expected, got)
}

func TestParse_Select_QueryWithOnlySelect(t *testing.T) {
	sql := `select name, age, color`
	ast, err := Parse(sql)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}
	if ast.String() != sql {
		t.Error(queryMismatchMessage(ast, sql))
	}
}
