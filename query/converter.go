package query

import (
	"errors"
	"fmt"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/model"
)

func Convert(ast Ast) (*model.EntryQuery, error) {
	query := model.NewEntryQuery()
	switch stmt := ast.(type) {
	case *selectStmt:
		for _, col := range stmt.columns {
			field, err := exprToSchemaField(col.val)
			if err != nil {
				return nil, err
			}
			query.Select(field)
		}
		if stmt.from != nil {
			cond, err := tableToCondition(*stmt.from)
			if err != nil {
				return nil, err
			}
			query.Where(cond)
		}
		return query, nil
	}

	return nil, fmt.Errorf("invalid query type: %v", ast.queryType())
}

func tableToCondition(from table) (kallax.Condition, error) {
	return model.Subquery(
		model.Schema.Entry.BookFK, model.Eq,
		model.Schema.Book.GUID, model.Schema.Book.BaseSchema,
		model.Schema.Book.Name, model.Like, from.name,
	), nil
}

func exprToSchemaField(ex expr) (kallax.SchemaField, error) {
	switch c := ex.(type) {
	case identifier:
		return kallax.NewJSONSchemaKey(kallax.JSONText, "data", c.name), nil
	case application:
		// Handle casts for json data fields here.
		if c.fn == "cast" && len(c.args) == 1 {
			switch c2 := c.args[0].(type) {
			case identifier:
				typ := kallax.JSONKeyType(c2.as)
				return kallax.NewJSONSchemaKey(typ, "data", c2.name), nil
			}
		}

		params := make([]kallax.SchemaField, len(c.args))
		for i, arg := range c.args {
			field, err := exprToSchemaField(arg)
			if err != nil {
				return nil, err
			}
			params[i] = field
		}
		return model.FunctionSelect(c.fn, params...), nil
	}
	return nil, errors.New("unknown column")
}
