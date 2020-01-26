package testing

import (
	"context"
)

type TestRepository struct {
	Cols []string
	Rows [][]interface{}
	Err  error
}

func (r TestRepository) Execute(ctx context.Context, query string) ([]string, [][]interface{}, error) {
	return r.Cols, r.Rows, r.Err
}
