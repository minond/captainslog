package query

import (
	"database/sql"
	"errors"
	"fmt"

	"gopkg.in/src-d/go-kallax.v1"
)

type querier interface {
	RawQuery(sql string, params ...interface{}) (kallax.ResultSet, error)
}

func Exec(store querier, origSQL, userGUID string) (string, []string, [][]interface{}, error) {
	ast, err := Parse(origSQL)
	if err != nil {
		return "", nil, nil, err
	}

	if _, ok := ast.(*selectStmt); !ok {
		return "", nil, nil, errors.New("only select statements are allowed")
	}

	converted, err := Convert(ast, userGUID)
	if err != nil {
		return "", nil, nil, err
	}

	executedQuery := converted.String()
	irs, err := store.RawQuery(executedQuery)
	if err != nil {
		return executedQuery, nil, nil, err
	}
	defer irs.Close()

	switch rs := irs.(type) {
	case *kallax.BaseResultSet:
		cols, rows, err := scan(rs)
		return executedQuery, cols, rows, err
	}

	return executedQuery, nil, nil, errors.New("bad record set")
}

func scan(rs *kallax.BaseResultSet) ([]string, [][]interface{}, error) {
	var rows [][]interface{}

	cols, err := rs.Rows.Columns()
	if err != nil {
		return nil, nil, err
	}

	if len(cols) == 0 {
		return nil, nil, nil
	}

	typs, err := rs.Rows.ColumnTypes()
	if err != nil {
		return nil, nil, err
	}

	for rs.Next() {
		row, err := rowContainer(typs)
		if err != nil {
			return nil, nil, err
		}
		if err := rs.RawScan(row...); err != nil {
			return nil, nil, err
		}
		rows = append(rows, row)
	}

	return cols, rows, nil
}

func rowContainer(typs []*sql.ColumnType) ([]interface{}, error) {
	row := make([]interface{}, len(typs))
	for i, typ := range typs {
		switch {
		case isString(typ):
			row[i] = &sql.NullString{}
		case isFloat(typ):
			row[i] = &sql.NullFloat64{}
		case isInt(typ):
			row[i] = &sql.NullInt64{}
		case isBool(typ):
			row[i] = &sql.NullBool{}
		default:
			return nil, fmt.Errorf("bad type: %v", typ)
		}
	}
	return row, nil
}

const (
	pgBool    = "BOOL"
	pgFloat8  = "FLOAT8"
	pgInt4    = "INT4"
	pgInt8    = "INT8"
	pgNumeric = "NUMERIC"
	pgText    = "TEXT"
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
