package lang

import (
	"fmt"
	"strconv"
	"strings"
)

/**
 * main			 = epxr*
 *               ;
 *
 * expr          = "(" expr ")"
 *               | "'" expr
 *               | identifier
 *               | number
 *               | string
 *               | boolean
 *               ;
 *
 * boolean       = "#t"
 *               | "#f"
 *               ;
 *
 * identifier    = ?? identifier ??
 *               ;
 *
 * number        = ?? number ??
 *               ;
 *
 * string        = ?? string ??
 *               ;
 */
type Expr interface {
	fmt.Stringer
	isExpr()
}

type Sexpr struct {
	Expr
	values []Expr
}

func NewSexpr(values ...Expr) *Sexpr {
	return &Sexpr{values: values}
}

func (e Sexpr) Size() int {
	return len(e.values)
}

func (e Sexpr) Head() Expr {
	return e.values[0]
}

func (e Sexpr) Tail() []Expr {
	return e.values[1:]
}

func (e Sexpr) String() string {
	buff := strings.Builder{}
	buff.WriteString("(")
	for i, val := range e.values {
		if i != 0 {
			buff.WriteRune(' ')
		}
		buff.WriteString(val.String())
	}
	buff.WriteString(")")
	return buff.String()
}

type Quote struct {
	Expr
	value Expr
}

func NewQuote(value Expr) *Quote {
	return &Quote{value: value}
}

func (Quote) isValue() {}

func (e Quote) String() string {
	return fmt.Sprintf("'%v", e.value.String())
}

type Identifier struct {
	Expr
	value string
}

func NewIdentifier(value string) *Identifier {
	return &Identifier{value: value}
}

func (Identifier) isValue() {}

func (e Identifier) Value() string {
	return e.value
}

func (e Identifier) String() string {
	return e.value
}

type Number struct {
	Expr
	value float64
}

func NewNumber(value float64) *Number {
	return &Number{value: value}
}

func (Number) isValue() {}

func (e Number) Value() float64 {
	return e.value
}

func (e Number) String() string {
	return strconv.FormatFloat(e.value, 'f', -1, 64)
}

type String struct {
	Expr
	value string
}

func NewString(value string) *String {
	return &String{value: value}
}

func (String) isValue() {}

func (e String) String() string {
	return fmt.Sprintf(`"%v"`, e.value)
}

type Boolean struct {
	Expr
	value bool
}

func NewBoolean(value bool) *Boolean {
	return &Boolean{value: value}
}

func (Boolean) isValue() {}

func (e Boolean) Value() bool {
	return e.value
}

func (e Boolean) String() string {
	if e.value {
		return "#t"
	}
	return "#f"
}
