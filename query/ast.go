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
	opIlike
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
	opIlike:   "ilike",
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
	Print(bool) string
	queryType() queryType
}

type selectStmt struct {
	distinct bool
	columns  []expr
	from     *table
	where    expr
	groupBy  []expr
}

func (selectStmt) queryType() queryType {
	return selectQuery
}

func (s selectStmt) Print(pretty bool) string {
	cols := make([]string, len(s.columns))
	for i, col := range s.columns {
		cols[i] = col.String()
	}

	var query strings.Builder
	fmt.Fprint(&query, "select ")
	if s.distinct {
		fmt.Fprint(&query, "distinct ")
	}
	fmt.Fprint(&query, strings.Join(cols, ", "))
	if s.from != nil {
		if pretty {
			fmt.Fprint(&query, "\nfrom ", s.from.String())
		} else {
			fmt.Fprint(&query, " from ", s.from.String())
		}
	}
	if s.where != nil {
		if pretty {
			fmt.Fprint(&query, "\nwhere ", s.where.String())
		} else {
			fmt.Fprint(&query, " where ", s.where.String())
		}
	}
	if len(s.groupBy) != 0 {
		group := make([]string, len(s.groupBy))
		for i, expr := range s.groupBy {
			group[i] = expr.String()
		}
		if pretty {
			fmt.Fprint(&query, "\ngroup by ", strings.Join(group, ", "))
		} else {
			fmt.Fprint(&query, " group by ", strings.Join(group, ", "))
		}
	}
	return query.String()
}

func (s selectStmt) String() string {
	return s.Print(false)
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
	v := i.name
	if i.source != "" {
		v = i.source + "." + v
	}
	return v
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

type unaryExpr struct {
	op    string
	right expr
}

func (unaryExpr) isExpr() {}

func (b unaryExpr) String() string {
	return fmt.Sprintf("%s %s", b.op, b.right.String())
}

type isNull struct {
	not  bool
	expr expr
}

func (isNull) isExpr() {}

func (i isNull) String() string {
	if i.not {
		return fmt.Sprintf("%s is not null", i.expr.String())
	}
	return fmt.Sprintf("%s is null", i.expr.String())
}

type aliased struct {
	as   string
	expr expr
}

func (aliased) isExpr() {}

func (a aliased) String() string {
	return fmt.Sprintf("%s as %s", a.expr.String(), a.as)
}

type jsonfield struct {
	col  string
	prop string
}

func (jsonfield) isExpr() {}

func (j jsonfield) String() string {
	return fmt.Sprintf("%s #>> '{%s}'", j.col, j.prop)
}

type subquery struct {
	stmt *selectStmt
}

func (subquery) isExpr() {}

func (s subquery) String() string {
	return fmt.Sprintf("(%s)", s.stmt.String())
}
