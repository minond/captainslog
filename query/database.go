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

func Exec(store querier, origSQL, userGUID string) ([]string, [][]interface{}, error) {
	ast, err := Parse(origSQL)
	if err != nil {
		return nil, nil, err
	}

	if _, ok := ast.(*selectStmt); !ok {
		return nil, nil, errors.New("only select statements are allowed")
	}

	converted, err := Convert(ast, userGUID)
	if err != nil {
		return nil, nil, err
	}

	irs, err := store.RawQuery(converted.String())
	if err != nil {
		return nil, nil, err
	}
	defer irs.Close()

	switch rs := irs.(type) {
	case *kallax.BaseResultSet:
		return scan(rs)
	}

	return nil, nil, errors.New("bad record set")
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
		default:
			return nil, fmt.Errorf("bad type: %v", typ)
		}
	}
	return row, nil
}

const (
	pgFloat8 = "FLOAT8"
	pgText   = "TEXT"
)

func isString(typ *sql.ColumnType) bool {
	return typ.DatabaseTypeName() == pgText
}

func isFloat(typ *sql.ColumnType) bool {
	return typ.DatabaseTypeName() == pgFloat8
}