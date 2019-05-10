package query

import (
	"fmt"
	"strings"
)

type queryType int32

const (
	selectQuery queryType = iota
)

type operator uint8

const (
	opInvalid operator = iota

	opAnd
	opDiv
	opEq
	opGe
	opGt
	opLe
	opLike
	opLt
	opMinus
	opMul
	opOr
	opPlus
)

var operatorStrings = map[operator]string{
	opInvalid: "invalid-operator",
	opAnd:     "and",
	opDiv:     "/",
	opEq:      "=",
	opGe:      ">=",
	opGt:      ">",
	opLe:      "<=",
	opLike:    "like",
	opLt:      "<",
	opMinus:   "-",
	opMul:     "*",
	opOr:      "or",
	opPlus:    "+",
}

func (o operator) String() string {
	str, ok := operatorStrings[o]
	if ok {
		return str
	}
	return "unknown-operator"
}

type Ast interface {
	String() string
	queryType() queryType
}

type selectStmt struct {
	columns []column
	from    *table
	where   expr
	groupBy []expr
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
	if len(s.groupBy) != 0 {
		group := make([]string, len(s.groupBy))
		for i, expr := range s.groupBy {
			group[i] = expr.String()
		}
		fmt.Fprint(&query, " group by ", strings.Join(group, ", "))
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
	distinct bool
	val      expr
	alias    string
}

func (c column) String() string {
	var head, tail string

	if c.distinct {
		head = "distinct"
	}

	if c.alias != "" {
		tail = "as " + c.alias
	}

	return strings.TrimSpace(fmt.Sprintf("%s %s %s", head, c.val.String(), tail))
}

type expr interface {
	String() string
	isExpr()
}

type identifier struct {
	source string
	name   string
}

func (identifier) isExpr() {}

func (i identifier) String() string {
	if i.source != "" {
		return i.source + "." + i.name
	}
	return i.name
}

type application struct {
	fn   string
	args []expr
}

func (application) isExpr() {}

func (a application) String() string {
	args := make([]string, len(a.args))
	for i, arg := range a.args {
		args[i] = arg.String()
	}
	return fmt.Sprintf("%s(%s)", a.fn, strings.Join(args, ", "))
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
	if v.ty == tyString {
		return fmt.Sprintf(`'%s'`, v.tok.lexeme)
	}
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
	op    operator
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
