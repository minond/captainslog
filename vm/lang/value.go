package lang

import (
	"fmt"
	"strings"
)

type Value interface {
	fmt.Stringer
	isValue()
}

type Applicable interface {
	Apply([]Value) (Value, error)
}

type List struct{ values []Value }

func NewList(values []Value) *List { return &List{values: values} }
func (List) isValue()              {}
func (v List) Head() Value         { return v.values[0] }
func (v List) Tail() []Value       { return v.values[1:] }
func (v List) String() string {
	buff := strings.Builder{}
	buff.WriteString("(list")
	for _, val := range v.values {
		buff.WriteRune(' ')
		buff.WriteString(val.String())
	}
	buff.WriteString(")")
	return buff.String()
}

type builtinFn func(...Value) (Value, error)
type Builtin struct{ fn builtinFn }

func NewBuiltin(fn builtinFn) *Builtin              { return &Builtin{fn: fn} }
func (Builtin) isValue()                            {}
func (v Builtin) String() string                    { return "(builtin)" }
func (v Builtin) Apply(args []Value) (Value, error) { return v.fn(args...) }
