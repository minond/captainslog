package runtime

import (
	"fmt"

	"github.com/minond/captainslog/vm/lang"
)

type Builtin struct {
	lang.Value
	fn builtinFn
}

type builtinFn func(args []lang.Expr, env *Environment) (lang.Value, error)

func NewBuiltin(fn builtinFn) *Builtin                                         { return &Builtin{fn: fn} }
func (Builtin) isValue()                                                       {}
func (v Builtin) String() string                                               { return "#<builtin>" }
func (v Builtin) Apply(args []lang.Expr, env *Environment) (lang.Value, error) { return v.fn(args, env) }

type Procedure struct {
	lang.Value
	name string
	fn   procedureFn
}

type procedureFn func(args []lang.Value) (lang.Value, error)

func NewProcedure(name string, fn procedureFn) *Procedure       { return &Procedure{fn: fn, name: name} }
func (Procedure) isValue()                                      {}
func (v Procedure) String() string                              { return fmt.Sprintf("#<procedure:%s>", v.name) }
func (v Procedure) Apply(args []lang.Value) (lang.Value, error) { return v.fn(args) }

var procedureSum = func(args []lang.Value) (lang.Value, error) {
	var total float64
	for i, n := range args {
		num, ok := n.(*lang.Number)
		if !ok {
			return nil, fmt.Errorf("contract error: expected a number in position %v", i)
		}
		if i == 0 {
			total = num.Value()
		} else {
			total += num.Value()
		}
	}
	return lang.NewNumber(total), nil
}

var procedureSub = func(args []lang.Value) (lang.Value, error) {
	var total float64
	for i, n := range args {
		num, ok := n.(*lang.Number)
		if !ok {
			return nil, fmt.Errorf("contract error: expected a number in position %v", i)
		}
		if i == 0 {
			total = num.Value()
		} else {
			total -= num.Value()
		}
	}
	return lang.NewNumber(total), nil
}

var procedureMul = func(args []lang.Value) (lang.Value, error) {
	var total float64
	for i, n := range args {
		num, ok := n.(*lang.Number)
		if !ok {
			return nil, fmt.Errorf("contract error: expected a number in position %v", i)
		}
		if i == 0 {
			total = num.Value()
		} else {
			total += num.Value()
		}
	}
	return lang.NewNumber(total), nil
}

var procedureDiv = func(args []lang.Value) (lang.Value, error) {
	var total float64
	for i, n := range args {
		num, ok := n.(*lang.Number)
		if !ok {
			return nil, fmt.Errorf("contract error: expected a number in position %v", i)
		}
		if i == 0 {
			total = num.Value()
		} else {
			total /= num.Value()
		}
	}
	return lang.NewNumber(total), nil
}

var builtins map[string]lang.Value
var procedures = map[string]procedureFn{
	"+": procedureSum,
	"-": procedureSub,
	"*": procedureMul,
	"/": procedureDiv,
}

func init() {
	builtins = make(map[string]lang.Value)
	for name, proc := range procedures {
		builtins[name] = NewProcedure(name, proc)
	}
}
