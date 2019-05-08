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

func queryMismatchMessage(expected string, returned Ast) string {
	return fmt.Sprintf(`error wth query parser.

expected: %s

returned: %s`, expected, returned)
}

func TestParse_Select_Select(t *testing.T) {
	sql := `select name, age, color`
	ast, err := Parse(sql)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}
	if ast.String() != sql {
		t.Error(queryMismatchMessage(sql, ast))
	}
}

func TestParse_Select_SelectWithAlias(t *testing.T) {
	sql := `select name as n, age as a, color as c`
	ast, err := Parse(sql)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}
	if ast.String() != sql {
		t.Error(queryMismatchMessage(sql, ast))
	}
}

func TestParse_Select_SelectFrom(t *testing.T) {
	sql := `select name, age, color from users`
	ast, err := Parse(sql)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}
	if ast.String() != sql {
		t.Error(queryMismatchMessage(sql, ast))
	}
}

func TestParse_Select_SelectFromWithAlias(t *testing.T) {
	sql := `select name, age, color from users as u`
	ast, err := Parse(sql)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}
	if ast.String() != sql {
		t.Error(queryMismatchMessage(sql, ast))
	}
}
