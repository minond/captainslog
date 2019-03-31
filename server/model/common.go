package model

import (
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
