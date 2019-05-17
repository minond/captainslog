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
		{"select conversion", `select exercise, reps, sets`, `SELECT __entry.data #>'{exercise}', __entry.data #>'{reps}', __entry.data #>'{sets}' FROM entries __entry`},
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
