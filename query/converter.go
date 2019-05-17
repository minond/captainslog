package query

import (
	"errors"
	"fmt"
	"strings"

	"gopkg.in/src-d/go-kallax.v1"

	"github.com/minond/captainslog/model"
)

type qir struct {
	kallax.ToSqler
	query   *model.EntryQuery
	groupBy []expr
}

func (q *qir) ToSql() (string, []interface{}, error) {
	var groupBy string
	query, args, err := q.query.ToSql()
	if err == nil && len(q.groupBy) != 0 {
		parts := make([]string, len(q.groupBy))
		for i, expr := range q.groupBy {
			field, err := exprToSchemaField(expr)
			if err != nil {
				return "", nil, err
			}
			parts[i] = field.String()
		}
		groupBy = " group by " + strings.Join(parts, ", ")
	}
	return query + groupBy, args, nil
}

func (q *qir) String() string {
	query, _, _ := q.ToSql()
	return query
}

func Convert(ast Ast) (*qir, error) {
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
		if stmt.where != nil {
			cond, err := exprToCondition(stmt.where)
			if err != nil {
				return nil, err
			}
			query.Where(cond)
		}
		return &qir{
			query:   query,
			groupBy: stmt.groupBy,
		}, nil
	}

	return nil, fmt.Errorf("invalid query type: %v", ast.queryType())
}

func tableToCondition(from table) (kallax.Condition, error) {
	return model.Subquery(
		model.Schema.Entry.BookFK, model.Eq,
		model.Schema.Book.GUID, model.Schema.Book.BaseSchema,
		model.Schema.Book.Name, model.Ilike, from.name,
	), nil
}

func exprToCondition(ex expr) (kallax.Condition, error) {
	switch c := ex.(type) {
	case isNull:
		field, err := exprToSchemaField(c.expr)
		if err != nil {
			return nil, err
		}
		if c.not {
			return model.IsNotNull(field), nil
		}
		return model.IsNull(field), nil
	}
	return nil, errors.New("unknown expression")
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
	return nil, errors.New("unknown expression")
}
