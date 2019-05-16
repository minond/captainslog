package query

import (
	"fmt"
	"log"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/model"
)

func Convert(ast Ast) (*model.EntryQuery, error) {
	query := model.NewEntryQuery()
	switch stmt := ast.(type) {
	case *selectStmt:
		fmt.Println("S")
		for _, col := range stmt.columns {
			if err := selectColumn(col, query); err != nil {
				return nil, err
			}
		}
		return query, nil
	}

	return nil, fmt.Errorf("invalid query type: %v", ast.queryType())
}

func selectColumn(col column, query *model.EntryQuery) error {
	switch c := col.val.(type) {
	case identifier:
		log.Printf("column %s", c.name)
		query.Select(kallax.NewJSONSchemaKey(kallax.JSONAny, "data", c.name))
	}
	return nil
}
