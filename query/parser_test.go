package query

import (
	"fmt"
	"testing"
)

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
		{"select and from", `select name, age, color from users`},
		{"select, from with alias", `select name, age, color from users as u`},
		{"select, from, and where with single bool value", `select name, age, color from users where true`},
		{"select, from, and where with single bool value in parens", `select name, age, color from users where (((true)))`},
		{"select, from, and where with single identifier", `select name, age, color from users where is_ok`},
		{"select, from, and where with single identifier aliased", `select u.name, u.age, u.color from users as u where u.is_ok`},
		{"select, from, and where with multiple identifiers", `select name, age, color from users where is_ok and is_alive or is_false`},
		{"select, from, and where with multiple grouped identifiers", `select name, age, color from users where ((is_ok and is_alive) or (is_false and is_true)) and true`},
		{"select, from, and where with operators", `select name, age, color from users where is_ok = true or is_alive = is_dead and age = min_age - something * multiplier / divi`},
		{"select, from, and where with grouped operators", `select name, age, color from users where (true or (is_ok = true and is_alive = is_dead and (age > max_age)))`},
		{"select, from, and where with number filter", `select name from users where age > 30`},
		{"select, from, and where with string filter", `select name from users where name like 'marcos'`},
		{"select, from, and where with or condition and two likes", `select reps, sets, weight from workouts where exercise like 'bicep' or exercise like 'bench press'`},
		{"select single expressions + from", `select 1 = 1 and 2 = 2 and 3 = 3 from users`},
		{"select multiple expressions + from", `select 1 = 1, 2 = 2, 3 = 3 from users`},
		{"select expressions with extras + from", `select distinct 1 = 1 as t1, distinct 2 = 2 as t2, distinct 3 = 3 as t3 from users as t4`},
		{"select with functions", `select max(1, 2, 3), min(weight1, weight2)`},
		{"select with expressions in functions", `select fn('four', 2 + 2)`},
		{"select with functions in functions", `select fn(fn(fn('four', 2 + 2)))`},
		// {"select + from + group by", `select min(weight), max(weight) from workouts group by exercise`},
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
