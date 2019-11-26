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
	expr()
}

type Sexpr struct{ Values []Expr }

func NewSexpr(values ...Expr) *Sexpr { return &Sexpr{Values: values} }
func (Sexpr) expr()                  {}
func (e Sexpr) String() string {
	buff := strings.Builder{}
	buff.WriteString("(")
	for i, val := range e.Values {
		if i != 0 {
			buff.WriteRune(' ')
		}
		buff.WriteString(val.String())
	}
	buff.WriteString(")")
	return buff.String()
}

type Quote struct{ Value Expr }

func NewQuote(value Expr) *Quote { return &Quote{Value: value} }
func (Quote) expr()              {}
func (e Quote) String() string   { return fmt.Sprintf("'%v", e.Value.String()) }

type Identifier struct{ Value string }

func NewIdentifier(value string) *Identifier { return &Identifier{Value: value} }
func (Identifier) expr()                     {}
func (e Identifier) String() string          { return e.Value }

type Number struct{ Value float64 }

func NewNumber(value float64) *Number { return &Number{Value: value} }
func (Number) expr()                  {}
func (e Number) String() string       { return strconv.FormatFloat(e.Value, 'f', -1, 64) }

type String struct{ Value string }

func NewString(value string) *String { return &String{Value: value} }
func (String) expr()                 {}
func (e String) String() string      { return fmt.Sprintf(`"%v"`, e.Value) }

type Boolean struct{ Value bool }

func NewBoolean(value bool) *Boolean { return &Boolean{Value: value} }
func (Boolean) expr()                {}
func (e Boolean) String() string {
	if e.Value {
		return "#t"
	}
	return "#f"
}
