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

func TestConvert_rewriteAst(t *testing.T) {
	tests := []struct {
		label    string
		input    string
		expected string
	}{
		{
			"columns are converted to data selectors",
			`select exercise, reps, sets`,
			`select data #>> '{exercise}', data #>> '{reps}', data #>> '{sets}'`,
		},
		{
			"from clause is converted into a sub query selecting the book",
			`select exercise from workouts`,
			`select data #>> '{exercise}' from workouts`,
		},
		{
			"cast in select clause passed to function",
			`select max(cast(reps as decimal)) from workouts`,
			`select max(cast(data #>> '{reps}' as decimal)) from workouts`,
		},
		{
			"is not null in where clause",
			`select exercise, max(cast(weight as decimal)) as weight from workouts where weight is not null`,
			`select data #>> '{exercise}', max(cast(data #>> '{weight}' as decimal)) as weight from workouts where weight is not null`,
		},
		{
			"group by field",
			`select exercise as exercise, max(cast(weight as float)) as weight from workouts where weight is not null group by exercise`,
			`select data #>> '{exercise}' as exercise, max(cast(data #>> '{weight}' as float)) as weight from workouts where weight is not null group by exercise`,
		},
		{
			"grouping in where clause",
			`select exercise from workouts where (weight is not null) and true`,
			`select data #>> '{exercise}' from workouts where (data #>> '{weight}' is not null) and true`,
		},
	}

	for _, test := range tests {
		t.Run(test.label, func(t *testing.T) {
			ast, err := Parse(test.input)
			if err != nil {
				t.Errorf("unexpected error parsing query: %v", err)
			}
			query, err := rewriteAst(ast, make(environment))
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

func TestConvert_rewriteFromClause(t *testing.T) {
	tests := []struct {
		label    string
		input    string
		expected string
	}{
		{
			"a subquery filter is added",
			`select exercise from workouts`,
			`select exercise from entries where book_guid = (select guid from books where name ilike 'workouts')`,
		},
		{
			"previous filters are kept",
			`select exercise from workouts where true and false and 1`,
			`select exercise from entries where book_guid = (select guid from books where name ilike 'workouts') and (true and false and 1)`,
		},
	}

	for _, test := range tests {
		t.Run(test.label, func(t *testing.T) {
			ast, err := Parse(test.input)
			if err != nil {
				t.Errorf("unexpected error parsing query: %v", err)
			}
			query := rewriteFromClause(ast.(*selectStmt))
			if query.String() != test.expected {
				t.Errorf(compstrmsg("bad conversion",
					test.expected, query.String()))
			}
		})
	}
}

func TestConvert_Convert(t *testing.T) {
	tests := []struct {
		label    string
		input    string
		expected string
	}{
		{
			"sample query 1",
			`select exercise as exercise, max(cast(weight as float)) from workouts where weight is not null group by exercise`,
			`select data #>> '{exercise}' as exercise, max(cast(data #>> '{weight}' as float)) from entries where book_guid = (select guid from books where name ilike 'workouts') and (data #>> '{weight}' is not null) group by exercise`,
		},
		{
			"sample query 2",
			`select distinct exercise as name from workouts where exercise ilike '%bicep%'`,
			`select distinct data #>> '{exercise}' as name from entries where book_guid = (select guid from books where name ilike 'workouts') and (data #>> '{exercise}' ilike '%bicep%')`,
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
