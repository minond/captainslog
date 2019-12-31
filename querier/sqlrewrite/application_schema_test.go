package sqlrewrite

import (
	"testing"

	"github.com/minond/captainslog/querier/sqlparse"
)

func TestApplicationRewrite_RewriteSelect(t *testing.T) {
	tests := []struct {
		label    string
		input    string
		expected string
	}{
		{
			"columns are converted to data selectors",
			`select exercise, reps, sets`,
			`select data #>> '{exercise}' as exercise, data #>> '{reps}' as reps, data #>> '{sets}' as sets`,
		},
		{
			"from clause is converted into a sub query selecting the book",
			`select exercise from workouts`,
			`select data #>> '{exercise}' as exercise from workouts`,
		},
		{
			"cast in select clause passed to function",
			`select max(cast(reps as decimal)) from workouts`,
			`select max(cast(data #>> '{reps}' as decimal)) as max from workouts`,
		},
		{
			"is not null in where clause",
			`select exercise, max(cast(weight as decimal)) as weight from workouts where weight is not null`,
			`select data #>> '{exercise}' as exercise, max(cast(data #>> '{weight}' as decimal)) as weight from workouts where data #>> '{weight}' is not null`,
		},
		{
			"group by field",
			`select exercise as exercise, max(cast(weight as float)) as weight from workouts where weight is not null group by exercise`,
			`select data #>> '{exercise}' as exercise, max(cast(data #>> '{weight}' as float)) as weight from workouts where data #>> '{weight}' is not null group by exercise`,
		},
		{
			"grouping in where clause",
			`select exercise from workouts where (weight is not null) and true`,
			`select data #>> '{exercise}' as exercise from workouts where (data #>> '{weight}' is not null) and true`,
		},
	}

	for _, test := range tests {
		t.Run(test.label, func(t *testing.T) {
			ast, err := sqlparse.Parse(test.input)
			if err != nil {
				t.Errorf("unexpected error parsing query: %v", err)
			}

			rewriter := ApplicationSchema{}
			query, _, err := rewriter.RewriteSelect(ast.(*sqlparse.SelectStmt), make(Environment))
			if err != nil {
				t.Errorf("unexpected error converting query: %v", err)
			}

			if query.String() != test.expected {
				t.Errorf(compstrmsg("bad conversion in "+test.label,
					test.expected, query.String()))
			}
		})
	}
}
