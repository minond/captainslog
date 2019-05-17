package model

import (
	"fmt"
	"strings"
	"time"

	"gopkg.in/src-d/go-kallax.v1"
)

type between struct {
	kallax.ToSqler

	col      string
	from, to interface{}
}

func (b *between) ToSql() (string, []interface{}, error) {
	sql := b.col + " between ? and ?"
	args := []interface{}{b.from, b.to}
	return sql, args, nil
}

func Between(col kallax.SchemaField, from, to interface{}) kallax.Condition {
	return func(schema kallax.Schema) kallax.ToSqler {
		return &between{
			col:  col.QualifiedName(schema),
			from: from,
			to:   to,
		}
	}
}

func BetweenTimes(col kallax.SchemaField, from, to time.Time) kallax.Condition {
	return Between(col,
		from.UTC().Format(time.RFC3339),
		to.UTC().Format(time.RFC3339))
}

type op uint8

const (
	Eq op = iota
	Like
)

func (o op) String() string {
	switch o {
	case Like:
		return "like"
	default:
		return "="
	}
}

type subquery struct {
	kallax.ToSqler

	sourceCol    string
	sourceOp     op
	destSelCol   kallax.SchemaField
	destTable    *kallax.BaseSchema
	destWhereCol kallax.SchemaField
	destOp       op
	destVal      interface{}
}

func (s *subquery) ToSql() (string, []interface{}, error) {
	sql := fmt.Sprintf("%s %s (select %s from %s where %s %s ?)",
		s.sourceCol, s.sourceOp,
		s.destSelCol.String(), s.destTable.Table(),
		s.destWhereCol.String(), s.destOp)
	args := []interface{}{s.destVal}
	return sql, args, nil
}

func Subquery(
	sourceCol kallax.SchemaField,
	sourceOp op,
	destSelCol kallax.SchemaField,
	destTable *kallax.BaseSchema,
	destWhereCol kallax.SchemaField,
	destOp op,
	destVal interface{},
) kallax.Condition {
	return func(schema kallax.Schema) kallax.ToSqler {
		return &subquery{
			sourceCol:    sourceCol.QualifiedName(schema),
			sourceOp:     sourceOp,
			destSelCol:   destSelCol,
			destTable:    destTable,
			destWhereCol: destWhereCol,
			destOp:       destOp,
			destVal:      destVal,
		}
	}
}

type fnloc uint8

const (
	fnselect fnloc = iota
)

type function struct {
	kallax.ToSqler

	fn     string
	loc    fnloc
	schema kallax.Schema

	args []kallax.SchemaField
}

func (f *function) ToSql() (string, []interface{}, error) {
	var params []string
	var args []interface{}

	if f.loc == fnselect {
		params = make([]string, len(f.args))
		for i, a := range f.args {
			params[i] = a.String()
		}
	}

	sql := fmt.Sprintf("%s(%s)", f.fn, strings.Join(params, ", "))
	return sql, args, nil
}

func FunctionSelect(fn string, args ...kallax.SchemaField) kallax.Condition {
	return func(schema kallax.Schema) kallax.ToSqler {
		return &function{
			fn:     fn,
			loc:    fnselect,
			args:   args,
			schema: schema,
		}
	}
}
