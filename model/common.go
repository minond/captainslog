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
	Ilike
)

func (o op) String() string {
	switch o {
	case Like:
		return "like"
	case Ilike:
		return "ilike"
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

type function struct {
	kallax.SchemaField

	fn   string
	args []kallax.SchemaField
}

func (f *function) QualifiedName(schema kallax.Schema) string {
	params := make([]string, len(f.args))
	for i, a := range f.args {
		params[i] = a.QualifiedName(schema)
	}
	return fmt.Sprintf("%s(%s)", f.fn, strings.Join(params, ", "))
}

func (f *function) String() string { return f.QualifiedName(nil) }
func (*function) isSchemaField()   {}

func FunctionSelect(fn string, args ...kallax.SchemaField) kallax.SchemaField {
	return &function{
		fn:   fn,
		args: args,
	}
}

type isNull struct {
	kallax.ToSqler

	not   bool
	field string
}

func (i *isNull) ToSql() (string, []interface{}, error) {
	if i.not {
		return i.field + " is not null", nil, nil
	}
	return i.field + " is null", nil, nil
}

func IsNull(field kallax.SchemaField) kallax.Condition {
	return func(schema kallax.Schema) kallax.ToSqler {
		return &isNull{
			not:   false,
			field: field.QualifiedName(schema),
		}
	}
}

func IsNotNull(field kallax.SchemaField) kallax.Condition {
	return func(schema kallax.Schema) kallax.ToSqler {
		return &isNull{
			not:   true,
			field: field.QualifiedName(schema),
		}
	}
}

type distinct struct {
	kallax.SchemaField

	field kallax.SchemaField
}

func (d *distinct) isSchemaField() {}

func (d *distinct) String() string {
	return d.field.String()
}

func (d *distinct) QualifiedName(schema kallax.Schema) string {
	return "distinct " + d.field.QualifiedName(schema) + " as " + d.String()
}

func Distinct(field kallax.SchemaField) kallax.SchemaField {
	return &distinct{field: field}
}
