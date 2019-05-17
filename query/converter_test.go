package query

import (
	"fmt"
	"testing"
)

func compstrmsg(msg, expecting, got string) string {
	return fmt.Sprintf(`%s

		expecting: %s

		      got: %s`, msg, expecting, got)
}

func TestConvert_convertsSelectsToDataSelectors(t *testing.T) {
	tests := []struct {
		label    string
		input    string
		expected string
	}{
		{
			"columns are converted to data selctros",
			`select exercise, reps, sets`,
			`SELECT __entry.data #>>'{exercise}', __entry.data #>>'{reps}', __entry.data #>>'{sets}' FROM entries __entry`,
		},
		{
			"from clause is converted into a sub query selecting the book",
			`select exercise from workouts`,
			`SELECT __entry.data #>>'{exercise}' FROM entries __entry WHERE __entry.book_guid = (select guid from books where name like $1)`,
		},
		{
			"cast in select clause passed to function",
			`select max(cast(reps as decimal)) from workouts`,
			`SELECT max(CAST(__entry.data #>>'{reps}' as decimal)) FROM entries __entry WHERE __entry.book_guid = (select guid from books where name like $1)`,
		},
	}

	for _, test := range tests {
		t.Run(test.label, func(t *testing.T) {
			ast, err := Parse(test.input)
			if err != nil {
				t.Errorf("unexpected error parsing query: %v", err)
			}
			query, err := Convert(ast)
			if err != nil {
				t.Errorf("unexpected error converting query: %v", err)
			}
			if query.String() != test.expected {
				t.Errorf(compstrmsg("bad conversion",
					test.expected, query.String()))
			}
		})
	}
}
