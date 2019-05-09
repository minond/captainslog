package query

import (
	"fmt"
	"strings"
)

type queryType int32

const (
	selectQuery queryType = iota
)

type Ast interface {
	String() string
	queryType() queryType
}

type selectStmt struct {
	columns []column
	from    *table
	where   expr
}

func (selectStmt) queryType() queryType {
	return selectQuery
}

func (s selectStmt) String() string {
	cols := make([]string, len(s.columns))
	for i, col := range s.columns {
		cols[i] = col.String()
	}

	var query strings.Builder
	fmt.Fprint(&query, "select ", strings.Join(cols, ", "))
	if s.from != nil {
		fmt.Fprint(&query, " from ", s.from.String())
	}
	if s.where != nil {
		fmt.Fprint(&query, " where ", s.where.String())
	}
	return query.String()
}

type table struct {
	name  string
	alias string
}

func (t table) String() string {
	if t.alias != "" {
		return t.name + " as " + t.alias
	}
	return t.name
}

type column struct {
	name     string
	alias    string
	source   string
	distinct bool
}

func (c column) String() string {
	var header string
	var middle string
	var footer string

	if c.distinct {
		header = "distinct"
	}

	if c.source == "" {
		middle = c.name
	} else {
		middle = c.source + "." + c.name
	}

	if c.alias != "" {
		footer = "as " + c.alias
	}

	return strings.TrimSpace(fmt.Sprintf("%s %s %s", header, middle, footer))
}

type expr interface {
	String() string
	isExpr()
}

type identifier struct {
	name   string
	source string
}

func (identifier) isExpr() {}

func (i identifier) String() string {
	if i.source != "" {
		return i.source + "." + i.name
	}
	return i.name
}

type valueTy uint8

const (
	tyBool valueTy = iota
	tyString
	tyNumber
)

type value struct {
	ty  valueTy
	tok token
}

func (value) isExpr() {}

func (v value) String() string {
	return v.tok.lexeme
}

type grouping struct {
	sub expr
}

func (grouping) isExpr() {}

func (g grouping) String() string {
	return fmt.Sprintf("(%s)", g.sub.String())
}

type binaryExpr struct {
	left  expr
	op    string
	right expr
}

func (binaryExpr) isExpr() {}

func (b binaryExpr) String() string {
	return fmt.Sprintf("%s %s %s", b.left.String(), b.op, b.right.String())
}

func (unaryExpr) isExpr() {}

type unaryExpr struct {
	op    string
	right expr
}

func (b unaryExpr) String() string {
	return fmt.Sprintf("%s %s", b.op, b.right.String())
}
