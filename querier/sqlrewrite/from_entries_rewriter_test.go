package sqlrewrite

import (
	"testing"

	"github.com/minond/captainslog/querier/sqlparse"
)

func TestFromEntriesRewriter_RewriteSelect(t *testing.T) {
	tests := []struct {
		label    string
		input    string
		expected string
	}{
		{
			"a subquery filter is added",
			`select exercise from workouts`,
			`select exercise from entries`,
		},
		{
			"previous filters are kept",
			`select exercise from workouts where true and false and 1`,
			`select exercise from entries where true and false and 1`,
		},
	}

	for _, test := range tests {
		t.Run(test.label, func(t *testing.T) {
			ast, err := sqlparse.Parse(test.input)
			if err != nil {
				t.Errorf("unexpected error parsing query: %v", err)
			}

			rewriter := FromEntriesRewriter{}
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
