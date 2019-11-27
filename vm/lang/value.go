package lang

import (
	"fmt"
	"strings"
)

type Value interface {
	fmt.Stringer
	isValue()
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
