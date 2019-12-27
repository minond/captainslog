//go:generate stringer -type=QueryType
package query

import (
	"fmt"
	"strings"
)

type QueryType int32

const (
	SelectQuery QueryType = iota
)

type Operator uint8

const (
	OpInvalid Operator = iota

	OpAnd
	OpDiv
	OpEq
	OpGe
	OpGt
	OpIlike
	OpLe
	OpLike
	OpLt
	OpMinus
	OpMul
	OpOr
	OpPlus
)

var operatorStrings = map[Operator]string{
	OpInvalid: "invalid-operator",
	OpAnd:     "and",
	OpDiv:     "/",
	OpEq:      "=",
	OpGe:      ">=",
	OpGt:      ">",
	OpIlike:   "ilike",
	OpLe:      "<=",
	OpLike:    "like",
	OpLt:      "<",
	OpMinus:   "-",
	OpMul:     "*",
	OpOr:      "or",
	OpPlus:    "+",
}

func (o Operator) String() string {
	str, ok := operatorStrings[o]
	if ok {
		return str
	}
	return "unknown-operator"
}

type Ast interface {
	String() string
	Print(bool) string
	QueryType() QueryType
}

type SelectStmt struct {
	Distinct bool
	Columns  []Expr
	From     *Table
	Where    Expr
	GroupBy  []Expr
	Having   Expr
	OrderBy  []Order
	Limit    *Limit
}

func (SelectStmt) QueryType() QueryType {
	return SelectQuery
}

func (s SelectStmt) Print(pretty bool) string {
	cols := make([]string, len(s.Columns))
	for i, col := range s.Columns {
		cols[i] = col.String()
	}

	var query strings.Builder
	fmt.Fprint(&query, "select ")
	if s.Distinct {
		fmt.Fprint(&query, "distinct ")
	}
	fmt.Fprint(&query, strings.Join(cols, ", "))
	if s.From != nil {
		if pretty {
			fmt.Fprint(&query, "\nfrom ", s.From.String())
		} else {
			fmt.Fprint(&query, " from ", s.From.String())
		}
	}
	if s.Where != nil {
		if pretty {
			fmt.Fprint(&query, "\nwhere ", s.Where.String())
		} else {
			fmt.Fprint(&query, " where ", s.Where.String())
		}
	}
	if len(s.GroupBy) != 0 {
		group := make([]string, len(s.GroupBy))
		for i, expr := range s.GroupBy {
			group[i] = expr.String()
		}
		if pretty {
			fmt.Fprint(&query, "\ngroup by ", strings.Join(group, ", "))
		} else {
			fmt.Fprint(&query, " group by ", strings.Join(group, ", "))
		}
	}
	if s.Having != nil {
		if pretty {
			fmt.Fprint(&query, "\nhaving ", s.Having.String())
		} else {
			fmt.Fprint(&query, " having ", s.Having.String())
		}
	}
	if len(s.OrderBy) != 0 {
		order := make([]string, len(s.OrderBy))
		for i, expr := range s.OrderBy {
			order[i] = expr.String()
		}
		if pretty {
			fmt.Fprint(&query, "\norder by ", strings.Join(order, ", "))
		} else {
			fmt.Fprint(&query, " order by ", strings.Join(order, ", "))
		}
	}
	if s.Limit != nil && s.Limit.Expr != nil {
		if pretty {
			fmt.Fprint(&query, "\nlimit ", s.Limit.Expr.String())
		} else {
			fmt.Fprint(&query, " limit ", s.Limit.Expr.String())
		}
	}
	return query.String()
}

func (s SelectStmt) String() string {
	return s.Print(false)
}

type Table struct {
	Name  string
	Alias string
}

func (t Table) String() string {
	if t.Alias != "" {
		return t.Name + " as " + t.Alias
	}
	return t.Name
}

// https://github.com/postgres/postgres/blob/93f03dad824f14f40519597e5e4a8fe7b6df858e/src/backend/parser/gram.y#L11579
type Limit struct {
	Expr Expr
}

func (l Limit) String() string {
	return ""
}

type OrderDir uint8

const (
	Asc OrderDir = iota
	Desc
)

type Order struct {
	Dir  OrderDir
	Expr Expr
}

func (o Order) String() string {
	dir := "asc"
	if o.Dir == Desc {
		dir = "desc"
	}
	return o.Expr.String() + " " + dir
}

type Expr interface {
	String() string
	isExpr()
}

type Identifier struct {
	Source string
	Name   string
}

func (Identifier) isExpr() {}

func (i Identifier) String() string {
	v := i.Name
	if i.Source != "" {
		v = i.Source + "." + v
	}
	return v
}

type Application struct {
	Fn   string
	Args []Expr
}

func (Application) isExpr() {}

func (a Application) String() string {
	args := make([]string, len(a.Args))
	for i, arg := range a.Args {
		args[i] = arg.String()
	}
	return fmt.Sprintf("%s(%s)", a.Fn, strings.Join(args, ", "))
}

type ValueTy uint8

const (
	TyBool ValueTy = iota
	TyString
	TyNumber
)

type Value struct {
	Ty  ValueTy
	Tok Token
}

func (Value) isExpr() {}

func (v Value) String() string {
	if v.Ty == TyString {
		return fmt.Sprintf(`'%s'`, v.Tok.Lexeme)
	}
	return v.Tok.Lexeme
}

type Grouping struct {
	Sub Expr
}

func (Grouping) isExpr() {}

func (g Grouping) String() string {
	return fmt.Sprintf("(%s)", g.Sub.String())
}

type BinaryExpr struct {
	Left  Expr
	Op    Operator
	Right Expr
}

func (BinaryExpr) isExpr() {}

func (b BinaryExpr) String() string {
	return fmt.Sprintf("%s %s %s", b.Left.String(), b.Op, b.Right.String())
}

type UnaryExpr struct {
	Op    string
	Tight Expr
}

func (UnaryExpr) isExpr() {}

func (b UnaryExpr) String() string {
	return fmt.Sprintf("%s %s", b.Op, b.Tight.String())
}

type IsNull struct {
	Not  bool
	Expr Expr
}

func (IsNull) isExpr() {}

func (i IsNull) String() string {
	if i.Not {
		return fmt.Sprintf("%s is not null", i.Expr.String())
	}
	return fmt.Sprintf("%s is null", i.Expr.String())
}

type Aliased struct {
	As   string
	Expr Expr
}

func (Aliased) isExpr() {}

func (a Aliased) String() string {
	return fmt.Sprintf("%s as %s", a.Expr.String(), a.As)
}

type JSONField struct {
	Col  string
	Prop string
}

func (JSONField) isExpr() {}

func (j JSONField) String() string {
	return fmt.Sprintf("%s #>> '{%s}'", j.Col, j.Prop)
}

type Subquery struct {
	Stmt *SelectStmt
}

func (Subquery) isExpr() {}

func (s Subquery) String() string {
	return fmt.Sprintf("(%s)", s.Stmt.String())
}
