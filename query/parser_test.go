package query

import (
	"fmt"
	"testing"
)

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
