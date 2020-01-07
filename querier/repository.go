package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"
)

var (
	ErrEmptyColumnSet = errors.New("empty column set")
)

type Repository interface {
	Execute(context.Context, string) ([]string, [][]interface{}, error)
}

type repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) Repository {
	return &repository{
		db: db,
	}
}

func (r *repository) Execute(ctx context.Context, sql string) ([]string, [][]interface{}, error) {
	rows, err := r.db.QueryContext(ctx, sql)
	if err != nil {
		return nil, nil, err
	}
	defer rows.Close()

	columns, columnTypes, err := columnInfo(rows)
	if err != nil {
		return nil, nil, err
	}

	results, err := scanRows(rows, columnTypes)
	if err != nil {
		return nil, nil, err
	}

	return columns, results, nil
}

func scanRows(rows *sql.Rows, columnTypes []*sql.ColumnType) ([][]interface{}, error) {
	var results [][]interface{}

	for rows.Next() {
		result, err := scanRow(rows, columnTypes)
		if err != nil {
			return nil, err
		}

		results = append(results, result)
	}

	return results, nil
}

func scanRow(rows *sql.Rows, columnTypes []*sql.ColumnType) ([]interface{}, error) {
	container, err := buildRowContainer(columnTypes)
	if err != nil {
		return nil, err
	}

	if err := rows.Scan(container...); err != nil {
		return nil, err
	}

	return container, nil
}

func columnInfo(rows *sql.Rows) ([]string, []*sql.ColumnType, error) {
	columns, err := rows.Columns()
	if err != nil {
		return nil, nil, err
	}

	columnTypes, err := rows.ColumnTypes()
	if err != nil {
		return nil, nil, err
	} else if len(columnTypes) == 0 {
		return nil, nil, ErrEmptyColumnSet
	}

	return columns, columnTypes, nil
}

func buildRowContainer(columnTypes []*sql.ColumnType) ([]interface{}, error) {
	row := make([]interface{}, len(columnTypes))
	for i, typ := range columnTypes {
		switch {
		case isString(typ):
			row[i] = &sql.NullString{}
		case isFloat(typ):
			row[i] = &sql.NullFloat64{}
		case isInt(typ):
			row[i] = &sql.NullInt64{}
		case isBool(typ):
			row[i] = &sql.NullBool{}
		case isTimestampt(typ):
			row[i] = &NullTime{}
		default:
			return nil, fmt.Errorf("bad type: %s", typ.DatabaseTypeName())
		}
	}
	return row, nil
}

type NullTime struct {
	Valid bool      `json:"valid"`
	Time  time.Time `json:"time"`
}

func (nt *NullTime) Scan(value interface{}) error {
	nt.Time = value.(time.Time)
	nt.Valid = true
	return nil
}

const (
	pgBool       = "BOOL"
	pgFloat8     = "FLOAT8"
	pgInt4       = "INT4"
	pgInt8       = "INT8"
	pgNumeric    = "NUMERIC"
	pgText       = "TEXT"
	pgTimestampt = "TIMESTAMPTZ"
)

func isString(typ *sql.ColumnType) bool {
	return typ.DatabaseTypeName() == pgText
}

func isFloat(typ *sql.ColumnType) bool {
	return typ.DatabaseTypeName() == pgFloat8 ||
		typ.DatabaseTypeName() == pgNumeric
}

func isInt(typ *sql.ColumnType) bool {
	return typ.DatabaseTypeName() == pgInt8 ||
		typ.DatabaseTypeName() == pgInt4
}

func isBool(typ *sql.ColumnType) bool {
	return typ.DatabaseTypeName() == pgBool
}

func isTimestampt(typ *sql.ColumnType) bool {
	return typ.DatabaseTypeName() == pgTimestampt
}
