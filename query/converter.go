package query

import (
	"fmt"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/model"
)

func Convert(ast Ast) (*model.EntryQuery, error) {
	query := model.NewEntryQuery()
	switch stmt := ast.(type) {
	case *selectStmt:
		for _, col := range stmt.columns {
			if err := selectColumn(query, col); err != nil {
				return nil, err
			}
		}
		if stmt.from != nil {
			filterByBookName(query, *stmt.from)
		}
		return query, nil
	}

	return nil, fmt.Errorf("invalid query type: %v", ast.queryType())
}

func filterByBookName(query *model.EntryQuery, from table) error {
	query.Where(model.Subquery(
		model.Schema.Entry.BookFK, model.Eq,
		model.Schema.Book.GUID, model.Schema.Book.BaseSchema,
		model.Schema.Book.Name, model.Like, from.name,
	))
	return nil
}

func selectColumn(query *model.EntryQuery, col column) error {
	switch c := col.val.(type) {
	case identifier:
		query.Select(kallax.NewJSONSchemaKey(kallax.JSONAny, "data", c.name))
	}
	return nil
}
