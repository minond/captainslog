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

func TestParse_PossibleQueries(t *testing.T) {
	tests := []struct {
		label, sql string
	}{
		{"select", `select name, age, color`},
		{"select with alias", `select name as n, age as a, color as c`},
		{"select + from", `select name, age, color from users`},
		{"select + from with alias", `select name, age, color from users as u`},
		{"select + from + where with single bool value", `select name, age, color from users where true`},
		{"select + from + where with single bool value in parens", `select name, age, color from users where (((true)))`},
		{"select + from + where with single identifier", `select name, age, color from users where is_ok`},
		{"select + from + where with single identifier aliased", `select u.name, u.age, u.color from users as u where u.is_ok`},
		{"select + from + where with multiple identifiers", `select name, age, color from users where is_ok and is_alive or is_false`},
		{"select + from + where with multiple grouped identifiers", `select name, age, color from users where ((is_ok and is_alive) or (is_false and is_true)) and true`},
		{"select + from + where with operators", `select name, age, color from users where is_ok = true or is_alive = is_dead and age = min_age - something * multiplier / divi`},
		{"select + from + where with grouped operators", `select name, age, color from users where (true or (is_ok = true and is_alive = is_dead and (age > max_age)))`},
	}
	for _, test := range tests {
		t.Run(test.label, func(t *testing.T) {
			ast, err := Parse(test.sql)
			if err != nil {
				t.Errorf("unexpected error: %v", err)
			} else if ast.String() != test.sql {
				t.Error(queryMismatchMessage(test.sql, ast))
			}
		})
	}
}
