package sqlrewrite

import (
	"fmt"
	"testing"

	"github.com/minond/captainslog/querier/sqlparse"
)

func compstrmsg(msg, expecting, got string) string {
	return fmt.Sprintf(`%s

		expecting: %s

		      got: %s`, msg, expecting, got)
}

func TestRewriteEntryQuery(t *testing.T) {
	tests := []struct {
		label    string
		input    string
		expected string
	}{
		{
			"sample query 1",
			`select exercise as exercise, max(cast(weight as float)) as max from workouts where weight is not null group by exercise`,
			`select data #>> '{exercise}' as exercise, max(cast(data #>> '{weight}' as float)) as max from entries where book_id = (select id from books where name ilike 'workouts' and user_id = 21) and (user_id = 21 and (data #>> '{weight}' is not null)) group by exercise`,
		},
		{
			"sample query 2",
			`select distinct exercise as name from workouts where exercise ilike '%bicep%'`,
			`select distinct data #>> '{exercise}' as name from entries where book_id = (select id from books where name ilike 'workouts' and user_id = 21) and (user_id = 21 and (data #>> '{exercise}' ilike '%bicep%'))`,
		},
		{
			"alias is respected in order clause",
			`select exercise, count(1) as count from workouts group by exercise order by count`,
			`select data #>> '{exercise}' as exercise, count(1) as count from entries where book_id = (select id from books where name ilike 'workouts' and user_id = 21) and (user_id = 21) group by data #>> '{exercise}' order by count asc`,
		},
		{
			"select with just a function call",
			`select now()`,
			`select now() as now from entries where user_id = 21`,
		},
	}

	for _, test := range tests {
		t.Run(test.label, func(t *testing.T) {
			ast, err := sqlparse.Parse(test.input)
			if err != nil {
				t.Errorf("unexpected error parsing query: %v", err)
			}

			query, err := RewriteEntryQuery(ast, 21)
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
